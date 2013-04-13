keyboardInput = require './KeyboardInput'

class ModalDialog
    constructor: (selector, @callback)->
        keyboardInput.pushModalKeyHandler this
        
        @dialogElement = $ selector
        @dialogElement.show()
        self = this
        @dialogElement.find('.choice').unbind('click').click ->
            self.handleButton $(this).attr "type"

    handleButton: (name) ->
        @callback(name) if @callback
        @close()
        
    close: ->
        @dialogElement.hide()
        keyboardInput.popModalKeyHandler()
        @callback(null) if @callback
        
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
        
module.exports = ModalDialog
    