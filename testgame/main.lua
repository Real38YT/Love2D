function love.load()
    sounds = {}
    sounds.grass = love.audio.newSource("sounds/Walking-Grass.mp3", "static")
    sounds.music = love.audio.newSource("sounds/BackgroundMusic1.wav", "stream")
    sounds.music:setLooping(true)

    sounds.music:play()
    
wf = require 'scripts/windfield'
world = wf.newWorld(0, 0)

    camera = require 'scripts/camera'
    cam = camera()

    anim8 = require 'scripts/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require 'scripts/sti'
    gameMap = sti('maps/testMap.lua')

    player = {}
    player.collider = world:newBSGRectangleCollider(390, 240, 20, 40, 0)
    player.collider:setFixedRotation(true)
    player.x = 400
    player.y = 200
    player.speed = 250
    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid( 12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )

    player.animations = {}
    player.animations.down = anim8.newAnimation( player.grid('1-4', 1), 0.2 )
    player.animations.left = anim8.newAnimation( player.grid('1-4', 2), 0.2 )
    player.animations.right = anim8.newAnimation( player.grid('1-4', 3), 0.2 )
    player.animations.up = anim8.newAnimation( player.grid('1-4', 4), 0.2 )

    player.anim = player.animations.left

    background = love.graphics.newImage('sprites/background.png')

 walls = {}
 if gameMap.layers["Walls"] then
 for i, obj in pairs(gameMap.layers["Walls"].objects) do
    local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
     wall: setType('static')
     table.insert(walls, wall)
     end
 end
      
end

function love.update(dt)
    local isMoving = false

    local vx = 0
    local vy = 0

    if love.keyboard.isDown("d") then
       vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("a") then
        vx = player.speed * -1
        player.anim = player.animations.left
        isMoving = true
    end

    if love.keyboard.isDown("s") then
        vy = player.speed
        player.anim = player.animations.down
        isMoving = true
    end

    if love.keyboard.isDown("w") then
        vy =  player.speed * -1
        player.anim = player.animations.up
        isMoving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    player.anim:update(dt)

    -- Update camera position
    cam:lookAt(player.x, player.y)

    -- This section prevents the camera from viewing outside the background
    -- First, get width/height of the game window
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    -- Left border
    if cam.x < w/2 then
        cam.x = w/2
    end

    -- Right border
    if cam.y < h/2 then
        cam.y = h/2
    end

    -- Get width/height of background
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    -- Right border
    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end
    -- Bottom border
    if cam.y > (mapH - h/2) then
        cam.y = (mapH - h/2)
    end


end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Floor"])
        gameMap:drawLayer(gameMap.layers["Path"])
        gameMap:drawLayer(gameMap.layers["trees"])
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2, nil, 6, 9)
    cam:detach()
end