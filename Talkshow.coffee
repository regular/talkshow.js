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
        
        setupUIDGenerator @storage, (err) =>
            if err? then return cb "Failed to initialize UIDGenerator"
        
            grid = new Grid 4, 2
            @navigationController = new NavigationController grid

            rootNodeId = localStorage.getItem "root"
            console.log "rootNodeId", rootNodeId

            myDataSource = new DataSource 
                grid: grid
                level: 1, 
                nodeId: rootNodeId
                delegate: this

            @yesNoDataSource = new DataSource 
                grid: grid,
                level: 1
                nodeId: "yes_no"
    
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
        
        splitDataSource = new SplitDataSource @yesNoDataSource, myDataSource, 1
        
        @navigationController.push splitDataSource
        
    
window.Talkshow = Talkshow