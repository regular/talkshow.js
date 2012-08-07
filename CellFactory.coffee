class CellFactory 
    constructor: (@delegate) ->
    
    makeLabel: (text) ->
        self = this
        
        return $("<div>").html(text).addClass("label").click ()->
            label = $(this)
            parent = $(this).parent()
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
            )
            .insertAfter(label)
            
            parent.find("input").focus()
            label.hide()
            return false
            
    setBackgroundImage: (cell, dataUri) ->
        cell.css "background-image", "url(#{dataUri})"
    
    setIcon: (image, dataUri) ->
        image.attr "src", dataUri
        image.show()

    setSound: (audio, dataUri) ->
        audio.attr "src", dataUri
        audio.closest("td").find(".iconbar .navigationSound").show()
    
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
                            self.setSound audio, dataUri
                            audio[0].play()
                            self.delegate?.soundChanged(cell, "navigationSound", dataUri)
                        when "sound"
                            audio.closest("td").find(".iconbar .sound").show()
                            self.delegate?.soundChanged(cell, "sound", dataUri)
                        
                
                
            when "image"
                # w = image.width()
                # h = image.height()
                # console.log "image dropped: #{image.width()}x#{image.height()}"
                #         
                # TODO: this does not really work,
                # probably image loading is async
        
                # if the image is large, we use it as a cell background
                # if w>256 or h>128
                #     @setBackgroundImage cell, dataUri
                #     image.hide()
                #     if @delegate
                #         @delegate.imageChanged cell, "background", dataUri
                #         
                # else
                
                @setIcon image, dataUri
                @delegate?.imageChanged(cell, "icon", dataUri)
    
    makeIconBar: (data) ->
        $("<div>")
            .addClass("iconbar")
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
            @setBackgroundImage cell, data.background
        
        if "icon" of data
            @setIcon image, data.icon

        if "navigationSound" of data
            @setSound audio, data.navigationSound
        
        return cell

window.CellFactory = CellFactory