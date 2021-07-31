import DPlayer from "dplayer";
import Hls from "hls.js";

class Player {
  constructor(url, ended_handler) {
    this.dp = new DPlayer({
      container: document.getElementById("dplayer"),
      screenshot: true,
      video: {
        url: url,
        type: "customHls",
        customType: {
          customHls: function (video) {
            const hls = new Hls();
            hls.loadSource(video.src);
            hls.attachMedia(video);
          },
        },
      },
    });

    this.dp.on("ended", function() { 
      console.log("ended");
      ended_handler();
    });
    this.dp.on("abort", function() { console.log("abort"); });
    this.dp.on("error", function() { console.log("error"); });
    this.dp.on("canplay", function() { console.log("canplay"); });
    this.dp.on("playing", function() { console.log("playing"); });
  };

  fullScreen() {
    console.log("fullScreen");
    this.dp.fullScreen.request("web");
  }

  play() {
    console.log("play");
    this.dp.play();
  }
}

export default Player;
