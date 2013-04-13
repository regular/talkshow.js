DataSource = require './DataSource'
SplitDataSource = require './SplitDataSource'

class AccessibilityModeShabanaj
    gridSize: 
        columns: 4
        rows: 2
        
    getKeyHandlerClass: ->
        return require './BlindKeyboardHandler'


    initializeDataSource: (options, cb) ->
        new DataSource 
            grid: options.grid
            level: 1
            nodeId: "yes_no"
            storage: options.storage
        , (err, @yesNoDataSource) =>
            if err? then return cb err
            options.level = 1
            @makeDataSource options, cb
    
    enteredCell: (dataSource, position, level, nodeId, cellData, cb) ->
        dataSource = dataSource.splitDataSource
        @delegate?.enteredCell dataSource, position, level, nodeId, cellData, cb
    
    makeDataSource: (options, cb) ->
        # we proxy enteredCell calls to correct the sender
        @delegate = options.delegate
        options.delegate = this
        
        # parent is a split data source. We want the 
        # left datasource of the split data source
        if options.parent?
            options.parent = options.parent.ds2
        
        options.userIsBlind = true
        new DataSource options, (err, myDataSource) =>
            if err? then return cb err
            splitDataSource = new SplitDataSource @yesNoDataSource, myDataSource, 1
            myDataSource.splitDataSource = splitDataSource
            cb null, splitDataSource

module.exports = AccessibilityModeShabanaj