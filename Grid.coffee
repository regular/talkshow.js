class Grid
    constructor: (@cols, @rows, @dataSource) ->
        @positions = 
            vert: []
            horiz: []

    reloadFromDataSource: (dataSource) ->
        console.log "Loading data from source"
        @dataSource = dataSource
        
        $("#grid").html("<table>")
        for y in [0...@rows]
            tr = $("<tr>")
            for x in [0...@cols]
                tr.append dataSource.cellForPosition(x,y)
            
            $("#grid table").append tr

        for y in [0...@rows]
            @positions.vert.push $("#grid table tr").eq(y).offset().top

        for x in [0...@cols]
            @positions.horiz.push $("#grid table tr").eq(0).find("td").eq(x).offset().left

    
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