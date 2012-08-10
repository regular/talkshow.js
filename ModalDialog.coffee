class ModalDialog
    constructor: ->
        KeyboardInput.get().pushModalKeyHandler this
        
    close: ->
        KeyboardInput.get().popModalKeyHandler()
        
    handleKey: (e) =>
        switch String.fromCharCode e.keyCode
            when 'J'
                @leftKeyPressed()
            when 'N'
                @rightKeyPressed()
            when 'M'
                @middleKeyPressed()
                
    leftKeyPressed: ->
    rightKeyPressed: -> @close()
    middleKeyPressed: ->
        
window.ModalDialog = ModalDialog
    