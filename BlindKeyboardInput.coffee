root = exports ? this # http://stackoverflow.com/questions/4214731/coffeescript-global-variables

# The publicly accessible Singleton fetcher
class root.KeyboardInput
  _instance = undefined # Must be declared here to force the closure on the class
  @get: (args) -> # Must be a static method
    _instance ?= new _BlindKeyboardInput args


class _BlindKeyboardInput

    constructor: (delegate) ->
        @delegate = delegate
        @rowCount = $("#grid tr").length
        @colCount = $("#grid tr:eq(1) td").length
        @modalKeyHandlers = []
        
        $(window).keyup (e) =>
            if @modalKeyHandlers.length isnt 0
                _(@modalKeyHandlers).last()?.handleKey e
            else
                if not isEditMode()
                    @handleKey e
            
        # comment this if you don't want the keyboard
        # focus to be visible initially
        @setFocusPosition 0, 0
            
    pushModalKeyHandler: (kh) ->
        @modalKeyHandlers.push(kh)
        console.log "stopping timer **"
        @stopTimer()
        
    popModalKeyHandler: ->
        @modalKeyHandlers.pop()
        if @modalKeyHandlers.length is 0 and not @isInMenu()
            @startTimer()
    
    isInMenu: (e) ->
        return @focusPosition().left is 0
    
    playNavigationSound: ->
        if $(".keyboardFocus audio").attr('src')?
            $(".keyboardFocus audio").each -> @play()
            return true
        return false
    
    handleKey: (e) =>
        # console.log(e.keyCode);
        # console.dir e
        switch String.fromCharCode e.keyCode
            when 'J'
                if @isInMenu()
                    @setFocusPosition 0, 0
                    @playNavigationSound()
                else
                    @enter()

            when 'N'
                if @isInMenu()
                    @setFocusPosition 0, 1
                    @playNavigationSound()
                else
                    @pop -> null

            when 'M'
                if @isInMenu()
                    @setFocusPosition 1 ,0
                    @playNavigationSound()
                    @startTimer()
                    
                else
                    @setFocusPosition 0,0
                    @stopTimer()

            else 
        
                switch e.keyCode
                    when 37 # left
                        @splitStep -1
                        # @move(-1,0);

                    when 39 # right
                        @splitStep 1
                        # @move(1,0);

                    when 38 # up
                        @move(0,-1);

                    when 40 # down
                        @move 0,1

                    #when 13
                    #    @enter()

                    when 32
                        #scanner.advance();
                
                    else
                        return true

        return false

    getScannerDelay: () ->
        parseInt( $("#scannerDelay").val() or 1000)

    startTimer: ->
        @stopTimer()
        timerCallback = =>
            @timeoutID = window.setTimeout timerCallback, @getScannerDelay()
            startField = $(".keyboardFocus")[0]
            played = false
            while not played 
                @splitStep 1
                played = @playNavigationSound()
                if startField is $(".keyboardFocus")[0]
                    break
        @timeoutID = window.setTimeout timerCallback, @getScannerDelay()
        
    stopTimer: ->
        if @timeoutID?
            console.log "STOP timer"
            window.clearTimeout @timeoutID
            @timeoutID = null

    enter: ->
        @stopTimer()
        focusPos = @focusPosition()
        if focusPos?
            @delegate.enterCell focusPos.left, focusPos.top, (err) =>
                console.log "set focus pos to 1/0"
                @setFocusPosition 1 ,0
                @playNavigationSound()
                @startTimer()

    pop: (cb) ->
        @stopTimer()
        @delegate?.pop =>
            @setFocusPosition 1 ,0
            @playNavigationSound()
            @startTimer()
            cb null

    focusPosition: () ->
        if $(".keyboardFocus").length == 1
            cell = $(".keyboardFocus")
            row = cell.closest("tr")
            x = cell.index()
            y = row.index()

            return {
                left: x
                top: y
            }

        else
            return {
                left: 0
                top: 0
            }

    setFocusPosition: (x,y) ->
        $("#grid td").removeClass("keyboardFocus")
        $("#grid tr").eq(y).find("td").eq(x).addClass("keyboardFocus")

    move: (dx, dy) ->
        if $(".keyboardFocus").length == 0
            # if no cell has the keyboard focus
            # focus on the center cell
            rows = $("#grid tr")
            row = rows.eq(Math.floor(rows.length / 2))
            cells = row.find("td")
            cell = cells.eq(Math.floor(cells.length / 2))
            cell.addClass("keyboardFocus")
        else
            focusPos = @focusPosition()
            x = focusPos.left
            y = focusPos.top
             #console.log(x,y)
            x += dx;
            y += dy;
            
            if x >= @colCount then x = 0
            if x < 0 then x = @colCount-1
            if y >= @rowCount then y = 0
            if y < 0 then y = @rowCount-1
            @setFocusPosition x, y

    step: (d, sx=0, sy=0, ex=@colCount-1, ey=@rowCount-1) ->
        if $(".keyboardFocus").length == 0
            # if no cell has the keyboard focus
            # focus on the first cell
            rows = $("#grid tr")
            row = rows.eq(sy)
            cells = row.find("td")
            cell = cells.eq(sx)
            cell.addClass("keyboardFocus")
        else
            focusPos = @focusPosition()
            x = focusPos.left
            y = focusPos.top

            x += d
            
            if x < sx
                x = ex
                y--

            if x > ex
                x = sx
                y++
        
            if y < sy
                y = ey
                x = ex

            if y > ey
                x = sx
                y = sy

            @setFocusPosition x, y

    splitStep: (d) ->
        if not @isInMenu()
            @step d, 1, 0, @colCount-1, @rowCount-1
        else
            @step d, 0, 0, 0, @rowCount-1
