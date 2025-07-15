-- URL pública de tu servidor Flask (ajústalo tú)
local URL_BASE = "https://8fdfc3ff64ee.ngrok-free.app"  -- ← cámbialo por el real

term.clear()
term.setCursorPos(1, 1)
print("Welcome to LoveChat!")
print("Please enter your name with love and be respectful:")
io.write("> ")
local username = read()
if username == "" then username = "GodLover" end

term.clear()
print("Connecting to LoveChat with love as: " .. username .. "\n")

local lastTs = 0

-- 📨 Enviar mensaje
local function sendMessage(txt)
  local body = textutils.serializeJSON({user = username, text = txt})
  local h = http.post(URL_BASE .. "/send", body, {
    ["Content-Type"] = "application/json"
  })
  if h then h.close() end
end

-- 📥 Recibir nuevos mensajes
local function pollMessages()
  local h = http.get(URL_BASE .. "/messages?after=" .. tostring(lastTs))
  if h then
    local data = textutils.unserialiseJSON(h.readAll())
    h.close()
    for _, m in ipairs(data) do
      print("[" .. m.user .. "] " .. m.text)
      if m.ts > lastTs then lastTs = m.ts end
    end
  end
end

-- 🧠 Bucle principal de chat
parallel.waitForAny(
  -- Entrada del usuario
  function()
    while true do
      io.write("> ")
      local msg = read()
      if msg ~= "" then sendMessage(msg) end
    end
  end,
  -- Receptor de mensajes cada 2 segundos
  function()
    while true do
      pollMessages()
      os.sleep(2)
    end
  end
)
