// Generated by CoffeeScript 1.3.3

/*
  The Storage interface aims to be compatible with all of these
  - localStorage
  - in-memory objects
  - cloud-based database APIs
*/


(function() {
  var LocalStorage, Storage,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Storage = (function() {

    function Storage() {}

    Storage.prototype.get = function(id, cb) {};

    Storage.prototype.save = function(id, doc, cb) {};

    Storage.prototype.remove = function(id, cb) {
      return this.save(id, null, cb);
    };

    return Storage;

  })();

  LocalStorage = (function(_super) {

    __extends(LocalStorage, _super);

    function LocalStorage() {
      return LocalStorage.__super__.constructor.apply(this, arguments);
    }

    LocalStorage.prototype.get = function(id, cb) {
      var doc, s;
      s = localStorage.getItem(id);
      doc = null;
      if (s !== null) {
        doc = JSON.parse(s);
      }
      return window.setTimeout(function() {
        return cb(null, doc);
      }, 1000);
    };

    LocalStorage.prototype.save = function(id, doc, cb) {
      localStorage.setItem(id, doc !== null ? JSON.stringify(doc) : null);
      return window.setTimeout(function() {
        return cb(null);
      }, 1000);
    };

    return LocalStorage;

  })(Storage);

  window.LocalStorage = LocalStorage;

}).call(this);
