function NavigationController(grid) {
    var controllerStack = [];
    
    function push(newController) {
        controllerStack.push(newController);
        grid.reloadFromDataSource(newController);
    }
    
    function pop() {
        controllerStack.pop();
        var lastController = _(controllerStack).last();
        grid.reloadFromDataSource(lastController);
    }
    
    function popToRoot() {
        while(controllerStack.length>1) {
            pop();
        }
    }
    
    return {
        push: push,
        pop: pop,
        popToRoot: popToRoot,
        count: function() {return controllerStack.length;}
    };
}

function NavigationDataSource(navigationController) {
    var labels = "Start,Zurück,Alarm,Einstellungen".split(",");
    
    var actions = [
        function() { navigationController.popToRoot(); },
        function() { 
            if (navigationController.count() > 1) {
                navigationController.pop();
            }
        },
        function() {}
    ];
    
    return {
        colorForCell: function(x, y) {
            return "rgba(240,240,250,0.8)";
        },
        labelForCell: function(x,y) {
            if (y == 1 && navigationController.count() < 2) {
                // this is the root level
                return "()";
            }
            return labels[y];
        },
        enterCell: function(x, y) {
            console.log("entering menu cell",x,y);
            actions[y]();
        }
    };
}
