[[
var gmSocket = new WebSocket("{{{WEBHOOK_ADDRESS}}}");

gmSocket.onmessage = function(event) {
  window.socketMessage(event.data);
};

gmSocket.onopen = function() {
  window.socketOpen();
};

gmSocket.onclose = function() {
  window.socketClose();
};

gmSocket.onerror = function() {
  window.socketError();
};

gmSocket.getStatus = function() {
  window.socketStatus(gmSocket.readyState);
};

// Call from Lua
window.socketSend = function(data) {
  gmSocket.send(data);
};
]]
