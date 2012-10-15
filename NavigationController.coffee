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
    
    # popToRoot: () ->
    #     while @controllerStack.length>1 
    #         @pop()
    
    count: ()-> @controllerStack.length
    currentController: ()-> return _(@controllerStack).last()


window.NavigationController = NavigationController