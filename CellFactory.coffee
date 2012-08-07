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
    
    handleImage: (image, cell, dataUri) ->
        image.attr "src", dataUri
        
        w = image.width()
        h = image.height()
        console.log "image dropped: #{image.width()}x#{image.height()}"
        
        # TODO: this does not really work,
        # probably image loading is async
        
        # if the image is large, we use it as a cell background
        if w>256 or h>128
            @setBackgroundImage cell, dataUri
            image.hide()
            if @delegate
                @delegate.imageChanged cell, "background", dataUri
        
        else
            if @delegate
                @delegate.imageChanged(cell, "icon", dataUri)
            image.show()
    
    makeCell: (data, color) ->
        label = data.label ? "n/a"
        image = $("<img>")
        self = this
        
        cell = $("<td>")
            .append(@makeLabel label)
            .append(image)
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
                    self.handleImage image, cell, dataUri
                reader.readAsDataURL file

        if "background" of data
            @setBackgroundImage cell, data.background
        
        if "icon" of data
            @setIcon image, data.icon
        
        return cell

window.CellFactory = CellFactory