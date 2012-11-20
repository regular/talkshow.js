setupUIDGenerator = (storage, cb) ->
    storage.get "currId", (err, doc) ->
        currId = doc?.value or 0

        window.uniqueId = (cb) ->
            ret = currId
            currId++
            storage.save "currId", {value: currId}, (err) ->
                cb err, ret
        
        cb err



class Talkshow
        
    export: (exporterName, cb) ->
        exporter = new ZIPExporter
        exporter.export @storage, cb
    
    constructor: (@accessibilityMode, cb) ->
        #@storage = new LocalStorage
        new StorageFactory().getBestStorage (err, result) =>
            if err? then return cb err
            @storage = result
            
            grid = new Grid 4, 2
            @navigationController = new NavigationController grid
        
            async.parallel [
                (cb) =>
                    setupUIDGenerator @storage, (err) =>
                        if err? then return cb "Failed to initialize UIDGenerator #{err}"
                        cb null, null
                (cb) =>
                    @storage.get "root", cb
                (cb) =>
                    new Settings @storage, cb
            ], (err, [ignored, rootDoc, settings]) =>
                if err? then return cb err
                rootNodeId = rootDoc?.value or null
                console.log "rootNodeId", rootNodeId
        
                @accessibilityMode.initializeDataSource
                    delegate: this
                    grid: grid
                    storage: @storage
                    nodeId: rootNodeId
                , (err, newDataSource) =>
                    if err? then return cb err
                    @navigationController.push newDataSource, =>
                        keyboardInput = KeyboardInput.get this
                        cb null, this

    enterCell: (x,y, cb) ->
        @navigationController.currentController().enterCell x,y, cb
    
    pop: (cb) ->
        if @navigationController.count()>1
            @navigationController.pop =>
                myDataSource = @navigationController.currentController().ds2
                $('#navBar').html myDataSource.navTitle
                cb null
        else
            cb null
    
    enteredCell: (dataSource, position, level, nodeId, cellData, cb) ->
        console.log "enteredCell #{position.x}/#{position.y} level: #{level} nodeId: #{nodeId}"
        @accessibilityMode.makeDataSource
            delegate: this
            grid: @grid
            storage: @storage
            parent: dataSource
            position: position
            level: level
            nodeId: nodeId
            cellData: cellData
        , (err, newDataSource) =>
            @navigationController.push newDataSource, ->
                cb null
    
window.Talkshow = Talkshow