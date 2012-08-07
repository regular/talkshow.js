// Generated by CoffeeScript 1.3.3
(function() {
  var CellFactory;

  CellFactory = (function() {

    function CellFactory(delegate) {
      this.delegate = delegate;
    }

    CellFactory.prototype.makeLabel = function(text) {
      var self;
      self = this;
      return $("<div>").html(text).addClass("label").click(function() {
        var label, parent;
        label = $(this);
        parent = $(this).parent();
        $("<input>").val(label.html()).addClass("label").click(function() {
          return false;
        }).keypress(function(e) {
          if (e.keyCode === 13) {
            e.preventDefault();
            e.stopPropagation();
            $(this).blur();
            return false;
          }
        }).blur(function() {
          var newText, _ref;
          newText = $(this).val();
          if ((_ref = self.delegate) != null) {
            _ref.labelTextChanged(parent, newText);
          }
          $(this).remove();
          label.html(newText);
          return label.show();
        }).insertAfter(label);
        parent.find("input").focus();
        label.hide();
        return false;
      });
    };

    CellFactory.prototype.setBackgroundImage = function(cell, dataUri) {
      return cell.css("background-image", "url(" + dataUri + ")");
    };

    CellFactory.prototype.setIcon = function(image, dataUri) {
      image.attr("src", dataUri);
      return image.show();
    };

    CellFactory.prototype.setSound = function(audio, dataUri) {
      audio.attr("src", dataUri);
      return audio.closest("td").find(".iconbar .navigationSound").show();
    };

    CellFactory.prototype.handleDrop = function(image, audio, cell, dataUri, mimeType) {
      var majorType, _ref, _ref1;
      majorType = mimeType.split("/")[0];
      switch (majorType) {
        case "audio":
          this.setSound(audio, dataUri);
          audio[0].play();
          return (_ref = this.delegate) != null ? _ref.soundChanged(cell, "navigationSound", dataUri) : void 0;
        case "image":
          this.setIcon(image, dataUri);
          return (_ref1 = this.delegate) != null ? _ref1.imageChanged(cell, "icon", dataUri) : void 0;
      }
    };

    CellFactory.prototype.makeIconBar = function(data) {
      return $("<div>").addClass("iconbar").append($("<img>").hide().addClass("navigationSound").attr("src", "icons/08-chat@2x.png")).append($("<img>").hide().addClass("sound").attr("src", "icons/65-note@2x.png"));
    };

    CellFactory.prototype.makeCell = function(data, color) {
      var audio, cell, image, label, self, _ref;
      label = (_ref = data.label) != null ? _ref : "n/a";
      image = $("<img>");
      audio = $("<audio>");
      self = this;
      cell = $("<td>").append(this.makeIconBar(data)).append(this.makeLabel(label)).append(audio).append(image).css("background-color", color);
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
        return evt.preventDefault();
      });
      cell.bind("drop", function(evt) {
        var files;
        $(this).removeClass("dragTarget");
        cell = $(this);
        evt.stopPropagation();
        evt.preventDefault();
        files = evt.originalEvent.dataTransfer.files;
        return _(files).each(function(file) {
          var reader;
          console.log("type", file.type);
          console.log("path", file.mozFullPath);
          reader = new FileReader();
          reader.onloadend = function() {
            var dataUri;
            dataUri = reader.result;
            return self.handleDrop(image, audio, cell, dataUri, file.type);
          };
          return reader.readAsDataURL(file);
        });
      });
      if ("background" in data) {
        this.setBackgroundImage(cell, data.background);
      }
      if ("icon" in data) {
        this.setIcon(image, data.icon);
      }
      if ("navigationSound" in data) {
        this.setSound(audio, data.navigationSound);
      }
      return cell;
    };

    return CellFactory;

  })();

  window.CellFactory = CellFactory;

}).call(this);
