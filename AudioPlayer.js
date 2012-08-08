// Generated by CoffeeScript 1.3.3
(function() {
  var AudioPlayer;

  AudioPlayer = (function() {

    function AudioPlayer(dataURI) {
      var self,
        _this = this;
      this.audio = $(".audioPlayer audio")[0];
      $(".audioPlayer .dialog").show();
      $(this.audio).attr("src", dataURI);
      this.audio.play();
      $(this.audio).bind("ended", function() {
        return _this.close();
      });
      self = this;
      $(".audioPlayer .choice").click(function() {
        switch ($(this).attr("type")) {
          case "pause":
            return self.audio.pause();
          case "back":
            return self.close();
        }
      });
    }

    AudioPlayer.prototype.close = function() {
      this.audio.pause();
      return $(".audioPlayer .dialog").hide();
    };

    return AudioPlayer;

  })();

  window.AudioPlayer = AudioPlayer;

}).call(this);