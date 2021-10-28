# gm_cable

A pure-lua clientside-only Websockets implementation for Garry's Mod.

While other implementations require the client to install a binary module, Cable works on all branches out-of-the-box, no action needed from the player!

Cable creates a background HTML panel and uses Javascript to create/interact with the Websockets inside of the panel.


## Installation
Simply download a copy of the zip, or clone the repository straight into your addons folder.

### Download
The latest pre-compiled versions are available in **[Releases](https://github.com/CFC-Servers/gm_cable/releases/)**

### Git Clone
<details><summary>Read More</summary>
<p>
  Because this project uses Moonscript, keeping it updated via git is _slightly_ more involved.

  The `main` branch is where the Moonscript code lives, and the [`lua` branch](https://github.com/CFC-Servers/gm_cable/tree/lua) is a lua-only branch containing the compiled code from the most recent release. You can use the `lua` branch to keep `gm_cable` up to date.
  ```sh
  git clone --single-branch --branch lua git@github.com:CFC-Servers/gm_cable.git
  ```

  Assuming you can get the project cloned (some hosting interfaces may not support this), any auto-updater software should work just fine.
</p></details>

## Usage
Using `gm_cable` is really straightforward!

Here's a simple example:
```lua
require( "cable" )
local myCable = Cable( serverIp )

-- Add a callback for newly received messages
myCable:on( "message" ):call( print )

myCable:Connect()
myCable:SendMessage( "Hello!" )
```

## API

### The Cable constructor:
**`Cable( string serverIp, string serverPort = "443", bool secure = true )`**
  - The `secure` parameter determines which protocol is used. `true` for `wss://`, `false` for `ws://`

### Connecting
**`myCable:Connect()`**
 - Actually establishes the connection - the Cable is completely inactive before calling this method

### Callbacks
 - The basic formula for callbacks is as follows:
```lua
myCable:on( string eventName ):call( func callback )
```
 - Acceptable event names:
   - **`open`**: Called when the connection is successfully established
   - **`message`**: Called when a message is received
   - **`err`**: Called when the Websocket has an error
   - **`close`**: Called when the connection is politely closed

### Status
**`myCable:Status( func callback )`**
 - Retrieving the status isn't immediate. You'll need to pass a callback that will be called with the Websocket's status code

### Sending data
**`myCable:SendMessage( string message )`**
 - Sends a basic string over the Websocket

**`myCable:SendData( table dataTable )`**
 - Sends a json-ified Lua table

### Closing
**`myCable:Close()`**
 - Closes the connection politely. Can be re-established using `myCable:Connect()` at any time
