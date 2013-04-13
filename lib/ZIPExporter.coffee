class ZIPExporter
    constructor: ->
    
    export: (storage, cb) ->
        @zip = new JSZip()
        @assets = @zip.folder 'assets'
        @_export storage, (err) =>
            if err? then return cb err
            @zip.file "content.json", JSON.stringify @data
            zipFileLink = "data:application/zip;base64," + @zip.generate
                base64: true
                compression: 'STORE'
                
            cb null, zipFileLink
       
    _export: (storage, cb) ->
        @data = {}
        @storage = storage
        async.parallel [
            (cb) => 
                @storage.get "root", (err, rootDoc) =>
                    if err? then return cb err
                    @data.root = rootDoc
                    rootNodeId = rootDoc?.value or null
                    @_exportTree(rootNodeId, cb)
            
            (cb) => @_exportTree("yes_no", cb)
        ], (err, results) ->
            cb err
        
    
    _exportTree: (rootNodeId, cb) ->
        console.log "### Start exporting with rootNodeId", rootNodeId
        if not rootNodeId? then return cb "rootNodeId not found"
        
        vq = async.queue (id, cb) =>
            @_visitNode vq, id, cb
        , 3

        vq.drain = =>
            console.log "finished exporting"
            console.log @data
            cb null
    
        vq.push rootNodeId, (err, nodeId) ->
            console.log "finished exporting root (id=#{nodeId}) with error #{err}"
            
    _visitNode: (vq, nodeId, cb) ->
            async.parallel [
                (cb) => @storage.get "node_#{nodeId}_cells", cb
                (cb) => @storage.get "node_#{nodeId}_children", cb
            ], (err, results) =>
                if err? then return cb err
                [cells, children] = results

                if children? and not _.isEmpty(children)
                    console.log "Start exporting node #{nodeId}'s children"
                    @data["node_#{nodeId}_children"] = children
                    for own position, childNodeId of children
                        console.log "starting exporting node #{childNodeId}"
                        vq.push childNodeId, (err, nodeId) ->
                            console.log "finished exporting node #{nodeId} with error #{err}"
                
                if cells? and not _.isEmpty(cells)
                    console.log "Start exporting node #{nodeId}'s cells"
                    @data["node_#{nodeId}_cells"] = cells
                    q = async.queue (id, cb) =>
                        key = "cell_#{id}"
                        console.log "getting data of #{key}"
                        @storage.get key, (err, doc) =>
                            if doc? and not _.isEmpty(doc)
                                @data[key] = doc 
                                @handleCellData id, doc, cb
                            else
                                cb err, nodeId
                    , 3

                    q.drain = ->
                        console.log "Done exporting node #{nodeId}'s cells"
                        cb null, nodeId
                    
                    for own position, cellId of cells
                        q.push cellId, (err, cellId) ->
                            console.log "finished getting cell #{cellId} with error #{err}"

                else
                    cb null, nodeId
                    
    handleCellData: (cellId, doc, cb) ->
        # purpose: download linked resources and put then in a zip archive
        # replace external URIs with relative local URIs
        # Example:
        #   input: http://localhost:1234/blabla
        #   output: ./blabla
        #   input: data://<data>
        #   output: ./blob001
        
        gotSomethingQueued = false
        q = async.queue (url, cb) =>
            console.log "downloading #{url} ..."

            $.ajax 
                url: url
                dataType: "text"
                beforeSend: (x) ->
                    if x?.overrideMimeType
                        x.overrideMimeType 'text/plain; charset=x-user-defined'
                error: (jqXHR, textStatus, errorThrown) -> cb errorThrown
                success: (data, textStatis, xhr) ->
                    cleanData = ""
                    for x in [0...data.length]
                        code = data.charCodeAt(x) & 0xff
                        cleanData += String.fromCharCode(code)
                    cb null, 
                        data: cleanData
                        contentType: xhr.getResponseHeader("content-type") 
        , 3
        
        q.drain = ->
            console.log "Finished downloading assets of cell #{cellId}"
            cb null, cellId
            
        ignoreKeys = ["label"]
        
        isExternalURI = (uri) ->
            return uri.substr(0,5) is "http:"
        
        for k, v of doc
            if k in ignoreKeys then continue
            ( (k, v) =>
                console.log "typeof value is #{typeof v}"
                if isExternalURI(v)
                    gotSomethingQueued = true
                    q.push v, (err, o) =>
                        if err?
                            console.log "download ended with error #{err}"
                        else
                            console.log "received #{o.data.length} bytes #{o.data.substr(1,3)}"
                            filename = "cell_#{cellId}_#{k}"
                            extension = window.mimeTypes[o.contentType or "text/plain"]
                            filename += ".#{extension}"
                            
                            #@data[filename] = data.length
                            @assets.file filename, o.data, {base64: false, binary: true}
                                
                            doc[k] = "./assets/#{filename}"
            )(k, v)

        if not gotSomethingQueued
            cb null, cellId
            
module.exports = ZIPExporter    