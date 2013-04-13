###
  The Storage interface aims to be compatible with all of these
  - localStorage
  - in-memory objects
  - cloud-based database APIs
###

class Storage
    
    get: (id, cb) ->
    save: (id, doc, cb) ->
    remove: (id, cb) ->
        @save id, null, cb
    toString: -> "unkown Storage"
        
class LocalStorage extends Storage
    constructor: (cb) ->
        cb null, this
        
    toString: -> "HTML5 LocalStorage"
    
    get: (id, cb) ->
        s = localStorage.getItem id
        doc = null
        doc = JSON.parse(s) if s isnt null
        cb null, doc
        
    save: (id, doc, cb) ->
        # TODO: handle out of space exception
        localStorage.setItem id, if doc isnt null then JSON.stringify(doc) else null
        cb null

class CouchStorage extends Storage
    constructor: (@serverUrl, @dbname, cb)->
        $.couch.urlPrefix = @serverUrl
        
        $.couch.db(@dbname).info
            success: (data) =>
                cb null, this
            error: (err) =>
                cb err, null
    
    toString: -> "CouchDB at #{@serverUrl}/#{@dbname}"
    
    get: (id, cb) ->
        @_get id, (err, doc) ->
            if err? then return cb err
            
            # remove keys added by couch
            cleanDoc = {}
            
            for own k, v of doc
                if k.substr(0,1) is "_" then continue
                cleanDoc[k] = doc[k]
            
            cb null, cleanDoc
        
    _get: (id, cb) ->
        $.couch.db(@dbname).openDoc id,
            success: (doc) =>
                doc = _.clone(doc)
                # make attachments URLs available 
                if doc._attachments?
                    # console.log "iterating attachments"
                    for own name of doc._attachments
                        link = "#{@serverUrl}/#{@dbname}/#{id}/#{name}"
                        #console.log "- #{name}, #{link}"
                        doc[name] = link
                #console.log "get returns", JSON.parse JSON.stringify doc
                cb null, doc
            error: (status) ->
                if status is 404 or status is '404'
                    cb null, null
                else
                    cb status
        
    replaceBlobs: (id, oldDoc, doc, cb) ->
        newDoc = {}
        newAtt = {}

        # remove old attachments
        for own k of (oldDoc?._attachments) or {}
            if doc[k] isnt null
                newAtt[k] = oldDoc._attachments[k]

        newDoc._attachments = newAtt
        
        # convert data URIs to attachments
        for own k, v of doc
            if typeof v is 'string' and v.substr(0, 5) is 'data:'
                meta = v.substr 0, v.indexOf ','
                [scheme, content_type, encoding] = meta.split /[:;]/g
                if encoding is not "base64" then return cb "createInlineAttachments: encoding is not base64!"
                newDoc._attachments[k] =
                    content_type: content_type
                    data: v.substr meta.length + 1
            else
                newDoc[k] = v if v isnt null and k isnt "_attachments"
        
        cb null, newDoc
        
    save: (id, doc, cb) ->
        #console.log "saving #{id}"
        @_get id, (err, oldDoc) =>
            #console.log 'oldDoc', oldDoc
            @replaceBlobs id, oldDoc, doc, (err, newDoc) =>
                if err? then return cb err
                newDoc._rev = oldDoc._rev if oldDoc?
                newDoc._id = id
                #console.log "writing:", JSON.parse JSON.stringify newDoc
                $.couch.db(@dbname).saveDoc newDoc,
                    success: (data) ->
                        cb null, data
                    error: (status) ->
                        cb status

class FileStorage extends Storage
    constructor: (@filename, cb) ->
        $.ajax 
            url: @filename
            dataType: "text"
            success: (data) =>
                console.log data
                @data = JSON.parse(data)
                if @data.root?
                    return cb null, this
                else
                    return cb "no root found", null
            error: (xhr, textStatus, err) =>
                cb err, null
        
    toString: -> "File #{@filename}"
    
    get: (id, cb) ->
        cb null, @data[id] or null
        
    save: (id, doc, cb) ->
        @data[id] = doc
        cb null

class StorageFactory
    getBestStorage: (cb) ->
        errors = {}
        async.parallel [
            (cb) =>
                new CouchStorage 'http://localhost:5984', 'talkshow', (err, result) ->
                    errors.CouchStorage = err
                    cb null, result
            (cb) =>
                new FileStorage 'content.json', (err, result) ->
                    errors.FileStorage = err
                    cb null, result
            (cb) =>
                new LocalStorage (err, result) ->
                    errors.LocalStorage = err
                    cb null, result
        ], (err, results) ->
            console.log errors
            for x in results
                if x? then return cb null, x
            cb errors

module.exports.LocalStorage = LocalStorage
module.exports.CouchStorage = CouchStorage
module.exports.FileStorage = FileStorage
module.exports.StorageFactory = StorageFactory