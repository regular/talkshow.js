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
    
    constructor: (cb) ->
        @storage = new LocalStorage
        
        async.parallel [
                (cb) =>
                    setupUIDGenerator @storage, (err) =>
                        if err? then return cb "Failed to initialize UIDGenerator"
                        cb null, null
                (cb) =>
                    @storage.get "root", cb
        ], (err, [ignored, rootDoc]) =>
            if err? then return cb err
            rootNodeId = rootDoc?.value or null
            console.log "rootNodeId", rootNodeId
        
            grid = new Grid 4, 2
            @navigationController = new NavigationController grid

            myDataSource = new DataSource 
                grid: grid
                level: 1, 
                nodeId: rootNodeId
                delegate: this
                storage: @storage

            @yesNoDataSource = new DataSource 
                grid: grid,
                level: 1
                nodeId: "yes_no"
                storage: @storage
    
            splitDataSource = new SplitDataSource @yesNoDataSource, myDataSource, 1

            @navigationController.push splitDataSource

            #scanner = Scanner(grid.positions(), tnis)
            keyboardInput = KeyboardInput.get(this)
            
            cb null

    enterCell: (x,y) ->
        @navigationController.currentController().enterCell(x,y)
    
    pop: ->
        if @navigationController.count()>1
            @navigationController.pop()
    
    enteredCell: (dataSource, position, level, nodeId) ->
        console.log "enteredCell #{position.x}/#{position.y} level: #{level} nodeId: #{nodeId}"
        myDataSource = new DataSource 
            grid: @grid
            level: level
            nodeId: nodeId
            parent: dataSource,
            position: position
            delegate: this
            storage: @storage
        
        splitDataSource = new SplitDataSource @yesNoDataSource, myDataSource, 1
        
        @navigationController.push splitDataSource
        
    
window.Talkshow = Talkshow