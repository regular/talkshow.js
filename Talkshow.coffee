class Talkshow
    
    constructor: ->
        grid = new Grid 4, 2

        @navigationController = new NavigationController grid

        rootNodeId = localStorage.getItem "root"
        console.log "rootNodeId", rootNodeId
        
        myDataSource = new NavigationDataSource grid, 
            @navigationController, 
            1, # level
            rootNodeId

        myDataSource.delegate = this

        @navigationController.push myDataSource

        #scanner = Scanner(grid.positions(), tnis)
        keyboardInput = new KeyboardInput(this)

    enterCell: (x,y) ->
        @navigationController.currentController().enterCell(x,y)
    
    enteredCell: (dataSource, position, level, nodeId) ->
        console.log "enteredCell #{position.x}/#{position.y} level: #{level} nodeId: #{nodeId}"
        myDataSource = new NavigationDataSource @grid, 
            @navigationController, 
            level,
            nodeId,
            dataSource,
            position
        myDataSource.delegate = this
        
        @navigationController.push myDataSource
        
    
window.Talkshow = Talkshow