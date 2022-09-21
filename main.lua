local STEP_TIME = 0.1 -- Time between each step
local Cells = {} -- Cells table
local CameraPos = {x = 0, y = 0}
local function addCell(x, y)
    -- create a table if it doesn't exist
    Cells[x] = Cells[x] or {}

    -- add the cell
    Cells[x][y] = true
end

local function removeCell(x, y)
    if Cells[x] then
        Cells[x][y] = nil

        -- remove the table if empty
        for key, value in pairs(Cells[x]) do
            return
        end
        Cells[x] = nil
    end
end

local function step()
    local deadCells = {}
    local deadNeightbours = {}
    local neighbors = 0
    for x, value in pairs(Cells) do
        for y, _ in pairs(value) do
            neighbors = 0
            for i = -1, 1, 1 do
                for j = -1, 1, 1 do
                    if i ~= 0 or j ~= 0 then
                        if Cells[x+i] and Cells[x + i][y + j] then
                            neighbors = neighbors + 1
                        else
                            deadNeightbours[x + i] = deadNeightbours[x + i] or {}
                            if deadNeightbours[x + i][y + j] then
                                deadNeightbours[x + i][y + j] = deadNeightbours[x + i][y + j] + 1
                            else
                                deadNeightbours[x + i][y + j] = 1
                            end
                        end
                    end
                end
            end
            if neighbors < 2 or neighbors > 3 then
                table.insert(deadCells, {x, y})
            end
        end
    end

    -- remove dead Cells
    for index, value in ipairs(deadCells) do
        removeCell(value[1], value[2])
    end

    -- reproduction
    for x, t in pairs(deadNeightbours) do
        for y, value in pairs(t) do
            if value == 3 then
                addCell(x, y)
            end
        end
    end
end

local function reset()
    CameraPos.x = 0
    CameraPos.y = 0
    Cells = {}

    for i = 1, love.math.random(500), 1 do
        addCell(15+love.math.random(0, 50), 10+love.math.random(0, 40))
    end
end

function love.load()
    love.window.setTitle('Game of Life')
    love.graphics.setBackgroundColor(0.95, 0.95, 0.95)
    reset()
end

local currentTime = STEP_TIME
local garbageCollection = 0.4
function love.update(dt)
    if garbageCollection < 0 then
        garbageCollection = 0.4
        collectgarbage()
    end
    garbageCollection = garbageCollection - dt

    if currentTime < 0 then
        currentTime = STEP_TIME
        step()
    end
    currentTime = currentTime - dt

    CameraPos.x = CameraPos.x + ((love.keyboard.isDown('right') and 1 or 0) - (love.keyboard.isDown('left') and 1 or 0)) * dt * 500
    CameraPos.y = CameraPos.y + ((love.keyboard.isDown('down') and 1 or 0) - (love.keyboard.isDown('up') and 1 or 0)) * dt * 500
end

function love.draw()
    love.graphics.print('Press SPACE to reset\nUse ARROWS to move around', 10, 10)
    
    love.graphics.setColor(0.1, 0.1, 0.1, 0.03)

    for i = 1, 62, 1 do
        love.graphics.line(-10, i * 10 - 10 - (CameraPos.y % 10), 820, i * 10 - 10 - (CameraPos.y % 10))
    end

    for i = 1, 82, 1 do
        love.graphics.line(i * 10 - 10 - (CameraPos.x % 10), -10, i * 10 - 10 - (CameraPos.x % 10), 620)
    end

    love.graphics.translate(-CameraPos.x, -CameraPos.y)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    for x, value in pairs(Cells) do
        for y, _ in pairs(value) do
            love.graphics.rectangle("fill", x * 10, y * 10, 10, 10)
        end
    end
end

function love.keypressed(key)
    if key == "space" then
        reset()
    end
end