function GenericDataSource(grid, navigationDataSource, navigationController, level, parent, levelId) {
    if (!level) {
        level = 1;
    }
    
    var cells = {};
    var children = {};
    
    if (levelId) {
        cells = JSON.parse(localStorage.getItem("node_" + levelId+"_cells")) || {};
        children = JSON.parse(localStorage.getItem("node_" + levelId+"_children")) || {};
    }
    
    function ensureLevelId() {
        if (!levelId) {
            levelId = window.uniqueId();
            if (parent) {
                parent.delegate.setChild(parent.position, levelId);
            } else {
                console.log("root levelId is", levelId);
                // save root
                localStorage.setItem("root", levelId);
            }
        }
    }
    
    function save(cell, aspect, data) {
        if (aspect === "id") {
            var row = cell.closest("tr");
            var x = cell.index();
            var y = row.index();
            var id = cell.attr("id");
            cells[x+"/"+y] = id;
            console.log("cell ", x,y, "changed id:", id);
            ensureLevelId();
            localStorage.setItem("node_" + levelId+"_cells", JSON.stringify(cells));
        } else {
            var id = cell.attr("id");
            if (!id) {
                id = window.uniqueId();
                cell.attr("id", id)
                save(cell, "id");
            }
            console.log("saving", id, aspect);
            var obj = localStorage.getItem("cell_" + id); 
            if (obj === null) {
                obj = {};
            } else {
                obj = JSON.parse(obj);
            }
            obj[aspect] = data;
            console.log(obj);
            obj = JSON.stringify(obj);
            localStorage.setItem("cell_" + id, obj); 
        }
    }
    
    var delegate = {
        labelTextChanged: function(cell, text) {
            save(cell, "label", text);
        },
        imageChanged: function(cell, role, dataUri) {
            save(cell, role, dataUri);
        },
        cellChanged: function(cell) {
            save(cell, "cell");
        },
        setChild: function(pos, id) {
            children[pos.x+"/"+pos.y] = id;
            ensureLevelId();
            localStorage.setItem("node_" + levelId+"_children", JSON.stringify(children));
            
        }
    };
    
    var factory = CellFactory(delegate);
    
    function colorForCell(x, y) {
        var index = x+y*4 % 6 + 1;
        var color = index.toString(2);
        color = "000".substr(0,3-color.length) + color;
        color = color.replace(/1/g, "255,").replace(/0/g, "112,");
        color += ".3"; // alpha
        color = "rgba(" + color + ")";
        return color;
    }
    
    function cellData(x,y) {
        var ret = {};
        var key = x+"/"+y;
        if (key in cells) {
            var id = cells[key];
            var obj = JSON.parse(localStorage.getItem("cell_" + id)); 
            if (obj) ret = obj;
            ret.id = id;
        }
        if (!("label" in ret)) {
            ret.label = "level " + level + "(#" + levelId + "): " + x + " / " + y;
        }
        return ret;
    }
    
    function labelForCell(x, y) {
        var obj = cellData(x,y);
        return obj.label;
    }
    
    function enterCell(x, y) {
        if (x === 0) {
            return navigationDataSource.enterCell(x, y);
        }
        console.log("entering cell",x,y);
        var nodeId = null;
        if (children) {
            var key = x+"/"+y;
            if (key in children) {
                nodeId = children[key];
            }
        }
        console.log("nodeId", nodeId);
        grid.zoomIntoCell(x, y, function() {
            navigationController.push(
                GenericDataSource(grid, navigationDataSource, navigationController, level + 1, {
                    delegate: delegate, 
                    position:{x:x,y:y}
                }, nodeId)
            );
        });
    }
    
    
    return {
        enterCell: function(x,y) {
            enterCell(x, y);
        },
        cellForPosition: function(x, y) {
            if (x === 0) {
                return navigationDataSource.cellForPosition(x, y);
            }
            
            //var label = labelForCell(x,y);
            var data = cellData(x,y);
            var color = colorForCell(x,y);
            
            var cell = factory.makeCell(data, color);
            
            if ("id" in data) {
                cell.attr("id", data.id);
            }
            
            cell.click(function() {
                enterCell(x, y);
            });
            
            return cell;
        }
    };
}
