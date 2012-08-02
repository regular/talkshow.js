class KeyboardInput

    constructor: (delegate) ->
        @delegate = delegate
        @rowCount = $("#grid tr").length
        @colCount = $("#grid tr:eq(1) td").length
        
        $(window).keyup (e) =>
            @keyHandler e
            
    keyHandler: (e) ->
        # console.log(e.keyCode);
        switch e.keyCode
            when 37 # left
                @step -1
                # @move(-1,0);

            when 38 # up
                @move(0,-1);

            when 39 # right
                @step 1
                # @move(1,0);

            when 40 # down
                @move 0,1

            when 13
                @enter()

            when 32
                #scanner.advance();
                
            else
                return true

        return false

    enter: () ->
        focusPos = @focusPosition()
        if focusPos?
            @delegate.enterCell focusPos.left, focusPos.top

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
            x += d; y += dy;
            @setFocusPosition x, y

    step: (d) ->
        if $(".keyboardFocus").length == 0
            # if no cell has the keyboard focus
            # focus on the first cell
            rows = $("#grid tr")
            row = rows.eq(0)
            cells = row.find("td")
            cell = cells.eq(0)
            cell.addClass("keyboardFocus")
        else
            focusPos = @focusPosition()
            x = focusPos.left
            y = focusPos.top
            # console.log(x,y);
            x += d
            if x < 0
                x= @colCount-1
                y--

            if x >= @colCount
                x=0
                y++
        
            if y < 0
                y = @rowCount-1
                x = @colCount-1

            if y >= @rowCount
                x = 0 
                y = 0

            @setFocusPosition x, y

window.KeyboardInput = KeyboardInput