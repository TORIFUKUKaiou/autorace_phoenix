import Player from "./player"

let Hooks = {};

Hooks.Player = {
  url() { return this.el.dataset.url; },
  play() {
    const player = new Player(this.url(), function() {
      this.pushEvent("load-more");
    }.bind(this));

    player.fullScreen();
    player.play();
  },
  mounted() {
    this.play()
  },
  updated() {
    console.log("updated", this.url());
    this.play();
  },
}

export default Hooks;