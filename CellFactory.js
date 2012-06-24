function CellFactory() {
    
    return {
        makeCell: function(label, color) {
            var cell = $("<td>")
                .html(label)
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
                        console.log(dataUri)
                        cell.css("background-image", "url(" + dataUri + ")");
                    };
                    reader.readAsDataURL(file);
                });
            });
                
            return cell;
        }
    };
}