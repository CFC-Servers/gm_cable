import insert from table
import AsyncRead from file
import JavascriptSafe, Replace from string
import TableToJSON from util

local HTML
createHTML = (address, html=HTML) ->
    Replace html, "{{{WEBHOOK_ADDRESS}}}", address

export class Cable
    new: (address, port="443", secure=true) =>
        @listeners =
            message: {}
            open: {}
            close: {}
            err: {}
            status: {}

        protocol = secure and "wss" or "ws"
        @address = "#{protocol}://#{address}:#{port}"

    _connect: =>
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

    _runCbs: (event, ...) =>
        cb(...) for cb in *@listeners[event]

    _message: (msg) =>
        @_runCbs "message", msg

    _open: =>
        @_runCbs "open"

    _close: =>
        @_runCbs "close"

    _error: =>
        @_runCbs "err"

    _status: (status) =>
        @_runCbs "status", status
        @listeners.status = {}

    on: (cable, event) ->
        call: (cb) =>
            insert cable.listeners[event], cb

    Connect: => @_connect!

    Close: =>
        @html\RunJavascript "gmSocket.close();"
        timer.Simple 0, -> @panel\Close!

    Status: (cb) =>
        @on "status", cb
        @html\RunJavascript "gmSocket.getStatus();"

    SendMessage: (msg) =>
        safe = JavascriptSafe msg
        @html\RunJavascript "window.socketSend('#{safe}');"

    SendData: (data) =>
        safe = JavascriptSafe TableToJSON data
        @html\RunJavascript "window.socketSend('#{safe}');"

AsyncRead "js/websockets.js", "DOWNLOAD", (fileName, gamePath, status, data) ->
    if status ~= FSASYNC_OK
        error fileName, gamePath, status

    HTML = "<script>#{data}</script>"

