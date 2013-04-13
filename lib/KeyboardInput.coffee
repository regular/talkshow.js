class KeyboardInput

    constructor: ->
        @modalKeyHandlers = []
        @keyHandler = null
        
        $(window).keyup (e) =>
            if @modalKeyHandlers.length isnt 0
                _(@modalKeyHandlers).last()?.handleKey e
            else
                if not isEditMode()
                    @handleKey e
            
        # comment this if you don't want the keyboard
        # focus to be visible initially
        # @setFocusPosition 0, 0
            
    pushModalKeyHandler: (kh) ->
        console.log "pushModalKeyHandler"
        if @modalKeyHandlers.length is 0
            if @keyHandler?
                @keyHandler.enterModal()
        @modalKeyHandlers.push(kh)

        #console.log "stopping timer **"
        #@stopTimer()
        
    popModalKeyHandler: ->
        @modalKeyHandlers.pop()
        if @modalKeyHandlers.length is 0 
            if @keyHandler?
                @keyHandler.leaveModal()

        #if not @isInMenu()
        #    @startTimer()
           
    handleKey: (e) =>
        if @keyHandler?
            @keyHandler.handleKey(e)

    setKeyHandler: (@keyHandler) ->
       
module.exports = new KeyboardInput()