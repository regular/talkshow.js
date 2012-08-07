class NavigationDataSource extends DataSource
 
    constructor: (@grid, @navigationController, level, nodeId, parent, position) ->
        super @grid, level, nodeId, parent, position
        
        @labels = "Start,Zurück,Alarm".split(",")
    
        @actions = [
            ()=> @navigationController.popToRoot()
            ()=> if @navigationController.count() > 1
                    @navigationController.pop()
        ]
    
    colorForCell: (x, y) ->
        if x is 0
            "rgba(240,240,250,0.8)";
        else
            super
    
    labelForCell: (x,y) ->
        if x isnt 0
            super
        else
            if y is 1 and @navigationController.count() < 2
                # this is the root level
                return "()"
            return @labels[y]
    
    enterCell: (x, y) ->
        if x is 0
            console.log "entering menu cell #{x}/#{y}"
            @actions[y]()
        else
            super

    cellForPosition: (x, y) ->
        if x isnt 0
            return super
        return $("<td>")
            .append(
                $("<div>")
                    .addClass("label")
                    .html( @labelForCell x,y )
            )
            .css("background-color", @colorForCell x,y )
            .click ()=> @enterCell x,y

window.NavigationDataSource = NavigationDataSource