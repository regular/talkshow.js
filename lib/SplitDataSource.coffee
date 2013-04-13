class SplitDataSource
    constructor: (@ds1, @ds2, @splitColumn) ->
        
    enterCell: (x, y, cb) ->
        (if x<@splitColumn then @ds1 else @ds2).enterCell x,y,cb
        
    cellForPosition: (x,y, cb) ->
        (if x<@splitColumn then @ds1 else @ds2).cellForPosition x,y, cb
        
module.exports = SplitDataSource