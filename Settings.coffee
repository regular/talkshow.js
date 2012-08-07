class Settings
   
    constructor: () ->
        # -- edit mode
        $(".showInEditMode").hide()
        $("#editSwitch").change ()->
            if $(this).attr("checked")
                $(".showInEditMode").show()
            else
                $(".showInEditMode").hide()
        @loadColors()

        if $("#colors li").length is 0
            @addDefaultColors()
            @saveColors()

        $("#colors").append $("<li>")
            .addClass("addButton")
            .html("+")
            .click () =>
                $("<li>")
                    .css("background-color", "rgb(0,0,0)")
                .insertBefore("#colors .addButton")
                @saveColors()
    
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
                .css "background-color", CSSColorFromArray c

    saveColors: () ->        
        colorJSON = "[" + (for element in $("#colors li").not(".addButton")
            s = $(element).css "background-color"
            s = s.replace("rgb(", "[")
            s = s.replace("rgba(", "[")
            s = s.replace(")", "]")
        ).join(",") + "]"
        localStorage.setItem "colors", colorJSON

    loadColors: () ->
        colorJSON = localStorage.getItem "colors"
        if colorJSON?
            colors = JSON.parse colorJSON
            for c in colors
                $("#colors").append $("<li>")
                    .css "background-color", CSSColorFromArray c

window.Settings = Settings