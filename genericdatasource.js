function GenericDataSource(grid, navigationDataSource, navigationController, level) {
    if (!level) {
        level = 1;
    }
    
    function colorForCell(x, y) {
        var index = x+y*4 % 6 + 1;
        var color = index.toString(2);
        color = "000".substr(0,3-color.length) + color;
        color = color.replace(/1/g, "255,").replace(/0/g, "112,");
        color += ".3"; // alpha
        color = "rgba(" + color + ")";
        return color;
    }
    
    function labelForCell(x, y) {
        return "level " + level + ":" + x + " / " + y;
    }
    
    function enterCell(x, y) {
        if (x === 0) {
            return navigationDataSource.enterCell(x, y);
        }
        console.log("entering cell",x,y);
        grid.zoomIntoCell(x, y, function() {
            navigationController.push(
                GenericDataSource(grid, navigationDataSource, navigationController, level + 1)
            );
        });
    }
    
    
    return {
        cellForPosition: function(x, y) {
            if (x === 0) {
                return navigationDataSource.cellForPosition(x, y);
            }
            
            var label = labelForCell(x,y);
            var color = colorForCell(x,y);
            
            return $("<td>")
                .html(label)
                .css("background-color", color)
                .click(function() {
                    enterCell(x, y);
                });
        }
    };
}
