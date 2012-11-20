class AccessibilityModeNavCol
    gridSize: 
        columns: 4
        rows: 3
        
    initializeDataSource: (options, cb) ->
        new DataSource
            delegate: this
            grid: options.grid
            level: 1
            nodeId: "navigation_column"
            storage: options.storage
        , (err, @navDataSource) =>
            if err? then return cb err
            options.level = 1
            @makeDataSource options, cb
    
    enteredCell: (dataSource, position, level, nodeId, cellData, cb) ->
        if dataSource is @navDataSource
            console.log "NavCol: #{position.y}"
            if position.y == 0
                @delegate.popToRoot cb
            if position.y == 1
                @delegate.pop cb
        else        
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
        
        new DataSource options, (err, myDataSource) =>
            if err? then return cb err
            splitDataSource = new SplitDataSource @navDataSource, myDataSource, 1
            myDataSource.splitDataSource = splitDataSource
            cb null, splitDataSource

window.AccessibilityModeNavCol = AccessibilityModeNavCol