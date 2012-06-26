function CellFactory(delegate) {
    
    function makeLabel(text) {
        return $("<div>")
            .html(text)
            .addClass("label")
            .click(function() {
                var label = $(this);
                var parent = $(this).parent();
                $("<input>")
                    .val(label.html())
                    .addClass("label")
                    .click(function() {return false;})
                    .keypress(function(e) {
                        if (e.keyCode == 13) {
                            $(this).blur();
                        }
                    })
                    .blur(function() {
                        var newText = $(this).val();
                        if (delegate) {
                            delegate.labelTextChanged(parent, newText)
                        }
                        $(this).remove();
                        label.html(newText);
                        label.show();
                    })
                    .insertAfter(label);
                    
                parent.find("input").focus();
                label.hide();
                return false;
            });
    }
    
    function setBackgroundImage(cell, dataUri) {
        cell.css("background-image", "url(" + dataUri + ")");
    }
    
    function setIcon(image, dataUri) {
        image.attr("src", dataUri);
    }
    
    function handleImage(image, cell, dataUri) {
        image.attr("src", dataUri);
        
        var w = image.width();
        var h = image.height();
        console.log("image dropped:", image.width(), "x", image.height())
        
        // if the image is large, we use it as a cell background
        if (w>256 || h>128) {
            setBackgroundImage(cell, dataUri);
            image.hide();
            if (delegate) {
                delegate.imageChanged(cell, "background", dataUri);
            }            
        } else {
            if (delegate) {
                delegate.imageChanged(cell, "icon", dataUri);
            }
            image.show();
        }
    }
    
    return {
        makeCell: function(data, color) {
            var label = data.label || "n/a";
            var image = $("<img>");
                        
            var cell = $("<td>")
                .append(makeLabel(label))
                .append(image)
                .css("background-color", color)
                
                
            cell.bind("dragenter", function(evt) {
                $(this).addClass("dragTarget");
                evt.stopPropagation();
                evt.preventDefault();
                return true;
            });
            cell.bind("dragleave", function(evt) {
                $(this).removeClass("dragTarget");
                evt.stopPropagation();
                evt.preventDefault();
                return true;
            });
            cell.bind("dragover", function(evt) {
                evt.stopPropagation();
                evt.preventDefault();
                //evt.dataTransfer.dropEffect = 'link';
            });
            cell.bind("drop", function(evt) {
                $(this).removeClass("dragTarget");
                
                var cell = $(this);
                evt.stopPropagation();
                evt.preventDefault();
                var files = evt.originalEvent.dataTransfer.files;
                _(files).each(function(file) {
                    console.log(file.type);
                    console.log(file.mozFullPath);
                    var reader = new FileReader();
                    reader.onloadend = function() {
                        var dataUri = reader.result;
                        handleImage(image, cell, dataUri);
                    };
                    reader.readAsDataURL(file);
                });
            });
            
            if ("background" in data) {
                setBackgroundImage(cell, data.background);
            }
            if ("icon" in data) {
                setIcon(image, data.icon);
            }
                
            return cell;
        }
    };
}