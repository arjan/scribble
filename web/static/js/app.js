
import "phoenix_html";
import {Socket} from "phoenix";


// make sure we have a player id
if (!localStorage.playerId) {
  localStorage.playerId = ('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = crypto.getRandomValues(new Uint8Array(1))[0]%16|0, v = c == 'x' ? r : (r&0x3|0x8);
    return v.toString(16);
  }));
}
let playerId = localStorage.playerId;


// state is an object with 'strokes'; each stroke contains:
// {playerId: {points: [[x,y],..], color: '#ffcccc'}}
function drawBoard(ctx, state) {
  let colors = ['#ffcc00', '#00ffcc', '#ff00cc', '#ffccff'];

  ctx.fillStyle = '#ffffff';
  ctx.clearRect(0, 0, 800, 600);

  ctx.lineWidth = 5;

  var p = 0;
  for (var playerId in state) {
    let strokes = state[playerId];
    strokes.forEach(coordinates => {
      if (!coordinates.length) return;
      ctx.strokeStyle = colors[p % colors.length];
      ctx.beginPath();
      ctx.moveTo(coordinates[0][0], coordinates[0][1]);
      coordinates.forEach(point => ctx.lineTo(point[0], point[1]));
      ctx.stroke();
    });
    p++;
  }
}

function setupGame(boardId) {

  var boardState = {};

  // socket stuff
  let socket = new Socket("/socket", {params: {id: playerId}});
  socket.connect();

  let canvas = document.querySelector('#canvas');
  let ctx = canvas.getContext('2d');
  let draw = () => drawBoard(ctx, boardState);
  let coord = (e) => [e.offsetX, e.offsetY];
  var dirty = false;

  let addNewLine = (playerId, c) => {
    if (!boardState[playerId])
      boardState[playerId] = [];
    boardState[playerId].push([c]);
    dirty = true;
  };
  let addToLine = (playerId, c) => {
    if (!boardState[playerId])
      boardState[playerId] = [[]];
    boardState[playerId][boardState[playerId].length-1].push(c);
    dirty = true;
  };

  let channel = socket.channel("boards:" + boardId, {});

  channel.join()
    .receive("ok", resp => {
      console.log("Joined successfully", resp);
    })
    .receive("error", resp => { console.log("Unable to join", resp); });

  channel
    .on("state", state => {
      console.log('state!', state);
      boardState = state;
      draw();
    });

  channel
    .on("new", payload => {
      if (payload.player == playerId) return;
      addNewLine(payload.playerId, payload.coord);
      draw();
    });

  channel
    .on("add", payload => {
      if (payload.player == playerId) return;
      addToLine(payload.playerId, payload.coord);
      draw();
    });


  // set up drawing listeners
  var drawing = false;

  // add new line
  canvas.addEventListener('mousedown', (e) => {
    addNewLine(playerId, coord(e));
    drawing = true;
    channel.push("new", {coord: coord(e)});
  });
  canvas.addEventListener('touchstart', (e) => {
    addNewLine(playerId, coord(e));
    drawing = true;
    channel.push("new", {coord: coord(e)});
  });

  // add to existing line
  canvas.addEventListener('mousemove', (e) => {
    if (!drawing) return;
    addToLine(playerId, coord(e));
    draw();
    channel.push("add", {coord: coord(e)});
  });
  canvas.addEventListener('touchmove', (e) => {
    if (!drawing) return;
    addToLine(playerId, coord(e));
    draw();
    channel.push("add", {coord: coord(e)});
  });

  // stop drawing
  canvas.addEventListener('mouseup', (e) => {
    drawing = false;
  });
  canvas.addEventListener('touchend', (e) => {
    drawing = false;
  });

  draw();

  var thumbCanvas = document.createElement('canvas');
  thumbCanvas.width = 300;
  thumbCanvas.height = 225;
  var thumbCtx = thumbCanvas.getContext("2d");

  let snapshot = () => {
    if (!dirty) return;
    dirty = false;
    thumbCtx.drawImage(canvas, 0, 0, 300, 225);
    let image = thumbCanvas.toDataURL();
    channel.push("snapshot", {image: image});
  };
  setInterval(snapshot, 1000);
}

let boardId = document.querySelector("#board").getAttribute("data-board-id");
if (boardId) setupGame(boardId);
