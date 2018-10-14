-- player stuffs

-- love.module shortcuts
local la = love.audio
local le = love.event
local lf = love.filesystem
local lg = love.graphics
local li = love.image
local lj = love.joystick
local lk = love.keyboard
local lm = love.mouse
local ln = love.math
local lp = love.physics
local ls = love.system
local ly = love.thread
local lt = love.timer
local lw = love.window

-- lua shortcuts
local min,max,abs,sign = math.min,math.max,math.abs,sign

--# #define's
local SPD = 3600
local RUNSPD = SPD*2
local GRV = 2000
local SPEEDUP = 0.25
local JUMPHEIGHT = -800

local ezra = lg.newImage("ezra.png")

plyr = {
	x=510,y=670,z=0, xv=0,yv=0,zv=0,
	hv=30,mhv=30, av=10,mav=10,
	xp=0, tkns=0,
	anm={cur="hodl",las="", f=1,dt=0, d1=1,d2=1},
	
	-- only for strife
	dmg=2,def=1,spd=3,
	onguard=false,canguard=true,guarddt=0, ishurt=false,hurtdt=0,hurtf=1, isrockn=false,rockndt=0
}

-- collision aka safety oval
local t,maxi,phi = {},32,2*math.pi
for i=1,maxi,2 do
	t[i]   = 60 * math.cos( (i / maxi) * phi ) + plyr.x
	t[i+1] = 30 * math.sin( (i / maxi) * phi ) + plyr.y
end
plyr.col = hc.polygon(unpack(t))
t,maxi,phi = nil,nil,nil

-- assets, should load only once
local passet = {img=lg.newImage("assets/gfx/ezra.png")}
local v,w,h = nil,passet.img:getDimensions()
for i=1,2 do
	v = i==1 and 0 or 280
	passet[i] = {hodl={},walk={},jump={}}
	passet[i].hodl[1] = lg.newQuad(0,v,   200,280, w,h)
	passet[i].walk[1] = lg.newQuad(200,v, 200,280, w,h); passet[i].walk[2] = passet[i].hodl[1]
	passet[i].walk[3] = lg.newQuad(400,v, 200,280, w,h); passet[i].walk[4] = passet[i].hodl[1]
	passet[i].jump[1] = lg.newQuad(200,v, 200,280, w,h)
	passet[i].jump[2] = lg.newQuad(400,v, 200,280, w,h)
end
v,w,h = nil,nil,nil

local ininteractable,interactablefunc = false,function()end
local ku,kd,kl,kr
function plyr.update(dt)
	if not panels.isActive() and tostate==gamestate and tomap==currentmap and mapsdarkness<0.5 then
		--ks = lk.isDown("space")	and 1 or 0
		ku = lk.isDown("up")	and 1 or 0
		kd = lk.isDown("down")	and 1 or 0
		kl = lk.isDown("left")	and 1 or 0
		kr = lk.isDown("right")	and 1 or 0
	else
		ku,kd,kl,kr = 0,0,0,0
	end

--# movement
	local p = plyr

	-- directional movement
	local dx,dy = (kr-kl),(kd-ku)

	-- keyboard move
	if (dx~=0 or dy~=0) then
		local spd = canrun and RUNSPD or SPD
		p.xv = p.xv + spd*dx*dt*SPEEDUP
		p.yv = p.yv + spd*dy*dt*SPEEDUP--/2
		SPEEDUP = min(SPEEDUP + dt*2,1)
	end

	if abs(p.xv) <= 0.1 then p.xv = 0 end --elseif abs(p.xv) > MAXSPD then p.xv = sign(p.xv)*MAXSPD end
	if abs(p.yv) <= 0.1 then p.yv = 0 end --elseif abs(p.yv) > MAXSPD then p.yv = sign(p.yv)*MAXSPD end
	p.x = p.x + p.xv * dt; p.xv = p.xv * (1-dt*12)
	p.y = p.y + p.yv * dt; p.yv = p.yv * (1-dt*12)
	-- p.zv = min(p.zv + GRV*dt,7100); p.z = p.z + p.zv * dt
	-- if p.z>0 then p.z,p.zv = 0,0 end

	-- if dx==0 and dy==0 then p.xv,p.yv = p.xv/1.15,p.yv/1.15; SPEEDUP = 0.25 end

	-- if ks==0 and p.zv<JUMPHEIGHT/4 then p.zv = JUMPHEIGHT/4 end


--# collision handling
	p.col:moveTo(p.x,p.y-16)

	if not(_DEBUG and lk.isDown("lctrl")) then
		local collided,dx,dy
		for i,v in ipairs(collidables) do
			collided,dx,dy = p.col:collidesWith(v)
			if collided then
				p.col:move(dx,dy)
				p.x,p.y = p.x+dx,p.y+dy
			end
		end
	end
	for i,v in ipairs(triggerzones) do
		collided = p.col:collidesWith(v)
		if collided and type(v:getUserData())=="function" then
			v:getUserData()()
		end
	end
	ininteractable = false
	for i,v in ipairs(interactables) do
		collided = p.col:collidesWith(v)
		if collided and type(v:getUserData())=="table" then
			local t = v:getUserData()
			ininteractable = t.pd1==p.anm.d1 and t.pd2==p.anm.d2
			interactablefunc = t.func
		end
	end


--# animation
	local a = p.anm
	local mx = 0
	if p.zv~=0 then
		mx = 0.05
		a.cur = "jump"
	elseif dx~=0 or dy~=0 then
		mx = 0.1
		a.cur = "walk"
	else
		a.cur = "hodl"
	end

	if a.las~=a.cur then
		a.f = 1
		a.dt = 0
		a.las = a.cur
	end

	a.dt = a.dt + dt
	if a.dt >= mx then a.f,a.dt = a.f + 1,0 end
	if a.f > #passet[a.d2][a.cur] then a.f = 1 end

	a.d1 = dx~=0 and dx or a.d1
	a.d2 = dy==-1 and 2 or dy==1 and 1 or a.d2
end

function plyr.draw()
	local p = plyr
	local a = p.anm
	--lg.setColor(1, 170/256, 0, 0.25); lg.rectangle("fill", p.x-90,p.y+p.z-240, 180,240)
	--lg.setColor(1, 100/256, 0, 0.25); lg.rectangle("fill", p.x-75,p.y+p.z-230, 150,220)
	lg.setColor(0,0,0,0.35)
	lg.ellipse("fill", plyr.x,plyr.y-16, 60,30)
	lg.setColor(1,1,1)
	local x,y, w,h = passet[a.d2][a.cur][a.f]:getViewport()
	lg.draw(passet.img, passet[a.d2][a.cur][a.f], p.x,p.y+20, 0,a.d1,1, w/2,h)
	--print(p.x,p.y)
	--lg.setColor(0, 170/256, 1); p.col:draw("line"); lg.setColor(1,1,1)
end

function plyr.keypressed(k)
	if k=="x" then
		if ininteractable then interactablefunc() end
	end
end

function plyr.isInInteractable()
	return ininteractable -- isininteractable==true ?
end