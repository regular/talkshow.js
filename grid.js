function Grid(cols, rows, dataSource) {
    var positions = {
        vert: [],
        horiz: []
    };

    function reloadFromSource(dataSource) {
        $("#grid").html("<table>");
        var x, y;
        for(y=0;y<rows;++y) {
            var tr = $("<tr>");
            for(x=0;x<cols;++x) {
                (function(x,y) {
                    tr.append(
                        $("<td>")
                            .html(dataSource.labelForCell(x,y))
                            .css("background-color", dataSource.colorForCell(x,y))
                            .click(function() {
                                dataSource.enterCell(x, y);
                            })
                    );
                })(x,y);
            }
            $("#grid table").append(tr);
        }
        for(y=0;y<rows;++y) {
            positions.vert.push($("#grid table tr").eq(y).offset().top);
        }
        for(x=0;x<cols;++x) {
            positions.horiz.push($("#grid table tr").eq(0).find("td").eq(x).offset().left);
        }
    }
    if (dataSource) {
        reloadFromSource(dataSource);        
    }

    return {
        positions: function() {return positions;},
        reloadFromDataSource: reloadFromSource
    };
}
