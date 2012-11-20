class AccessibilityModePlain
    gridSize:
        columns: 3
        rows: 3
    
    initializeDataSource: (options, cb) ->
        @makeDataSource options, cb
        
    makeDataSource: (options, cb) ->
        new DataSource options, cb

window.AccessibilityModePlain = AccessibilityModePlain