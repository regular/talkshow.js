class ImagePlayer extends ModalDialog

    constructor: (dataURI, cb) ->
        super cb
        @img = $(".imagePlayer img")[0]
        $(".imagePlayer .dialog").show()
        $(@img).attr "src", dataURI
        
        self = this
        $(".imagePlayer .choice").click ->
            switch $(this).attr "type"
                when "back"
                    self.close()
    
    close: ->
        super
        $(".imagePlayer .dialog").hide()
        
window.ImagePlayer = ImagePlayer
    