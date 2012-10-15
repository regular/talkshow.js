class Settings
   
    constructor: (@storage, cb) ->
        $("#settings input.preference").focus ->
            $(this).css("background-color", "yellow")
        self = this
        $("#settings input.preference").change ->
            self.savePreferences (err) =>
                if err?
                    console.log err
                else
                    $(this).css("background-color", "inherit")

        
        @load (err) =>
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

    load: (cb) ->
        async.parallel [
            (cb) => @loadColors(cb)
            (cb) => @loadPreferences(cb)
        ], cb

    loadPreferences: (cb) ->
        @storage.get "preferences", (err, prefs) =>
            if prefs?
                for own key, value of prefs
                    el = $("input##{key}.preference")
                    if el?
                        $(el).attr('value', value)
                        console.log el, value
            cb null, prefs
            
    savePreferences: (cb) ->
        prefs = {}
        $("#settings input.preference").each (i, el) =>
            prefs[$(el).attr('id')] = $(el).attr('value')
        console.log  prefs
        @storage.save "preferences", prefs, cb

    loadColors: (cb) ->
        @storage.get "colors", (err, colors) =>
            if colors?.rgb?
                for c in colors.rgb
                    $("#colors").append $("<li>")
                        .css "background-color", @CSSColorFromArray c
            cb null, colors

window.Settings = Settings