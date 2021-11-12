local insert
insert = table.insert
local AsyncRead
AsyncRead = file.AsyncRead
local JavascriptSafe, Replace
do
  local _obj_0 = string
  JavascriptSafe, Replace = _obj_0.JavascriptSafe, _obj_0.Replace
end
local TableToJSON
TableToJSON = util.TableToJSON
local HTML
local createHTML
createHTML = function(address, html)
  if html == nil then
    html = HTML
  end
  return Replace(html, "{{{WEBHOOK_ADDRESS}}}", address)
end
do
  local _class_0
  local _base_0 = {
    _connect = function(self)
      do
        local _with_0 = vgui.Create("DFrame")
        self.panel = _with_0
        _with_0:SetSize(0, 0)
        _with_0:SetTitle("")
        _with_0:SetDeleteOnClose(true)
        _with_0.Paint = function()
          return nil
        end
      end
      do
        local _with_0 = vgui.Create("DHTML", self.panel)
        self.html = _with_0
        _with_0:AddFunction("window", "socketMessage", (function()
          local _base_1 = self
          local _fn_0 = _base_1._message
          return function(...)
            return _fn_0(_base_1, ...)
          end
        end)())
        _with_0:AddFunction("window", "socketOpen", (function()
          local _base_1 = self
          local _fn_0 = _base_1._open
          return function(...)
            return _fn_0(_base_1, ...)
          end
        end)())
        _with_0:AddFunction("window", "socketClose", (function()
          local _base_1 = self
          local _fn_0 = _base_1._close
          return function(...)
            return _fn_0(_base_1, ...)
          end
        end)())
        _with_0:AddFunction("window", "socketError", (function()
          local _base_1 = self
          local _fn_0 = _base_1._error
          return function(...)
            return _fn_0(_base_1, ...)
          end
        end)())
        _with_0:AddFunction("window", "socketStatus", (function()
          local _base_1 = self
          local _fn_0 = _base_1._status
          return function(...)
            return _fn_0(_base_1, ...)
          end
        end)())
        _with_0:SetAllowLua(true)
        _with_0:SetHTML(createHTML(self.address))
        return _with_0
      end
    end,
    _runCbs = function(self, event, ...)
      local _list_0 = self.listeners[event]
      for _index_0 = 1, #_list_0 do
        local cb = _list_0[_index_0]
        cb(...)
      end
    end,
    _message = function(self, msg)
      return self:_runCbs("message", msg)
    end,
    _open = function(self)
      return self:_runCbs("open")
    end,
    _close = function(self)
      return self:_runCbs("close")
    end,
    _error = function(self)
      return self:_runCbs("err")
    end,
    _status = function(self, status)
      self:_runCbs("status", status)
      self.listeners.status = { }
    end,
    on = function(cable, event)
      return {
        call = function(self, cb)
          return insert(cable.listeners[event], cb)
        end
      }
    end,
    Connect = function(self)
      return self:_connect()
    end,
    Close = function(self)
      self.html:RunJavascript("gmSocket.close();")
      return timer.Simple(0, function()
        return self.panel:Close()
      end)
    end,
    Status = function(self, cb)
      self:on("status", cb)
      return self.html:RunJavascript("gmSocket.getStatus();")
    end,
    SendMessage = function(self, msg)
      local safe = JavascriptSafe(msg)
      return self.html:RunJavascript("window.socketSend('" .. tostring(safe) .. "');")
    end,
    SendData = function(self, data)
      local safe = JavascriptSafe(TableToJSON(data))
      return self.html:RunJavascript("window.socketSend('" .. tostring(safe) .. "');")
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, address, port, secure)
      if port == nil then
        port = "443"
      end
      if secure == nil then
        secure = true
      end
      self.listeners = {
        message = { },
        open = { },
        close = { },
        err = { },
        status = { }
      }
      local protocol = secure and "wss" or "ws"
      self.address = tostring(protocol) .. "://" .. tostring(address) .. ":" .. tostring(port)
    end,
    __base = _base_0,
    __name = "Cable"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Cable = _class_0
end
return AsyncRead("js/websockets.js", "DOWNLOAD", function(fileName, gamePath, status, data)
  if status ~= FSASYNC_OK then
    error(fileName, gamePath, status)
  end
  HTML = "<script>" .. tostring(data) .. "</script>"
end)
