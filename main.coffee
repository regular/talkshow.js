Talkshow = require './Talkshow'
AccessibilityModeNavCol = require './AccessibilityModeNavCol'
AccessibilityModeShabanaj = require './AccessibilityModeShabanaj'
AccessibilityModePlain = require './AccessibilityModePlain'

$ ->

    getQuery = ->
        result = {}
        queryString = location.search.substring(1)
        re = /([^&=]+)=([^&]*)/g

        while m = re.exec(queryString)
            result[decodeURIComponent(m[1])] = decodeURIComponent(m[2])

        return result

    $("#editSwitch").change ->
        if $(this).attr("checked")
            $("body").addClass("editMode")
        else
            $("body").removeClass("editMode")

    window.isEditMode = ->
        return $('.editMode').length isnt 0

    $("#export").click ->
        $("#export").hide()
        talkshow.export "zip", (err, link)->
            console.log "export callback triggered"
            $("#export").show()
            location.href = link
        
    $(".dialog").hide()
    
    query = getQuery()
    accessibilityMode = new AccessibilityModeNavCol()
    
    if query.mode is "shabanaj"
        accessibilityMode = new AccessibilityModeShabanaj()
    else if query.mode is "plain"
        accessibilityMode = new AccessibilityModePlain()
    
    talkshow = new Talkshow accessibilityMode, (err) ->
        if err
            $("body").html "Failed to initialize Talkshow: #{err}"
        else
            $('#storageIdentifier').html talkshow.storage.toString()