class Grid
    constructor: (@cols, @rows, @dataSource) ->
        @positions = 
            vert: []
            horiz: []

    reloadFromDataSource: (dataSource, cb) ->
        console.log "Loading data from source"
        if cb is undefined 
            console.trace()
            
        @dataSource = dataSource

        q = async.queue ({td,x,y}, cb) ->
            dataSource.cellForPosition x,y, (err, newTd) ->
                if not err? then td.replaceWith newTd
                cb null
        , 3
            
        q.drain = =>
            for y in [0...@rows]
                @positions.vert.push $("#grid table tr").eq(y).offset().top

            for x in [0...@cols]
                @positions.horiz.push $("#grid table tr").eq(0).find("td").eq(x).offset().left
            cb null
            
        $("#grid").html("<table>")
        for y in [0...@rows]
            tr = $("<tr>")
            $("#grid table").append tr
            for x in [0...@cols]
                td = $ "<td>"
                tr.append td
                q.push {td: td, x:x, y:y}
    
    zoomIntoCell: (x,y,cb) ->
        cb()

        # var cell = $("#grid tr").eq(y).find("td").eq(x);
        # var position = cell.position();
        # var width = cell.width();
        # var height = cell.height();
        # console.log(position, width, height);
        # 
        # $("#grid td").not(cell).animate({
        #     opacity: 0.0
        #   }, 500, function() {
        #       cell.css("position","relative");
        #       //cell.css("left", position.left+"px");
        #       //cell.css("top", position.top+"px");
        #      // cell.css("width", width+"px");
        #       //cell.css("height", height+"px");
        #       
        #       cell.animate({
        #           left: -width
        # 
        #       },4000, cb);
        #       cb();
        #   }
        # );

window.Grid = Grid