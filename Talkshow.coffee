class Talkshow
    
    constructor: ->
        grid = new Grid 4, 2

        @navigationController = new NavigationController grid
        
        window.uniqueId = do ->
            currId = localStorage.getItem "currId"
            currId ?= 0
            
            return ->
                ret = currId
                currId++
                localStorage.setItem "currId", currId
                return ret

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