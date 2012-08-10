class AudioPlayer extends ModalDialog

    constructor: (dataURI, cb) ->
        super cb
        @audio = $(".audioPlayer audio")[0]
        $(".audioPlayer .dialog").show()
        $(@audio).attr "src", dataURI
        @audio.play()
        $(@audio).bind "ended", => @close()
        
        self = this
        $(".audioPlayer .choice").click ->
            switch $(this).attr "type"
                when "pause"
                   self.leftKeyPressed()
                   
                when "back"
                    self.close()
    
    leftKeyPressed: ->
        @audio.pause()
                    
    close: ->
        super
        @audio.pause()
        $(".audioPlayer .dialog").hide()
        
window.AudioPlayer = AudioPlayer 