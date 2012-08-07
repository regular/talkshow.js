class Scanner
    
    constructor: (@positions, @delegate) ->
        $("#vert").css "left", "0px"
        $("#vert").css "top", $("#grid").offset().top - 10 + "px"

        $("#horiz").css "top", $("#grid").offset().top -40 + "px"
        $("#horiz").css "left", $("#grid").offset().left -32 + "px"

        @scannerStates = ["hold", "vert", "horiz"]
        @scannerState = 0

        @animOptions = 
            duration: 5000
            easing: "linear"
            step: (now, fx) =>
                axis = fx.elem.id
                if axis isnt @scannerStates[@scannerState]
                    return
                    
                offsets = @positions[axis]
                klass = "current_" + axis
                
                # find the index of the cell the poihnter points to
                index = 0;
                index++ while (now > offsets[index] and index < offsets.length)
                $("#grid table tr td").removeClass klass
                
                if axis is "horiz"
                    $("#grid table tr td:nth-child(#{index})").addClass klass
                else
                    $("#grid table tr").eq(if index-1>0 then index-1 else 0).find("td").addClass(klass)

    animate: (axis, animOptions) ->
        $('#'+axis).show()
        propNames =
            horiz: "left"
            vert: "top"
    
        value = if axis is "horiz" then  $("#grid").width() else $("#grid").height()
        props = {}
        props[propNames[axis]] = "+=#{value}"

        $('#'+axis).animate props, animOptions

        props[propNames[axis]] = "-=#{value}"

        animOptions2 = _.clone(animOptions)
        #animOptions2.complete = () ->
        #     $("td").removeClass("current_"+axis);
        #     $('#'+axis).hide();

        $('#'+axis).animate props, animOptions2

    advance: () ->
        old = @scannerState

        i = (@scannerState + 1) % @scannerStates.length

        if old isnt 0
            $("#"+@scannerStates[old]).hide()

        if i isnt 0
            @animate @scannerStates[i], animOptions
        else
            # open!
            
            cell = $(".current_vert.current_horiz")
            row = cell.closest("tr")
            x = cell.index()
            y = row.index()
            
            $("td").removeClass("current_vert").removeClass("current_horiz")
            
            @delegate?.enterCell x,y

        @scannerState = i

window.Scanner = Scanner