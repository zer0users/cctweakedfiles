-- Ajusta URL_BASE a tu túnel público
local URL_BASE = "https://yourname.serveo.net"  -- <‑‑ cámbialo
local username = "Aaron"

print("Connecting to LoveChat as " .. username .. "…")
local lastTs = 0

-- Función para enviar un mensaje
local function sendMessage(txt)
  local body = textutils.serializeJSON({user = username, text = txt})
  local h = http.post(URL_BASE .. "/send", body, {["Content-Type"]="application/json"})
  if h then h.close() end
end

-- Función para obtener mensajes nuevos
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

-- Bucle principal
parallel.waitForAny(
  -- lector de teclado
  function()
    while true do
      io.write("> ")
      local msg = read()
      if msg ~= "" then sendMessage(msg) end
    end
  end,
  -- recepción cada 2 s
  function()
    while true do
      pollMessages()
      os.sleep(2)
    end
  end
)
