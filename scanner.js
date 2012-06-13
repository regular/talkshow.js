function Scanner(positions) {
    $("#vert").css("left", "0px");
    $("#vert").css("top", $("#grid").offset().top - 10 + "px");

    $("#horiz").css("top", $("#grid").offset().top -40 + "px");
    $("#horiz").css("left", $("#grid").offset().left -32 + "px");

    var scannerStates = ["hold", "vert", "horiz"];
    var scannerState = 0;

    var animOptions = {
        duration: 5000,
        easing: "linear",
        step: function(now, fx) {
            var axis = fx.elem.id;
            if (axis !== scannerStates[scannerState]) {
                return;
            }
            var offsets = positions[axis];
            var klass = "current_" + axis;
            // find the index of the cell the poihnter points to
            var index = 0;
            while (now > offsets[index] && index < offsets.length) index++;
            $("#grid table tr td").removeClass(klass);
            if (axis === "horiz") {
                $("#grid table tr td:nth-child("+index+")").addClass(klass);
            } else {
                $("#grid table tr").eq(index-1>0?index-1:0).find("td").addClass(klass);

            }
        }
    };

    function animate(axis, animOptions) {
        $('#'+axis).show();
        var propNames = {
            horiz: "left",
            vert: "top"
        }
        var value = axis === "horiz" ?  
            $("#grid").width() : $("#grid").height();
        props = {};
        props[propNames[axis]] = "+=" + value;

        $('#'+axis).animate(props, animOptions);

        props[propNames[axis]] = "-=" + value;

        var animOptions2 = _.clone(animOptions);
        animOptions2.complete = function() {
            //$("td").removeClass("current_"+axis);
            //$('#'+axis).hide();
        };

        $('#'+axis).animate(props, animOptions2);
    }

    function advanceState() {
        var old = scannerState;

        var i = (scannerState + 1) % scannerStates.length;

        if (old !== 0) {
            $("#"+scannerStates[old]).hide();
        } else {
        }
        if (i !== 0) {
            animate(scannerStates[i], animOptions);
        } else {
            $("td").removeClass("current_vert");
            $("td").removeClass("current_horiz");
            // open!
        }
        scannerState = i;
    }
    return {
        advance: advanceState
    };
}
