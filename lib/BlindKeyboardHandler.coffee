class BlindKeyboardHandler

    constructor: (delegate) ->
        @delegate = delegate
        @rowCount = $("#grid tr").length
        @colCount = $("#grid tr:eq(1) td").length
            
        # comment this if you don't want the keyboard
        # focus to be visible initially
        @setFocusPosition 0, 0
            
    enterModal:  ->
        @stopTimer()
        
    leaveModal: ->
        if not @isInMenu()
            @startTimer()
    
    isInMenu: (e) ->
        return @focusPosition().left is 0
    
    currentAudioDuration: ->
        if $(".keyboardFocus audio").attr('src')?
            return $(".keyboardFocus audio")[0].duration
        return null

    playNavigationSound: ->
        @stopNavigationSound()
        if $(".keyboardFocus audio").attr('src')?
            $(".keyboardFocus audio").each -> 
                @play()
                setTimeout =>
                    @play()
                , 100
            return true
        return false
        
    stopNavigationSound: ->
        $("#grid audio").each -> @pause()
    
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

    getScannerDelay: ->
        minms = parseInt( $("#scannerDelay").val() or 1000)
        audioms = @currentAudioDuration()
        audioms = if audioms is null then 0 else audioms * 1000
        console.log "getScannerDelay", audioms
        return if minms > audioms then minms else audioms

    startTimer: ->
        @stopTimer()
        timerCallback = =>
            console.log "set timeoutID to  #{@timeoutID}"
            startField = $(".keyboardFocus")[0]
            played = false
            while not played 
                @splitStep 1
                played = @playNavigationSound()
                if startField is $(".keyboardFocus")[0]
                    break
            @timeoutID = window.setTimeout timerCallback, @getScannerDelay()

        @timeoutID = window.setTimeout timerCallback, @getScannerDelay()
        console.log "set timeoutID to  #{@timeoutID}"
        
    stopTimer: ->
        if @timeoutID?
            console.log "STOP timer"
            window.clearTimeout @timeoutID
            @timeoutID = null
        else
            console.log "not stopping, timeoutID is #{@timeoutID}"

    enter: ->
        @stopTimer()
        @stopNavigationSound()
        focusPos = @focusPosition()
        if focusPos?
            @delegate.enterCell focusPos.left, focusPos.top, (err, result) =>
                console.log "set focus pos to 1/0"
                if result? and ("content" of result)
                    # some content is displayed
                else
                    # we entered a new level
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

module.exports = BlindKeyboardHandler