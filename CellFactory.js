function CellFactory(delegate) {
    
    function makeLabel(text) {
        return $("<div>")
            .html(text)
            .addClass("label")
            .click(function() {
                var label = $(this);
                var parent = $(this).parent();
                $("<input>")
                    .click(function() {return false;})
                    .keypress(function(e) {
                        if (e.keyCode == 13) {
                            $(this).blur();
                        }
                    })
                    .blur(function() {
                        var newText = $(this).val();
                        if (delegate) {
                            delegate.labelTextChanged(newText)
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
    
    function handleImage(image, cell, dataUri) {
        image.attr("src", dataUri);
        
        var w = image.width();
        var h = image.height();
        console.log("image dropped:", image.width(), "x", image.height())
        
        // if the image is large, we use it as a cell background
        if (w>cell.width() || h>128) {
            cell.css("background-image", "url(" + dataUri + ")");
            image.hide();
        } else {
            image.show();
        }
    }
    
    return {
        makeCell: function(label, color) {
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
                        if (delegate) {
                            delegate.imageChanged(dataUri)
                        }
                        handleImage(image, cell, dataUri);
                    };
                    reader.readAsDataURL(file);
                });
            });
                
            return cell;
        }
    };
}