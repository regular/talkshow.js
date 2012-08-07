class NavigationController
    
    constructor: (@grid) ->
        @controllerStack = []
    
    push: (newSource) ->
        @controllerStack.push newSource
        @grid.reloadFromDataSource newSource
    
    pop: () ->
        @controllerStack.pop()
        lastController =_(@controllerStack).last()
        @grid.reloadFromDataSource lastController
    
    popToRoot: () ->
        while @controllerStack.length>1 
            @pop()
    
    count: ()-> @controllerStack.length
    currentController: ()-> return _(@controllerStack).last()


window.NavigationController = NavigationController