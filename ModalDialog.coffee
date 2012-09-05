class ModalDialog
    constructor: (selector, @callback)->
        KeyboardInput.get().pushModalKeyHandler this
        
        @dialogElement = $ selector
        @dialogElement.show()
        self = this
        @dialogElement.find('.choice').unbind('click').click ->
            self.handleButton $(this).attr "type"

    handleButton: (name) ->
        alert name
        
    close: ->
        @dialogElement.hide()
        KeyboardInput.get().popModalKeyHandler()
        @callback(null) if @callback?
        
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
    