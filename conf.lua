function love.conf(t)
	t.version = "11.1"
	t.identity = ".cosvent"

	local w = t.window
	w.title = "CosVent"
	w.icon = "assets/gfx/favicon.png"
	w.width,w.height = 800,480
	w.vsync = 1
	w.centered = true

	local m = t.modules
	m.audio		= true
	m.data		= true
	m.event		= true
	m.font		= true
	m.graphics	= true
	m.image		= true
	m.joystick	= true
	m.keyboard	= true
	m.math		= true
	m.mouse		= true
	m.physics	= false
	m.sound		= true
	m.system	= true
	m.thread	= true
	m.timer		= true
	m.touch		= false
	m.video		= true
	m.window	= true
end