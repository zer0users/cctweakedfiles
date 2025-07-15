-- ╔═════════════════════════════════════════════════════╗
-- ║                    LoveChat.lua                     ║
-- ║         Chat multijugador HTTP (GET/POST)           ║
-- ║                © 2025 Konqi with love               ║
-- ╚═════════════════════════════════════════════════════╝

----------------------------------------
--  CONFIGURACIÓN
----------------------------------------
local URL_BASE = "https://8fdfc3ff64ee.ngrok-free.app"   -- ← pon aquí tu URL pública
local POLL_INTERVAL = 2                                 -- segundos entre consultas
----------------------------------------

-- 1) NOMBRE DEL USUARIO --------------------------------
term.clear()
term.setCursorPos(1, 1)
print("Welcome to LoveChat!")
print("Please enter your name with love:")
io.write("> ")
local username = read()
if username == "" then username = "Anon" end

term.clear()
print("🧠 Connecting to LoveChat as: " .. username .. "\n")
local lastTs = 0
local seen = {}   -- tabla para no imprimir el mismo ts dos veces

-- 2) ENVIAR MENSAJE ------------------------------------
local function sendMessage(txt)
  local body = textutils.serializeJSON({user = username, text = txt})
  local h = http.post(URL_BASE .. "/send", body,
    {["Content-Type"] = "application/json"})
  if h then
    -- El servidor devuelve {status="ok", ts=<number>}
    local result = textutils.unserialiseJSON(h.readAll())
    h.close()
    if result and tonumber(result.ts) then
      lastTs = tonumber(result.ts)      -- evita duplicados
      seen[lastTs] = true               -- marca como visto
    end
  else
    print("❌ Could not reach server for sending.")
  end
end

-- 3) RECIBIR MENSAJES ---------------------------------
local function pollMessages()
  local h = http.get(URL_BASE .. "/messages?after=" .. tostring(lastTs))
  if not h then
    print("❌ Connection lost… retrying")
    return
  end
  local data = textutils.unserialiseJSON(h.readAll())
  h.close()

  local highest = lastTs
  for _, m in ipairs(data) do
    local ts = tonumber(m.ts)
    if not seen[ts] then           -- solo si no se ha visto antes
      print("[" .. m.user .. "] " .. m.text)
      seen[ts] = true
    end
    if ts > highest then highest = ts end
  end
  lastTs = highest
end

-- 4) BUCLE PRINCIPAL (paralelo input / polling) --------
parallel.waitForAny(
  -- Entrada del usuario
  function()
    while true do
      io.write("> ")
      local msg = read()
      if msg ~= "" then sendMessage(msg) end
    end
  end,
  -- Recepción periódica
  function()
    while true do
      pollMessages()
      os.sleep(POLL_INTERVAL)
    end
  end
)


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
