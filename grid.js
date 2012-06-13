function Grid(cols, rows, colorFactory) {
    $("#grid").html("<table>");
    var x, y;
    for(y=0;y<rows;++y) {
        var tr = $("<tr>");
        for(x=0;x<cols;++x) {
            tr.append(
                $("<td>")
                    .html(x + " / " + y)
                    .css("background-color", colorFactory(x,y))
            );
        }
        $("#grid table").append(tr);
    }
    var positions = {
        vert: [],
        horiz: []
    };
    for(y=0;y<rows;++y) {
        positions.vert.push($("#grid table tr").eq(y).offset().top);
    }
    for(x=0;x<cols;++x) {
        positions.horiz.push($("#grid table tr").eq(0).find("td").eq(x).offset().left);
    }
    return {
        positions: function() {return positions;},
    };
}
