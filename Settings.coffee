class Settings
   
    constructor: (@storage, cb) ->
        @loadColors (err, colors) =>
            if $("#colors li").length is 0
                @addDefaultColors()
                @insertAddButton()
                @saveColors (err, res) =>
                    cb null, this
            else
                @insertAddButton()
                cb null, this
            
    insertAddButton: () ->
        $("#colors").append $("<li>")
            .addClass("addButton")
            .html("+")
            .click () =>
                $("<li>")
                    .css("background-color", "rgb(0,0,0)")
                .insertBefore("#colors .addButton")
                @saveColors (err, res) ->
                    if err? then console.log err
    
    CSSColorFromArray: (c) ->
        "rgb(#{c[0]},#{c[1]},#{c[2]})"

    addDefaultColors: () ->
        console.log "adding default colors"
        colors = [
            [255,255,127]
            [127,127,255]
            [255,40,40]
        ]
    
        for c in colors
            $("#colors").append $("<li>")
                .css "background-color", @CSSColorFromArray c

    saveColors: (cb) ->
        colorJSON = "[" + (for element in $("#colors li").not(".addButton")
            s = $(element).css "background-color"
            s = s.replace("rgb(", "[")
            s = s.replace("rgba(", "[")
            s = s.replace(")", "]")
        ).join(",") + "]"
        @storage.save "colors", {rgb: JSON.parse(colorJSON)}, cb

    loadColors: (cb) ->
        @storage.get "colors", (err, colors) =>
            if colors?.rgb?
                for c in colors.rgb
                    $("#colors").append $("<li>")
                        .css "background-color", @CSSColorFromArray c
            cb err, colors

window.Settings = Settings