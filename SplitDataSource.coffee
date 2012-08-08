class SplitDataSource
    constructor: (@ds1, @ds2, @splitColumn) ->
        
    enterCell: (x, y) ->
        (if x<@splitColumn then @ds1 else @ds2).enterCell x,y
        
    cellForPosition: (x, y) ->
        (if x<@splitColumn then @ds1 else @ds2).cellForPosition x,y
        
window.SplitDataSource = SplitDataSource