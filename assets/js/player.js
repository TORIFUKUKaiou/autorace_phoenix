import fluidPlayer from "fluid-player";

class Player {
  constructor(ended_handler) {
    this.player = fluidPlayer(
      'video-id',	{
      "layoutControls": {
        "controlBar": {
        "autoHideTimeout": 3,
        "animated": true,
        "autoHide": true
      },
      "htmlOnPauseBlock": {
        "html": null,
        "height": null,
        "width": null
      },
      "autoPlay": true,
      "mute": false,
      "allowTheatre": true,
      "playPauseAnimation": true,
      "playbackRateEnabled": true,
      "allowDownload": false,
      "playButtonShowing": false,
      "fillToContainer": true,
      "posterImage": ""
      },
      "vastOptions": {
        "adList": [],
        "adCTAText": false,
        "adCTATextPosition": ""
      }
    });

    this.player.on('play', function() {
      console.log('Video is playing');
    });

    this.player.on("ended", function() {
      console.log("ended");
      ended_handler();
    });
  };
}

export default Player;