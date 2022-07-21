import Player from "./player"

let Hooks = {};

Hooks.Player = {
  play() {
    const player = new Player(function() {
      this.pushEvent("load-more");
    }.bind(this));
  },
  mounted() {
    console.log("mounted");
    this.play()
  },
  updated() {
    console.log("updated");
    this.play();
  },
}

export default Hooks;