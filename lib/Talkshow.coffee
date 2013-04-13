ZIPExporter = require './ZIPExporter'
NavigationController = require './NavigationController'
Grid = require './Grid'
{StorageFactory} = require './Storage'
Settings = require './Settings'
keybordInput = require './KeyboardInput'

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
    
    constructor: (@accessibilityMode, cb) ->
        #@storage = new LocalStorage
        new StorageFactory().getBestStorage (err, result) =>
            if err? then return cb err
            @storage = result
            
            {columns, rows} = @accessibilityMode.gridSize
            grid = new Grid columns, rows
            @navigationController = new NavigationController grid
        
            _this = this
            $(".breadcrumbs a").live 'click', (e) ->
                i = $(this).attr 'index'
                console.log "breadcrumb index is #{i}"
                l = $(".breadcrumbs li").length
                popCount = l - i - 1
                if (popCount > 0)
                    console.log "popping #{popCount} levels"
                    _this.pop(popCount)

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
        
                @accessibilityMode.initializeDataSource
                    delegate: this
                    grid: grid
                    storage: @storage
                    nodeId: rootNodeId
                , (err, newDataSource) =>
                    if err? then return cb err
                    newDataSource.navTitle = "Home"
                    @navigationController.push newDataSource, =>
                        ## TODO: refactor this
                        KeyHandlerClass = @accessibilityMode.getKeyHandlerClass()
                        keybordInput.setKeyHandler new KeyHandlerClass(this)
                        @updateBreadcrumbs()
                        cb null, this

    enterCell: (x,y, cb) ->
        @navigationController.currentController().enterCell x,y, cb
   
    updateBreadcrumbs: ->
        $('#navBar').html @navigationController.getBreadCrumbs()
 
    pop: (count, cb) ->
        if count instanceof Function
            cb = count
            count = 1
        if @navigationController.count()>1
            @navigationController.pop count, =>
                @updateBreadcrumbs()
                cb null
        else
            cb null

    popToRoot: (cb) ->
        if @navigationController.count()>1
            @navigationController.popToRoot =>
                @updateBreadcrumbs()                
                cb null
        else
            cb null
    
    enteredCell: (dataSource, position, level, nodeId, cellData, cb) ->
        console.log "enteredCell #{position.x}/#{position.y} level: #{level} nodeId: #{nodeId} of data source #{dataSource.navTitle}"
        @accessibilityMode.makeDataSource
            delegate: this
            grid: @grid
            storage: @storage
            parent: dataSource
            position: position
            level: level
            nodeId: nodeId
            cellData: cellData
        , (err, newDataSource) =>
            if err? then return cb err
            newDataSource.navTitle = cellData?.label or ">"
            
            @navigationController.push newDataSource, =>
                @updateBreadcrumbs()
                cb null
    
module.exports = Talkshow