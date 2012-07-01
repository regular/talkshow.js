function CSSColorFromArray(c) {
    return "rgb("+ c[0] + "," + c[1] + "," + c[2] + ")";
}

function addDefaultColors() {
    console.log("adding default colors");
    var colors = [
        [255,255,127],
        [127,127,255],
        [255,40,40],
    ];
    for(var i=0; i<colors.length; ++i) {
        var c = colors[i];
        $("#colors").append(
            $("<li>").css("background-color", CSSColorFromArray(c))
        );
    }
}

function saveColors() {
    var colorJSON = "[" + _($("#colors li").not(".addButton")).map(function(e) {
        var s = $(e).css("background-color");
        s = s.replace("rgb(", "[");
        s = s.replace("rgba(", "[");
        s = s.replace(")", "]");
        return s;
    }).join(",") + "]";
    localStorage.setItem("colors", colorJSON);
}

function loadColors() {
    var colorJSON = localStorage.getItem("colors");
    if (colorJSON) {
        var colors = JSON.parse(colorJSON);
        for(var i=0; i<colors.length; ++i) {
            var c = colors[i];
            $("#colors").append(
                $("<li>").css("background-color", CSSColorFromArray(c))
            );
        }
    }
}

$(function() {
    // -- edit mode
    $(".showInEditMode").hide();
    $("#editSwitch").change(function() {
        if ($(this).attr("checked")) {
            $(".showInEditMode").show();
        } else {
            $(".showInEditMode").hide();
        }
    });
    loadColors();
    if ($("#colors li").length == 0) {
        addDefaultColors();
        saveColors();
    }
    $("#colors").append(
        $("<li>")
            .addClass("addButton")
            .html("+")
            .click(function() {
                $("<li>")
                    .css("background-color", "rgb(0,0,0)")
                .insertBefore("#colors .addButton");
                saveColors();
            })
    );
});