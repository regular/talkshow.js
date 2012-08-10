class CellFactory 
    constructor: (@delegate) ->
    
    makeLabel: (text) ->
        self = this
        
        return $("<div>").html(text).addClass("label").click ()->
            label = $(this)
            parent = $(this).parent()
            KeyboardInput.get().pushModalKeyHandler null
            $("<input>").val(label.html()).addClass("label")
            .click( ()-> 
                return false
            ).keypress( (e)->
                if e.keyCode is 13
                    e.preventDefault()
                    e.stopPropagation()
                    $(this).blur()
                    return false
            ).blur( ()->
                newText = $(this).val()
                self.delegate?.labelTextChanged(parent, newText)
                $(this).remove()
                label.html(newText)
                label.show()
                KeyboardInput.get().popModalKeyHandler()
            )
            .insertAfter(label)
            
            parent.find("input").focus()
            label.hide()
            return false
            
    setBackgroundImage: (image, dataUri) ->
        cell = $(image).closest("td")
        cell.css "background-image", "url(#{dataUri})"
        image.hide()
    
    setIcon: (image, dataUri) ->
        image.attr "src", dataUri
        image.show()

    setNavigationSound: (audio, dataUri) ->
        audio.attr "src", dataUri
        audio.closest("td").find(".iconbar .navigationSound").show()

    setSound: (audio, dataUri) ->
        audio.closest("td").find(".iconbar .sound").show()

    setPhoto: (audio, dataUri) ->
        audio.closest("td").find(".iconbar .photo").show()

    handleDrop: (image, audio, cell, dataUri, mimeType) ->
        majorType = mimeType.split("/")[0]
        
        switch majorType
            when "audio"
                self = this
                $(".soundDropped .dialog").show()
                $(".dialog .choice").click ->
                    $(".soundDropped .dialog").hide()
                    switch $(this).attr "type"
                        when "navigationSound"
                            self.setNavigationSound audio, dataUri
                            audio[0].play()
                            self.delegate?.soundChanged(cell, "navigationSound", dataUri)
                        when "sound"
                            self.setSound audio, dataUri
                            self.delegate?.soundChanged(cell, "sound", dataUri)
            
            when "image"
                self = this
                $(".imageDropped .dialog").show()
                $(".dialog .choice").click ->
                    $(".imageDropped .dialog").hide()
                    switch $(this).attr "type"
                        when "icon"
                            self.setIcon image, dataUri
                            self.delegate?.imageChanged(cell, "icon", dataUri)
                        when "background"
                            self.setBackgroundImage image, dataUri
                            self.delegate?.imageChanged(cell, "background", dataUri)
                        when "photo"
                            self.setPhoto image, dataUri
                            self.delegate?.imageChanged(cell, "photo", dataUri)
            
    
    makeIconBar: (data) ->
        $("<div>")
            .addClass("iconbar")
            .append($("<img>").hide().addClass("photo").attr "src", "icons/86-camera@2x.png")
            .append($("<img>").hide().addClass("navigationSound").attr "src", "icons/08-chat@2x.png")
            .append($("<img>").hide().addClass("sound").attr "src", "icons/65-note@2x.png")
        
    makeCell: (data, color) ->
        label = data.label ? "n/a"
        image = $("<img>")
        audio = $("<audio>")
        self = this
        
        cell = $("<td>")
            .append(@makeIconBar data)
            .append(audio)
            .append(image)
            .append(@makeLabel label)
            .css("background-color", color)
                
        cell.bind "dragenter", (evt) ->
            $(this).addClass("dragTarget")
            evt.stopPropagation()
            evt.preventDefault()
            return true
        
        cell.bind "dragleave", (evt) ->
            $(this).removeClass("dragTarget")
            evt.stopPropagation()
            evt.preventDefault()
            return true
        
        cell.bind "dragover", (evt) ->
            evt.stopPropagation()
            evt.preventDefault()
        
        cell.bind "drop", (evt)->
            $(this).removeClass("dragTarget")
        
            cell = $(this)
            evt.stopPropagation()
            evt.preventDefault()
            files = evt.originalEvent.dataTransfer.files
            _(files).each (file) ->
                console.log "type", file.type
                console.log "path", file.mozFullPath
                reader = new FileReader()
                reader.onloadend = () ->
                    dataUri = reader.result
                    self.handleDrop image, audio, cell, dataUri, file.type
                reader.readAsDataURL file

        if "background" of data
            @setBackgroundImage image, data.background
        
        if "icon" of data
            @setIcon image, data.icon

        if "sound" of data
            @setSound audio, data.sound

        if "photo" of data
            @setPhoto image, data.photo

        if "navigationSound" of data
            @setNavigationSound audio, data.navigationSound
        
        return cell

window.CellFactory = CellFactory