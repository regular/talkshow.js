function GenericDataSource(grid, navigationDataSource, navigationController, level) {
    if (!level) {
        level = 1;
    }
    return {
        colorForCell: function(x, y) {
            if (x === 0) {
                return navigationDataSource.colorForCell(x, y);
            }
            var index = x+y*4 % 6 + 1;
            var color = index.toString(2);
            color = "000".substr(0,3-color.length) + color;
            color = color.replace(/1/g, "255,").replace(/0/g, "112,");
            color += ".3"; // alpha
            color = "rgba(" + color + ")";
            return color;
        },
        labelForCell: function(x, y) {
            if (x === 0) {
                return navigationDataSource.labelForCell(x, y);
            }
            return "level " + level + ":" + x + " / " + y;
        },
        enterCell: function(x, y) {
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
    };
}
