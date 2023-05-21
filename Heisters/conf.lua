function love.conf(t)
    t.window.width = 1080
    t.window.height = 720
    t.console = true
    t.window.title = "Heisters"

    -- screen_pos --
    t.window.x = 1920/2-(514)
    t.window.y = 1080/2-(384)

    -- modules --
    t.modules.joystick = false
    t.modules.physics = false
end