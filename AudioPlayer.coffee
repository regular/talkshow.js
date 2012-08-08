class AudioPlayer

    constructor: (dataURI) ->
        @audio = $(".audioPlayer audio")[0]
        $(".audioPlayer .dialog").show()
        $(@audio).attr "src", dataURI
        @audio.play()
        $(@audio).bind "ended", => @close()
        
        self = this
        $(".audioPlayer .choice").click ->
            switch $(this).attr "type"
                when "pause"
                   self.audio.pause()
                   
                when "back"
                    self.close()
                    
    close: ->
        @audio.pause()
        $(".audioPlayer .dialog").hide()
        
window.AudioPlayer = AudioPlayer 