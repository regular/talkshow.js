// Generated by CoffeeScript 1.3.3
(function() {
  var DataSource;

  DataSource = (function() {

    function DataSource(options) {
      var cellDelegate, _ref, _ref1, _ref2,
        _this = this;
      this.grid = options.grid, this.level = options.level, this.nodeId = options.nodeId, this.parent = options.parent, this.position = options.position, this.delegate = options.delegate, this.storage = options.storage;
      if ((_ref = this.level) == null) {
        this.level = 1;
      }
      this.cells = {};
      this.children = {};
      if (this.nodeId != null) {
        this.cells = (_ref1 = JSON.parse(localStorage.getItem("node_" + this.nodeId + "_cells"))) != null ? _ref1 : {};
        this.children = (_ref2 = JSON.parse(localStorage.getItem("node_" + this.nodeId + "_children"))) != null ? _ref2 : {};
      }
      cellDelegate = {
        labelTextChanged: function(cell, text, cb) {
          console.log("labelTextChanged", cell, text);
          return _this.save(cell, "label", text, cb);
        },
        contentChanged: function(cell, aspect, dataUri, cb) {
          return _this.save(cell, aspect, dataUri, cb);
        },
        cellChanged: function(cell, cb) {
          return _this.save(cell, "cell", cb);
        }
      };
      this.factory = new CellFactory(cellDelegate);
    }

    DataSource.prototype.setChild = function(pos, id, cb) {
      var _this = this;
      this.children["" + pos.x + "/" + pos.y] = id;
      return this.ensureNodeId(function(err) {
        if (err != null) {
          return cb(err);
        }
        localStorage.setItem("node_" + _this.nodeId + "_children", JSON.stringify(_this.children));
        return cb(null);
      });
    };

    DataSource.prototype.ensureNodeId = function(cb) {
      var _this = this;
      if (!(this.nodeId != null)) {
        return window.uniqueId(function(err, id) {
          if (err) {
            return cb(err);
          }
          _this.nodeId = id;
          if (_this.parent != null) {
            return _this.parent.setChild(_this.position, id, cb);
          } else {
            console.log("root nodeId is " + _this.nodeId);
            return _this.storage.save("root", {
              value: _this.nodeId
            }, cb);
          }
        });
      } else {
        return cb(null);
      }
    };

    DataSource.prototype.setCellId = function(cell, id, cb) {
      var row, x, y,
        _this = this;
      row = cell.closest("tr");
      x = cell.index();
      y = row.index();
      cell.attr("id", id);
      this.cells["" + x + "/" + y] = id;
      console.log("cell " + x + "/" + y + " changed id: " + id);
      return this.ensureNodeId(function(err) {
        if (!(_this.nodeId != null)) {
          alert("No nodeId after ensureNodeId");
        }
        if (err != null) {
          return cb(err);
        }
        localStorage.setItem("node_" + _this.nodeId + "_cells", JSON.stringify(_this.cells));
        return cb(null);
      });
    };

    DataSource.prototype.ensureCellId = function(cell, cb) {
      var id,
        _this = this;
      console.log("ensureCellId");
      id = cell.attr("id");
      if (id != null) {
        return cb(null);
      }
      console.log("calling uniqueId");
      return window.uniqueId(function(err, id) {
        console.log("uniqueId returned " + err + ", " + id);
        if (err != null) {
          return cb(err);
        }
        return _this.setCellId(cell, id, cb);
      });
    };

    DataSource.prototype.save = function(cell, aspect, data, cb) {
      var _this = this;
      return this.ensureCellId(cell, function(err) {
        var id, obj;
        if (err != null) {
          return cb(err);
        }
        id = cell.attr('id');
        console.log("saving " + aspect + " of cell " + id);
        obj = localStorage.getItem("cell_" + id);
        if (obj === null) {
          obj = {};
        } else {
          obj = JSON.parse(obj);
        }
        obj[aspect] = data;
        console.dir(obj);
        obj = JSON.stringify(obj);
        localStorage.setItem("cell_" + id, obj);
        return cb(null);
      });
    };

    DataSource.prototype.colorForCell = function(x, y) {
      var color, index;
      index = x + y * 4 % 6 + 1;
      color = index.toString(2);
      color = "000".substr(0, 3 - color.length) + color;
      color = color.replace(/1/g, "255,").replace(/0/g, "112,");
      color += ".3";
      color = "rgba(" + color + ")";
      return color;
    };

    DataSource.prototype.cellData = function(x, y) {
      var id, key, obj, ret;
      ret = {};
      key = "" + x + "/" + y;
      if (key in this.cells) {
        id = this.cells[key];
        obj = JSON.parse(localStorage.getItem("cell_" + id));
        if (obj != null) {
          ret = obj;
        }
        ret.id = id;
      }
      if (!("label" in ret)) {
        ret.label = "level" + this.level + "(#" + this.nodeId + "): " + x + "/" + y;
      }
      return ret;
    };

    DataSource.prototype.labelForCell = function(x, y) {
      var obj;
      obj = cellData(x, y);
      return obj.label;
    };

    DataSource.prototype.enterCell = function(x, y) {
      var audioPlayer, childNodeId, data, imagePlayer, key, _ref;
      console.log("entering cell " + x + "/" + y);
      childNodeId = null;
      if (this.children) {
        key = "" + x + "/" + y;
        if (key in this.children) {
          childNodeId = this.children[key];
        }
      }
      console.log("nodeId", childNodeId);
      if (childNodeId === null) {
        data = this.cellData(x, y);
        if (data.sound) {
          audioPlayer = new AudioPlayer(data.sound);
          return;
        }
        if (data.photo) {
          imagePlayer = new ImagePlayer(data.photo);
          return;
        }
      }
      return (_ref = this.delegate) != null ? _ref.enteredCell(this, {
        x: x,
        y: y
      }, this.level + 1, childNodeId) : void 0;
    };

    DataSource.prototype.cellForPosition = function(x, y) {
      var cell, color, data,
        _this = this;
      data = this.cellData(x, y);
      color = this.colorForCell(x, y);
      cell = this.factory.makeCell(data, color);
      if ("id" in data) {
        cell.attr("id", data.id);
      }
      cell.click(function() {
        return _this.enterCell(x, y);
      });
      return cell;
    };

    return DataSource;

  })();

  window.DataSource = DataSource;

}).call(this);
