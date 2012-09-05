class AudioPlayer extends ModalDialog

    constructor: (dataURI, cb) ->
        super '.audioPlayer .dialog', cb
        
        @audio = $(".audioPlayer audio")[0]
        $(@audio).attr "src", dataURI
        @audio.play()
        $(@audio).bind "ended", => @close()
        
    handleButton: (name) ->
        switch name
            when "pause"
               @leftKeyPressed()
               
            when "back"
                @close()
    
    leftKeyPressed: ->
        @audio.pause()
                    
    close: ->
        super
        @audio.pause()
        
window.AudioPlayer = AudioPlayer 