class NavigationController
    
    constructor: (@grid) ->
        @controllerStack = []
    
    getBreadCrumbs: ->
        i = 0
        lis = _(@controllerStack).map( (dataSource) ->
            title = dataSource.navTitle or "?"
            "<li><a index=\"#{i++}\">#{title}</a></li>"
        )
        _(['<ui class="breadcrumbs">', lis, '</ui>']).flatten().join('')

    push: (newSource, cb) ->
        @controllerStack.push newSource
        @grid.reloadFromDataSource newSource, cb
    
    pop: (count, cb) ->
        if count instanceof Function
            cb = count
            count = 1
        for i in [0...count]
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