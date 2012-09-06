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

window.LocalStorage = LocalStorage