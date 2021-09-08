import insert from table
import JavascriptSafe, Replace from string

-- TODO: Set up the JS file to be downloaded reliably
export CableHTML = [[
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

CableHTML = "<script>#{CableHTML}</script>"

--hook.Add "InitPostEntity", "GMCable_Load_HTML", ->
--    AsyncRead "gm_cable/script.js", "LUA", (fileName, gamePath, status, data) ->
--        if status ~= FSASYNC_OK
--            error fileName, gamePath, status
--
--        CableHTML = "<script>#{data}</script>"

export createHTML = (address, html=CableHTML) ->
    Replace html, "{{{WEBHOOK_ADDRESS}}}", address

export class Cable
    new: (address, port="443", protocol="wss") =>
        @listeners =
            message: {}
            open: {}
            close: {}
            err: {}
            status: {}

        @address = "#{protocol}://#{address}:#{port}"

        with @panel = vgui.Create "DFrame"
            \SetSize 0, 0
            \SetTitle ""
            \SetDeleteOnClose true
            .Paint = () -> nil

        with @html = vgui.Create "DHTML", @panel
            \AddFunction "window", "socketMessage", @\_message
            \AddFunction "window", "socketOpen", @\_open
            \AddFunction "window", "socketClose", @\_close
            \AddFunction "window", "socketError", @\_error
            \AddFunction "window", "socketStatus", @\_status
            \SetAllowLua true
            \SetHTML createHTML @address

    runCbs: (event, ...) =>
        cb(...) for cb in *@listeners[event]

    _message: (msg) =>
        @runCbs "message", msg

    _open: =>
        @runCbs "open"

    _close: =>
        @runCbs "close"

    _error: =>
        @runCbs "err"

    _status: (status) =>
        @runCbs "status", status
        @listeners.status = {}

    on: (event, cb) =>
        insert @listeners[event], cb

    status: (cb) =>
        @on "status", cb
        @html\RunJavascript "gmSocket.getStatus();"

    close: =>
        @html\RunJavascript "gmSocket.close();"

    send: (msg) =>
        safe = JavascriptSafe msg
        @html\RunJavascript "window.socketSend('#{safe}');"
