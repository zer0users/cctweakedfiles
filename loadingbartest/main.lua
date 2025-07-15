-- ╔═══════════════════════════════════════╗
-- ║        Loading Bar Test (CC:T)       ║
-- ║    Simulates erratic download speed  ║
-- ╚═══════════════════════════════════════╝

local term = term
local totalBlocks = 50        -- ancho de la barra
local progress    = 0
local percent     = 0

math.randomseed(os.clock()*10000)

local function drawBar()
  term.setCursorPos(1, 1)
  term.clear()
  local filled = math.floor(progress)
  local empty  = totalBlocks - filled
  local bar    = string.rep("█", filled) .. string.rep("░", empty)
  percent      = math.floor((progress / totalBlocks) * 100)
  print("Loading Bar Test\n")
  print("[" .. bar .. "] " .. percent .. "%")
end

while progress < totalBlocks do
  drawBar()

  local roll = math.random()
  if roll < 0.15 then
    ----------------------------------
    -- 15 % de probabilidad: bloqueo
    ----------------------------------
    os.sleep(math.random(1, 2))   -- pausa larga, sin avanzar
  elseif roll < 0.35 then
    ----------------------------------
    -- 20 % de probabilidad: turbo
    ----------------------------------
    local jump = math.random(5, 8)
    progress   = math.min(progress + jump, totalBlocks)
    os.sleep(0.05)
  else
    ----------------------------------
    -- 65 % de probabilidad: normal
    ----------------------------------
    local step = math.random(1, 2)
    progress   = math.min(progress + step, totalBlocks)
    os.sleep(math.random() * 0.3 + 0.1)
  end
end

-- Barra completa
drawBar()
print("\nDone! God bless you! 😊")
