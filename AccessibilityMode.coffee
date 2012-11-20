class AccessibilityMode
    
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
    
    makeDataSource: (options, cb) ->
        new DataSource options, (err, myDataSource) =>
            if err? then return cb err
            myDataSource.navTitle = ">"
            if options.parent?.navTitle? and options.cellData?.label?
                myDataSource.navTitle = options.parent.navTitle + " / " + options.cellData.label
            $('#navBar').html myDataSource.navTitle
            splitDataSource = new SplitDataSource @yesNoDataSource, myDataSource, 1
            cb null, splitDataSource

window.AccessibilityMode = AccessibilityMode