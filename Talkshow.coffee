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
    
    constructor: (cb) ->
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
        
                async.parallel [
                    (cb) =>
                        new DataSource 
                            grid: grid
                            level: 1, 
                            nodeId: rootNodeId
                            delegate: this
                            storage: @storage
                        , cb
                    (cb) =>
                         new DataSource 
                            grid: grid,
                            level: 1
                            nodeId: "yes_no"
                            storage: @storage
                         , cb
                ], (err, results) =>
                    if err? then return cb err
                    [myDataSource, @yesNoDataSource] = results
                    myDataSource.navTitle = ">"
                    splitDataSource = new SplitDataSource @yesNoDataSource, myDataSource, 1

                    @navigationController.push splitDataSource

                    keyboardInput = KeyboardInput.get this
                    cb null, this

    enterCell: (x,y, cb) ->
        @navigationController.currentController().enterCell x,y, cb
    
    pop: ->
        if @navigationController.count()>1
            @navigationController.pop()
        myDataSource = @navigationController.currentController().ds2
        $('#navBar').html myDataSource.navTitle
    
    enteredCell: (dataSource, position, level, nodeId, cellData, cb) ->
        console.log "enteredCell #{position.x}/#{position.y} level: #{level} nodeId: #{nodeId}"
        new DataSource 
            grid: @grid
            level: level
            nodeId: nodeId
            parent: dataSource,
            position: position
            delegate: this
            storage: @storage
        , (err, myDataSource) =>
            if err? then return cb err
            myDataSource.navTitle = dataSource.navTitle + " / " + cellData.label
            $('#navBar').html myDataSource.navTitle
            splitDataSource = new SplitDataSource @yesNoDataSource, myDataSource, 1
            @navigationController.push splitDataSource
            cb null
    
window.Talkshow = Talkshow