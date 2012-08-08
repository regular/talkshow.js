class BlindKeyboardInput

    constructor: (delegate) ->
        @delegate = delegate
        @rowCount = $("#grid tr").length
        @colCount = $("#grid tr:eq(1) td").length
        
        $(window).keyup (e) =>
            @keyHandler e
            
        # comment this if you don't want the keyboard
        # focus to be visible initially
        @setFocusPosition 0, 0
    
    isInMenu: (e) ->
        return @focusPosition().left is 0
    
    playNavigationSound: ->
        $(".keyboardFocus audio").each ()-> @play()
    
    keyHandler: (e) =>
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
                    @pop()

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

                    when 13
                        @enter()

                    when 32
                        #scanner.advance();
                
                    else
                        return true

        return false

    startTimer: ->
        timerCallback = ()=>
            @timeoutID = window.setTimeout timerCallback, 1000
            @splitStep 1
            @playNavigationSound()
        @timeoutID = window.setTimeout timerCallback, 1000
        
    stopTimer: ->
        window.clearTimeout @timeoutID

    enter: ->
        @stopTimer()
        focusPos = @focusPosition()
        if focusPos?
            @delegate?.enterCell focusPos.left, focusPos.top
            @setFocusPosition 1 ,0
            @playNavigationSound()
            @startTimer()
            
    pop: ->
        @stopTimer()
        @delegate?.pop()
        @setFocusPosition 1 ,0
        @playNavigationSound()
        @startTimer()

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
            return null

    setFocusPosition: (x,y) ->
        $("td").removeClass("keyboardFocus")
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

window.BlindKeyboardInput = BlindKeyboardInput