puzzle_ping = love.audio.newSource('Assets/sounds/puzzle_ping.wav', 'static')

title_screen_music = love.audio.newSource('Assets/sounds/title.wav', 'stream')
title_screen_music:setLooping(true)
title_screen_music:setVolume(0.7)

music = {
    titlescreen = title_screen_music,
    puzzleping = puzzle_ping
}

love.audio.setVolume(1)

function clear_audio_que()
    puzzle_ping:stop()
    title_screen_music:stop()
end
