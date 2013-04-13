class NavigationController
    
    constructor: (@grid) ->
        @controllerStack = []
    
    push: (newSource, cb) ->
        @controllerStack.push newSource
        @grid.reloadFromDataSource newSource, cb
    
    pop: (cb) ->
        @controllerStack.pop()
        lastController =_(@controllerStack).last()
        @grid.reloadFromDataSource lastController, cb
    
    popToRoot: (cb) ->
        if @controllerStack.length > 1 
            @pop =>
                @popToRoot cb
        else
            cb null
    
    count: ()-> @controllerStack.length
    currentController: ()-> return _(@controllerStack).last()


module.exports = NavigationController