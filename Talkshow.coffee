class Talkshow
    
    constructor: ->
        grid = new Grid 4, 2

        @navigationController = new NavigationController grid

        rootNodeId = localStorage.getItem "root"
        console.log "rootNodeId", rootNodeId
        
        myDataSource = new DataSource grid, 
            1, # level
            rootNodeId
        myDataSource.delegate = this

        @yesNoDataSource = new DataSource grid, 
            1, # level
            "yes_no"
            
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
        myDataSource = new DataSource @grid, 
            level,
            nodeId,
            dataSource,
            position
        myDataSource.delegate = this
        
        splitDataSource = new SplitDataSource @yesNoDataSource, myDataSource, 1
        
        @navigationController.push splitDataSource
        
    
window.Talkshow = Talkshow