// Generated by CoffeeScript 1.7.1
var decreaseCredibility, downsize, income, increaseCredibility, stockOptions;

increaseCredibility = function(playerIndex, amount) {
  io.connect(window.location.origin).emit("game:alterCredibility", {
    playerIndex: playerIndex,
    amount: amount
  });
  return true;
};

decreaseCredibility = function(playerIndex, amount) {
  io.connect(window.location.origin).emit("game:alterCredibility", {
    playerIndex: playerIndex,
    amount: amount * -1
  });
  return true;
};

income = function(playerIndex) {
  increaseCredibility(playerIndex, 1);
  return true;
};

stockOptions = function() {
  return true;
};

downsize = function() {
  return true;
};
