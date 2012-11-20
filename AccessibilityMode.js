// Generated by CoffeeScript 1.3.3
(function() {
  var AccessibilityMode;

  AccessibilityMode = (function() {

    function AccessibilityMode() {}

    AccessibilityMode.prototype.initializeDataSource = function(options, cb) {
      var _this = this;
      return new DataSource({
        grid: options.grid,
        level: 1,
        nodeId: "yes_no",
        storage: options.storage
      }, function(err, yesNoDataSource) {
        _this.yesNoDataSource = yesNoDataSource;
        if (err != null) {
          return cb(err);
        }
        options.level = 1;
        return _this.makeDataSource(options, cb);
      });
    };

    AccessibilityMode.prototype.enteredCell = function(dataSource, position, level, nodeId, cellData, cb) {
      var _ref;
      dataSource = dataSource.splitDataSource;
      return (_ref = this.delegate) != null ? _ref.enteredCell(dataSource, position, level, nodeId, cellData, cb) : void 0;
    };

    AccessibilityMode.prototype.makeDataSource = function(options, cb) {
      var _this = this;
      this.delegate = options.delegate;
      options.delegate = this;
      if (options.parent != null) {
        options.parent = options.parent.ds2;
      }
      return new DataSource(options, function(err, myDataSource) {
        var splitDataSource;
        if (err != null) {
          return cb(err);
        }
        splitDataSource = new SplitDataSource(_this.yesNoDataSource, myDataSource, 1);
        myDataSource.splitDataSource = splitDataSource;
        return cb(null, splitDataSource);
      });
    };

    return AccessibilityMode;

  })();

  window.AccessibilityMode = AccessibilityMode;

}).call(this);
