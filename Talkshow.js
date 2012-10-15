// Generated by CoffeeScript 1.3.3
(function() {
  var Talkshow, setupUIDGenerator;

  setupUIDGenerator = function(storage, cb) {
    return storage.get("currId", function(err, doc) {
      var currId;
      currId = (doc != null ? doc.value : void 0) || 0;
      window.uniqueId = function(cb) {
        var ret;
        ret = currId;
        currId++;
        return storage.save("currId", {
          value: currId
        }, function(err) {
          return cb(err, ret);
        });
      };
      return cb(err);
    });
  };

  Talkshow = (function() {

    Talkshow.prototype["export"] = function(exporterName, cb) {
      var exporter;
      exporter = new ZIPExporter;
      return exporter["export"](this.storage, cb);
    };

    function Talkshow(cb) {
      var _this = this;
      new StorageFactory().getBestStorage(function(err, result) {
        var grid;
        if (err != null) {
          return cb(err);
        }
        _this.storage = result;
        grid = new Grid(4, 2);
        _this.navigationController = new NavigationController(grid);
        return async.parallel([
          function(cb) {
            return setupUIDGenerator(_this.storage, function(err) {
              if (err != null) {
                return cb("Failed to initialize UIDGenerator " + err);
              }
              return cb(null, null);
            });
          }, function(cb) {
            return _this.storage.get("root", cb);
          }, function(cb) {
            return new Settings(_this.storage, cb);
          }
        ], function(err, _arg) {
          var ignored, rootDoc, rootNodeId, settings;
          ignored = _arg[0], rootDoc = _arg[1], settings = _arg[2];
          if (err != null) {
            return cb(err);
          }
          rootNodeId = (rootDoc != null ? rootDoc.value : void 0) || null;
          console.log("rootNodeId", rootNodeId);
          return async.parallel([
            function(cb) {
              return new DataSource({
                grid: grid,
                level: 1,
                nodeId: rootNodeId,
                delegate: _this,
                storage: _this.storage
              }, cb);
            }, function(cb) {
              return new DataSource({
                grid: grid,
                level: 1,
                nodeId: "yes_no",
                storage: _this.storage
              }, cb);
            }
          ], function(err, results) {
            var myDataSource, splitDataSource;
            if (err != null) {
              return cb(err);
            }
            myDataSource = results[0], _this.yesNoDataSource = results[1];
            myDataSource.navTitle = ">";
            splitDataSource = new SplitDataSource(_this.yesNoDataSource, myDataSource, 1);
            return _this.navigationController.push(splitDataSource, function() {
              var keyboardInput;
              keyboardInput = KeyboardInput.get(_this);
              return cb(null, _this);
            });
          });
        });
      });
    }

    Talkshow.prototype.enterCell = function(x, y, cb) {
      return this.navigationController.currentController().enterCell(x, y, cb);
    };

    Talkshow.prototype.pop = function(cb) {
      var _this = this;
      if (this.navigationController.count() > 1) {
        return this.navigationController.pop(function() {
          var myDataSource;
          myDataSource = _this.navigationController.currentController().ds2;
          $('#navBar').html(myDataSource.navTitle);
          return cb(null);
        });
      } else {
        return cb(null);
      }
    };

    Talkshow.prototype.enteredCell = function(dataSource, position, level, nodeId, cellData, cb) {
      var _this = this;
      console.log("enteredCell " + position.x + "/" + position.y + " level: " + level + " nodeId: " + nodeId);
      return new DataSource({
        grid: this.grid,
        level: level,
        nodeId: nodeId,
        parent: dataSource,
        position: position,
        delegate: this,
        storage: this.storage
      }, function(err, myDataSource) {
        var splitDataSource;
        if (err != null) {
          return cb(err);
        }
        myDataSource.navTitle = dataSource.navTitle + " / " + cellData.label;
        $('#navBar').html(myDataSource.navTitle);
        splitDataSource = new SplitDataSource(_this.yesNoDataSource, myDataSource, 1);
        return _this.navigationController.push(splitDataSource, function() {
          return cb(null);
        });
      });
    };

    return Talkshow;

  })();

  window.Talkshow = Talkshow;

}).call(this);
