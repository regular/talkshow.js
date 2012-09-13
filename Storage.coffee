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
        
class LocalStorage extends Storage
    # TODO: remove async simulation timeout
    
    get: (id, cb) ->
        s = localStorage.getItem id
        doc = null
        doc = JSON.parse(s) if s isnt null
        window.setTimeout ->
            cb null, doc
        , 10
        
    save: (id, doc, cb) ->
        localStorage.setItem id, if doc isnt null then JSON.stringify(doc) else null
        window.setTimeout ->
            cb null
        , 10

class CouchStorage extends Storage
    constructor: (@serverUrl, @dbname)->
        $.couch.urlPrefix = @serverUrl
        
    get: (id, cb) ->
        $.couch.db(@dbname).openDoc id,
            success: (doc) =>
                # make attachments URLs available 
                if doc._attachments?
                    for own name, a of doc._attachments
                        doc[name] = "#{@serverUrl}/#{@dbname}/#{id}/#{name}"
                console.log "get returns", doc
                cb null, doc
            error: (status) ->
                if status is 404 or status is '404'
                    cb null, null
                else
                    cb status
        
    replaceBlobs: (id, oldDoc, doc, cb) ->
        newDoc = 
            _attachments: oldDoc?._attachments or {}
        
        # remove old attachments
        for k of newDoc._attachments
            if not (k of doc) or not doc[k]?
                newDoc._attachments[k] = null
        
        for own k, v of doc
            if typeof v is 'string' and v.substr(0, 5) is 'data:'
                meta = v.substr 0, v.indexOf ','
                [scheme, content_type, encoding] = meta.split /[:;]/g
                if encoding is not "base64" then return cb "createInlineAttachments: encoding is not base64!"
                newDoc._attachments[k] =
                    content_type: content_type
                    data: v.substr meta.length + 1
            else
                newDoc[k] = v
        cb null, newDoc
        
    save: (id, doc, cb) ->
        console.log "saving #{id}"
        @get id, (err, oldDoc) =>
            console.log 'oldDoc', oldDoc
            @replaceBlobs id, oldDoc, doc, (err, newDoc) =>
                if err? then return cb err
                newDoc._rev = oldDoc._rev if oldDoc?
                newDoc._id = id
                console.log "writing:", newDoc
                $.couch.db(@dbname).saveDoc newDoc,
                    success: (data) ->
                        cb null, data
                    error: (status) ->
                        cb status

window.LocalStorage = LocalStorage
window.CouchStorage = CouchStorage