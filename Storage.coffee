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
    constructor: (serverUrl, @dbname)->
        $.couch.urlPrefix = serverUrl
        
    get: (id, cb) ->
        $.couch.db(@dbname).openDoc id,
            success: (data) ->
                cb null, data
            error: (status) ->
                if status is 404 or status is '404'
                    cb null, null
                else
                    cb status
        
        
    save: (id, doc, cb) ->
        @get id, (err, data) =>
            doc._rev = data._rev if data?._rev
            doc._id = id
            $.couch.db(@dbname).saveDoc doc,
                success: (data) ->
                    cb null, data
                error: (status) ->
                    cb status




window.LocalStorage = LocalStorage
window.CouchStorage = CouchStorage