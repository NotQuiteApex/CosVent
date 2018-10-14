-- CosVent, NotQuiteApex (c) 2018


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
local sin,cos = math.sin,math.cos

math.randomseed( os.time() )

-- the main game loop
function love.run()
	love.load()
	lt.step()

	return function()
		le.pump()
		for name, a,b,c,d,e,f in le.poll() do
			if name=="quit" and not love.quit(a) then return a or 0 end
			love.handlers[name](a,b,c,d,e,f)
		end

		love.update(lt.step())

		if lg.isActive() then
			lg.origin()
			lg.clear(0.5,0.5,0.5)
			love.draw()
			lg.present()
		end

		lt.sleep(0.001)
	end
end


-- main love2d functions
function love.load()
	io.stdout:setvbuf("no")

	sysW,sysH = lg.getDimensions()
	lg.setBackgroundColor(0.5,0.5,0.5)
	lg.setDefaultFilter("linear","nearest")
	lg.setLineStyle("rough")
	lg.setLineWidth(2)
	lg.setPointSize(4)

	-- title, intro, overworld, strife, outro, credits
	gamestate = "title"
	tostate = gamestate
	blackoutdt = 1
	framecount = 0
	local gametodos = {
		overworld = {
			"flesh out ludo's animation",
			"add strife event trigger",
			"finish rooms (kitchen, bathroom, and laundry)",
			"spindash! (?)"
		},
		cache = {
			"simple stats display",
			"sylladex, Vector-style"
		},
		strife = {
			"revolver move choose, hv/av/xp on bottom",
			"add 2 simon moves, crowbar and bite",
			"add 2 dad moves, wrench and drillbit",
		},
		credits = {
			"by NotQuiteApex",
			"Homestuck and MSPA (c) Andrew Hussie",
			"LÖVE by the LÖVE Development Team", -- mega thanks
			"Hardon Collider by VRLD",
			"Special Thanks",
			"Dad",
			"Andy 'Pochi' Froggorino",
			"Ill Teteka",
			"Flag Admiral Stabby Crew",
		}
	}

	font = lg.newFont("assets/gfx/fontholmstock.ttf",16)
	lg.setFont(font)

	moonbg = lg.newImage("assets/gfx/title/moon.png")
	for i=1,3 do _G["cloud"..i] = lg.newImage("assets/gfx/title/cloud"..i..".png") end
	cvlogo = lg.newImage("assets/gfx/title/logo.png")
	raindrops = {t=0,maxt=0.05}
	raintrail = {}
	raincanv = lg.newCanvas()
	stormcanv = lg.newCanvas()
	rainsfx = la.newSource("assets/sfx/weather2.ogg","stream")
	rainsfx:setVolume(0)
	rainsfx:setLooping(true)

	dedcoll = lg.newImage("assets/gfx/eastereggs/dedcollision.png")
	_DEBUG = false

	hc = require("libs.hc")
	json = require("libs.json")

	require("plyr")
	require("maps")
	require("panels")

	intro = {tcur="", tpos=0, t_dt=0,tmax=1/30, pval=0,tval=0, part=1,topart=1, cantype=false,typed=""}
	for i=1,6 do intro["i"..i] = lg.newImage("assets/gfx/panels/wake"..i..".png") end
	local q = intro
	q.t1 = "On this day, in the middle of summer, on the 10th of July, a young boy sits in his bed in the early morning of his birthday.\n\nHe is incredibly tired.\n\nCare to remind him of his name?"
	q.typebutton = lg.newImage("assets/gfx/typebutton.png") -- this is a mess and needs to be cleaned. later.
	q.needname = false
	q.truename = "SIMON EZRA HUBBLE"
	q.typedname = ""
	q.truenamedt = -1.5
	q.truenamemax = 1/20
	q.right = false
	q.wrong = false
	q.wrongnum = 1
	q.winon = false
	q.winpart = 1
	q.windt = 0
	q.winmax = 0.1
	q.waittype = false
	q.waittypedt = 0
	q.waittypemax = 1
	q.check = function()
		local i = intro
		if i.typed == i.truename then i.part = 6; i.cantype = false; i.right = true;i.winon=true
		else i.wrong=true; i.winon=true; i.typed = wronginsults[i.wrongnum]; i.wrongnum = i.wrongnum + 1; i.waittype = true
		end
	end
	wronginsults = {"NO, YOU IDIOT.","THAT IS WRONG.","TRY AGAIN, DINGUS."}

	gitcardget = false
	gitx = 0
	gity = 0
	gitt = 0
	crowbarget = false
	crox = 0
	croy = 0
	crot = 0

	xbutton = lg.newImage("assets/gfx/xbutton.png")
	notiftext = lg.newImage("assets/gfx/notiftext.png")
	notifarrow = lg.newImage("assets/gfx/notifarrow.png")
	notifshield = lg.newImage("assets/gfx/notifshield.png")
	notifcrowbar = lg.newImage("assets/gfx/notifcrowbar.png")

	credits = {lg.newImage("assets/gfx/credits1.png"),lg.newImage("assets/gfx/credits2.png")}
	creditsdt = 0
	creditsmax = 0.2
	creditsframe = 1

	rainsfx:play()

	-- intro to strife
	heartbeatbg = lg.newImage("assets/gfx/heartbeatbg.png")
	heartbeatsnd = la.newSource("assets/sfx/heartbeat.wav", "static")
	heartbeatdt = -1
	heartbeatmax = 3
	heartbeatf = 1
	heartbeatsnded = false

	-- STRIFE stuffs
	strifebg = lg.newImage("assets/gfx/bg.png")
	cheezbols = lg.newImage("assets/gfx/CHEEZBOLS.png")
	numfont = lg.newImageFont("assets/gfx/numbers.png", " 0123456789:", 1)
	defaultfont = lg.newFont(12)
	statplate = lg.newImage("assets/gfx/statplate.png")
	uicrowbar = lg.newImage("assets/gfx/crowbarui.png")
	uicrowbargrey = lg.newImage("assets/gfx/crowbaruigrey.png")
	uiguard = lg.newImage("assets/gfx/guardui.png")
	uiarrow = lg.newImage("assets/gfx/arrowui.png")
	uipull1 = -1
	uipull2 = -2
	uipull3 = -3

	crowbarhit = la.newSource("assets/sfx/cbar_hit2.wav","static")
	wrenchhit = la.newSource("assets/sfx/pwrench_hit2.wav","static")
	mutiny = la.newSource("assets/sfx/mutiny.ogg","stream")
	mutiny:setLooping(true)
	--mutiny:play()

	--simn = lg.newImage("simon.png")
	--dadd = lg.newImage("dad.png")


	animsimn = {
		stand={img=lg.newImage("assets/gfx/simon-stand.png")},
		block=lg.newImage("assets/gfx/simon-guard.png"),
		attack={img=lg.newImage("assets/gfx/simon-attack.png")},
		hurt={}
	}
	local w,h = animsimn.stand.img:getDimensions()
	for i=1,5 do animsimn.stand[i] = lg.newQuad(260*(i-1),0, 260,280, w,h) end
	local w,h = animsimn.attack.img:getDimensions()
	animsimn.attack[1] = lg.newQuad(0,0, 301,281, w,h)
	animsimn.attack[2] = lg.newQuad(301,0, 287,273, w,h)
	animsimn.attack[3] = lg.newQuad(588,0, 236,274, w,h)
	for i=1,2 do animsimn.hurt[i] = lg.newImage("assets/gfx/simon-hurt"..i..".png") end

	animdadd = {
		stand={img=lg.newImage("assets/gfx/dad-stand.png")},
		block=lg.newImage("assets/gfx/dad-block.png"),
		attack={},
		hurt=lg.newImage("assets/gfx/dad-hurt.png"),
		outro={}
	}
	local w,h = animdadd.stand.img:getDimensions()
	for i=1,5 do animdadd.stand[i] = lg.newQuad(322*(i-1),0, 322,370, w,h) end
	for i=1,4 do animdadd.attack[i] = lg.newImage("assets/gfx/dad-attack"..i..".png") end
	for i=1,4 do animdadd.outro[i] = lg.newImage("assets/gfx/dad-outro"..i..".png") end


	--plyr = {x=170,y=460, hv=20,av=0, dmg=2,def=1,spd=3, onguard=false,canguard=true,guarddt=0, ishurt=false,hurtdt=0,hurtf=1, isrockn=false,rockndt=0}
	enmy = {x=780-160,y=450, hv=20,av=0, dmg=3,def=1,spd=2, ishurt=false,hurtdt=0,hurtf=1, isrockn=false,rockndt=0}

	fightstate = "intro" -- intro, choose, action
	turnnum = 1
	turns = {"plyr1","enmy1"}

	mainopts = {"crowbar","guard"}
	mainoptscolor = {{160/256,0,0},{1,170/256,0}}

	subopts = {
		special = {"bad punch", "woof bite", "howl"},
		item = {"crimson helmet", "meat chunk", "meat chunk", "soda bomb","miilk","crimson helmet"},
	}
	cursel = 1
	subsel = 1
	curmenu = "main"
	choosetarget = false
	curtarget = "none0" -- index=plyrX,enmyX, all=plyrA,enmyA, ground=enttG, floatn=enttF,
	roundnum = 1
	roundnummax = 7

	-- stuff for strife text i guess
	textmode = false
	futrtext = ""
	disptext = ""

	-- intro strife stuff
	dadintrodt = 0
	dadintromax = 2
	dadintrofnum = 1
	dadintrof = {}
	for i=1,9 do dadintrof[i] = lg.newImage("assets/gfx/dad-intro"..i..".png") end
	holddown = false
	holddowndt = 0
	holddownmax = 0.05

	-- outro strife stuff
	outrof = 1
	outrodt = 0
	outromax = 0.75
end

local sec,oldsec,rainang = 1,1,math.pi/2+math.pi/9
function love.update(dt)
	raindrops.t = raindrops.t + dt
	if raindrops.t >= raindrops.maxt then
		raindrops.t = 0
		raindrops.maxt = 0.045 + (math.random() / 100)
		while sec==oldsec do
			sec = math.random(10)
		end
		oldsec = sec
		table.insert(raindrops, {x=(sec-1)*100+math.random(0,95),y=-10})
	end
	for i,v in ripairs(raintrail) do
		v.t = v.t - dt
		if v.t <= 0 then table.remove(raintrail,i) end
	end
	local ox,oy
	for i,v in ripairs(raindrops) do
		ox,oy = v.x,v.y
		v.x = v.x + (2560 * dt * cos(rainang))
		v.y = v.y + (2560 * dt * sin(rainang))
		if v.y > 520 then table.remove(raindrops, i) end
		local b = 0
		for i=1,(ox-v.x) do
			b = i/(ox-v.x)
			table.insert(raintrail, {x=ox+(ox-v.x)*b,y=oy+(oy-v.y)*b,t=.5})
		end
	end
	if gamestate == "title" then
		if rainsfx:getVolume()<1 then rainsfx:setVolume(rainsfx:getVolume() + dt/2) end
	elseif gamestate == "overworld" then
		if rainsfx:getVolume()>0.25 then rainsfx:setVolume(rainsfx:getVolume() - dt/2) end

		maps_update(dt)
		panels.update(dt)
		plyr.update(dt)

		if gitcardget then
			gitt = gitt + dt
			if gitt >= 1 then gitcardget = false end
		end
		if crowbarget then
			crot = crot + dt
			if crot >= 1 then crocardget = false end
		end
	elseif gamestate == "intro" then
		if rainsfx:getVolume()>0.25 then rainsfx:setVolume(rainsfx:getVolume() - dt/2) end
		local i = intro
		if i.pval~=1 then i.pval = i.pval>0.999 and 1 or i.pval + (1-i.pval)*dt*8 end

		if i.tval~=1 then i.tval = i.tval>0.999 and 1 or i.tval + (1-i.tval)*dt*8 end
		if i["t"..i.part] then
			if i.tval~=1 then i.tval = i.tval>0.999 and 1 or i.tval + (1-i.tval)*dt*8 end
			if i.tpos < #i["t"..i.part] then
				i.t_dt = i.t_dt + dt
				for j=1,5 do if i.t_dt>=i.tmax then
					i.t_dt = i.t_dt - i.tmax
					i.tpos = i.tpos + 1
					i.tcur = i.tcur .. i["t"..i.part]:sub(i.tpos,i.tpos)
				end end
			end
		else 
			if i.tval~=0 then i.tval = i.tval<0.001 and 0 or i.tval + (0-i.tval)*dt*8 end
		end

		if i.waittype then
			i.waittypedt = i.waittypedt + dt
			if i.waittypedt >= i.waittypemax then
				i.waittype = false
				i.waittypedt = 0
				i.typed = ""
				i.winon = false
				i.winpart = 1
				i.windt = 0
				i.right = false
				i.wrong = false
			end
		end

		if i.part == 5 then
			i.truenamedt = i.truenamedt + dt
			if i.truenamedt > i.truenamemax then
				i.truenamedt = i.truenamedt - i.truenamemax
				i.typed = i.typed .. i.truename:sub(#i.typed+1,#i.typed+1)
				if i.typed == i.truename then intro.check() end
			end
		end

		if i.right or i.wrong then
			if i.winpart < 5 then
				i.windt = i.windt + dt
				if i.windt >= i.winmax then
					i.windt = i.windt - i.winmax
					i.winpart = i.winpart + 1
					i.winon = not i.winon
				end
			end
		end
	elseif gamestate == "credits" then
		creditsdt = creditsdt + dt
		if creditsdt >= creditsmax then
			creditsdt = 0
			creditsframe = creditsframe + 1
			if creditsframe > #credits then creditsframe = 1 end
		end
	elseif gamestate == "strife" then
		dt = math.min(dt,1/30)
		if fightstate ~= "intro" and fightstate ~= "outro" then
			uipull1 = uipull1 + (1-uipull1)*dt*8
			if holddown then
				holddowndt = holddowndt + dt
				if holddowndt >= holddownmax then
					holddown = false
				end
			end

			if not plyr.canguard then
				plyr.guarddt = plyr.guarddt + dt
				if plyr.guarddt > 0.5 then
					plyr.guarddt = 0
					plyr.canguard = true
				elseif plyr.guarddt > 0.3 then
					plyr.onguard = false
				end
			end
			if plyr.ishurt then
				plyr.hurtdt = plyr.hurtdt + dt
				if plyr.hurtdt>=0.2 then
					plyr.hurtf = 1
					plyr.ishurt = false
					plyr.hurtdt = 0
				elseif plyr.hurtdt>=0.1 then
					plyr.hurtf = 2
				end
			end
			if plyr.isrockn then
				plyr.rockndt = plyr.rockndt + dt
				if plyr.rockndt>=0.2 then
					plyr.rockndt = 0
					plyr.isrockn = false
				end
			end

			if enmy.ishurt then
				enmy.hurtdt = enmy.hurtdt + dt
				if enmy.hurtdt>=0.2 then
					enmy.ishurt = false
					enmy.hurtdt = 0
				end
			end
			if enmy.isrockn then
				enmy.rockndt = enmy.rockndt + dt
				if enmy.rockndt>=0.2 then
					enmy.rockndt = 0
					enmy.isrockn = false
				end
			end

			if roundnum == roundnummax then
				fightstate = "outro"
			end

			if fightstate == "action" then
				local startturn = turnnum
				if turns[turnnum]:sub(1,-2)=="plyr" then
					if curmenu=="main" then
						if mainopts[cursel] == "crowbar" then
							if not (oldx and oldy) then oldx,oldy,atkdone,waitdt,dmgplus,hops,hopdt = plyr.x,plyr.y,"go",0,false,0,0 end
							local enmyposx = enmy.x - 250
							hopdt = hopdt + dt
							if atkdone=="go" then
								plyr.x = plyr.x + sign(enmyposx - plyr.x)*dt*380
								plyr.y = oldy-160*math.sin((plyr.x-oldx)/(enmyposx+100-oldx)*math.pi)
								if plyr.x>=enmyposx then atkdone = "smash" end
							-- elseif atkdone=="hold" then
							-- 	waitdt = waitdt + dt
							-- 	if waitdt>=0.2 then
							-- 		if dmgplus then enmy.hv = enmy.hv - 2*math.max(plyr.dmg-enmy.def,0); atkdone=hops==1 and "back" or "hop"; hops = hops + 1
							-- 		else enmy.hv = enmy.hv - math.max(plyr.dmg-enmy.def,0); atkdone="back" end
							-- 		waitdt = 0
							-- 	end
							-- elseif atkdone=="hop" then
							-- 	if not tempy then tempy = plyr.y end
							-- 	hopdt = hopdt + dt
							-- 	plyr.y = tempy - 100*math.sin(hopdt/0.5*math.pi)
							-- 	if hopdt >= 0.5 then atkdone="hold" end
							elseif atkdone=="smash" then
								if plyr.y < enmy.y then
									plyr.y = plyr.y  + sign(enmy.y - plyr.y)*dt*2000
									plyr.x = plyr.x  + sign(enmy.x - plyr.x)*dt*800
								end
								if plyr.y >= enmy.y then plyr.y = enmy.y; atkdone = "hold" end
							elseif atkdone=="hold" then
								if waitdt==0 then
									crowbarhit:setPitch(1+(0.125-0.25*math.random()))
									if dmgplus then
										enmy.hv = enmy.hv - math.max(plyr.dmg-enmy.def,0)
										crowbarhit:setVolume(1)
										enmy.ishurt = true
									else
										crowbarhit:setVolume(0.5)
										enmy.isrockn = true
									end
									crowbarhit:play()
									enmy.hv = enmy.hv - math.max(plyr.dmg-enmy.def,0)
								end
								waitdt = waitdt + dt
								if waitdt>=0.2 then
									plyr.x = plyr.x + 70
									atkdone="back"
									waitdt = 0
								end
							elseif atkdone=="back" then
								plyr.x = plyr.x + sign(oldx - plyr.x)*dt*1000
								plyr.y = oldy-30*math.sin((plyr.x-oldx)/(enmyposx+100-oldx)*math.pi)
								if math.floor(plyr.x*10)/10<=oldx then turnnum = turnnum + 1; plyr.x,plyr.y = oldx,oldy; oldx,oldy,atkdone,waitdt,dmgplus,hops,hopdt = nil,nil,nil,nil,nil,nil,nil end
							end
						elseif mainopts[cursel] == "pass" then
							turnnum = turnnum + 1
						end
					end
				elseif turns[turnnum]:sub(1,-2)=="enmy" then
					-- decide an action (this defaults to attack)
					if not (oldx and oldy) then oldx,oldy,atkdone,waitdt,attacked,daddframe,atkblocked = enmy.x,enmy.y,"wait",0,false,1,false end
					if atkdone=="wait" then
						daddframe = 1
						waitdt = waitdt + dt
						if waitdt >= 1 then
							waitdt = 0
							atkdone = "go"
						end
					elseif atkdone=="go" then
						waitdt = waitdt + dt

						if waitdt>=0.09 then
							daddframe = 3
						elseif waitdt>=0.06 then
							daddframe = 2
						end
						enmy.x = enmy.x + (plyr.x+200 - enmy.x)*dt*10
						if math.floor(enmy.x*10)/10<=plyr.x+280 then atkdone,waitdt = "hold",0 end
					elseif atkdone=="hold" then
						daddframe = 4
						waitdt = waitdt + dt
						if waitdt>=0.5 then
							atkdone="back"
						elseif not attacked then
							plyr.hv = plyr.hv - math.max(enmy.dmg-math.ceil(plyr.def*((plyr.onguard or atkblocked) and 1.5 or 1)),0)
							plyr.ishurt = not plyr.onguard
							plyr.isrockn = plyr.onguard
							attacked = true
							wrenchhit:setPitch(1+(0.125-0.25*math.random()))
							wrenchhit:play()
						end
					elseif atkdone=="back" then
						enmy.x = enmy.x + (oldx - enmy.x)*dt*16
						if math.ceil(enmy.x)==oldx then turnnum = turnnum + 1; enmy.x,enmy.y = oldx,oldy; oldx,oldy,atkdone,waitdt,daddframe,atkblocked = nil,nil,nil,nil,nil,nil end
					end
				end

				uipull2 = uipull2 + (-2-uipull2)*dt*8
				uipull3 = uipull3 + (-3-uipull3)*dt*8
				
				if turnnum > #turns then turnnum = 1 end
				if turnnum~=startturn and turns[turnnum]:sub(1,-2)=="plyr" then fightstate = "choose"; uipull2,uipull3 = -1,-2; roundnum = roundnum + 1 end
			elseif fightstate=="choose" then
				plyr.onguard = false
				uipull2 = uipull2 + (1-uipull2)*dt*8
				uipull3 = uipull3 + (1-uipull3)*dt*8
			end
		elseif fightstate == "intro" then
			dadintrodt = dadintrodt + dt
			if dadintrodt >= dadintromax then
				dadintrodt = 0
				dadintrofnum = dadintrofnum + 1
				if dadintrofnum==2 then     dadintromax = 0.05
				elseif dadintrofnum==3 then
				elseif dadintrofnum==4 then
				elseif dadintrofnum==5 then
				elseif dadintrofnum==6 then dadintromax = 0.75; holddown = true
				elseif dadintrofnum==7 then dadintromax = 0.05
				elseif dadintrofnum==8 then
				elseif dadintrofnum==9 then
				elseif dadintrofnum==10 then fightstate,holddown,holddownmax="choose",true,0.075; mutiny:play();
				end
			end
			if holddown then
				holddowndt = holddowndt + dt
				if holddowndt >= holddownmax then
					holddowndt = 0
					holddown = false
				end
			end
		elseif fightstate == "outro" then
			uipull1 = uipull1 + (-2-uipull1)*dt*8
			uipull2 = uipull2 + (-3-uipull2)*dt*8
			uipull3 = uipull3 + (-4-uipull3)*dt*8

			if outrof <= 5 then 
				outrodt = outrodt + dt
				if outrodt>=outromax then
					if outrof <= 4 then
						outrodt = 0
						outrof = outrof + 1
					else
						tostate = "overworld"
						statetransfn = function()
							plyr.x = 290
							plyr.y = 750
							plyr.d1 = 1
							plyr.d2 = 1
							lg.setFont(font)
							panels.addToQueue("endmessage")
						end
					end
					if outrof == 2 then outromax = 0.75
					elseif outrof == 3 then outromax = 1.2
					elseif outrof == 4 then outromax = 1
					end
				end
			end
		end
	elseif gamestate == "heartbeat" then
		heartbeatdt = heartbeatdt + dt
		if heartbeatdt >= 0.5 and not heartbeatsnded then
			heartbeatsnd:play()
			heartbeatsnded = true
		end
		if heartbeatdt >= heartbeatmax then
			heartbeatdt = 0
			heartbeatf = heartbeatf + 1
			heartbeatmax = 3
			heartbeatsnded = false
		end
		if heartbeatf == 4 then
			tostate = "strife"
		end
	elseif gamestate == "easteregg" then -- pass
	end

	if gamestate==tostate then
		if blackoutdt>0 then blackoutdt = blackoutdt - dt
		else blackoutdt = 0 end
	else
		if blackoutdt<1 then blackoutdt = blackoutdt + dt
		else
			blackoutdt = 1
			gamestate=tostate
			if statetransfn then statetransfn() end
			statetransfn = nil
		end
	end
end

function love.draw()
	lg.setColor(1,1,1)

	raincanv:renderTo(function()
		lg.clear()
		lg.setBlendMode("replace")
		for i,v in ipairs(raintrail) do lg.setColor(0,0.25,1,v.t/0.5); lg.rectangle("fill", v.x-2,v.y-2, 4,4) end
		lg.setColor(0,0.25,1)
		for i,v in ipairs(raindrops) do lg.rectangle("fill", v.x-2,v.y-2, 4,4) end
		lg.setColor(1,1,1)
		lg.setBlendMode("alpha")
	end)

	stormcanv:renderTo(function()
		lg.clear()
		lg.draw(moonbg)

		local t = lt.getTime()/1.5
		lg.draw(cloud1, -40+14*sin(t),-40)
		lg.draw(cloud2, 400+15*sin(t/3),200)
		lg.draw(cloud3, -80,240+12*cos(t))

		lg.draw(raincanv)
	end)

	if gamestate == "title" then
		lg.draw(stormcanv)
		lg.draw(cvlogo, 20,20)

		local mx,my = lm.getPosition()
		local s,v = {"start","","","quit"},nil --{"start","options","credits","quit"}
		for i=1,#s do
			v = s[i]
			if (38<=mx and mx<font:getWidth(v)*2+40) and (260+40*i<=my and my<260+40*i+font:getHeight(v)*2) then
				lg.setColor(0.5,0.5,0.5)
			end
			lg.print(v, 40, 260+40*i, 0,2)
			lg.setColor(1,1,1)
		end

		lg.print("How to Play:\nArrow keys to move\nX key to inspecticate\n\nCosVent by NotQuiteApex",sysW/2+200,sysH/4*3+40)
	elseif gamestate == "overworld" then
		local m = currentmapdata

		lg.push()
		if not _DEBUG then
			lg.translate(-clamp(plyr.x-sysW/2, 0, m.xb or 800),-clamp(plyr.y-sysH/2-100, 0, m.yb or 600))
		else
			lg.translate(-(plyr.x-sysW/2),-(plyr.y-sysH/2-100))
		end

		if currentmap == "bedroom" then
			lg.draw(stormcanv,200,200, 0,1,1, 0,0, 0,-0.5)
		elseif currentmap == "hallway" then
			lg.draw(stormcanv, lg.newQuad(0,0,200,400,800,480), 100,60, 0,1,1, 0,0, 0,-0.5)
		elseif currentmap == "tvroom" then
			lg.setColor(0,0.2,0.1); lg.polygon("fill", 800,100, 1400-20,400, 1400-20,700, 800,500); lg.setColor(1,1,1)
			lg.draw(raincanv,lg.newQuad(0,0,600,400,800,480), 800,10, 0,1,1, 0,0, 0,0.5)
		end
		if m.bg then lg.draw(m.bg, m.x,m.y, 0,1,1, m.ox,m.oy) end
		--for y=1,m.w do for x=1,m.h do lg.draw(mapstile, (x-1+y-1)*96 +m.x, (y-1)*48 - x*48 +m.y) end end
		--if m.ref then lg.setColor(1,1,1,0.5); lg.draw(m.ref, m.x,m.y, 0,1,1, m.ox,m.oy); lg.setColor(1,1,1) end

		if m.back then for i,v in ipairs(m.back) do maps_drawOBJ(v) end end

		local ylist = {{t="p",y=plyr.y}}
		if m.zway then for i,v in ipairs(m.zway) do ylist[#ylist+1] = {t="o",y=v.y+currentmapdata.y,i=i} end end
		table.sort(ylist, orderY)
		for i,v in ipairs(ylist) do
			if m.zway and v.t == "o" then
				maps_drawOBJ(m.zway[v.i])
			else
				plyr.draw()
			end
		end

		if m.frnt then for i,v in ipairs(m.frnt) do maps_drawOBJ(v) end end

		if _DEBUG then
			lg.setColor(0,0,1); for i,v in ipairs(collidables)   do v:draw("line") end
			lg.setColor(1,0,0); for i,v in ipairs(triggerzones)  do v:draw("line") end
			lg.setColor(0,1,0); for i,v in ipairs(interactables) do v:draw("line") end
			lg.setColor(1, 170/256, 0); plyr.col:draw("line"); lg.setColor(1,1,1)

			lg.setColor(1,0,0)
			if m.zway then for i,v in ipairs(m.zway) do
				lg.rectangle("fill", v.x-3,v.y-3, 6,6)
			end end
			lg.rectangle("fill", plyr.x-3,plyr.y-3, 6,6)

			lg.setColor(1,1,1)
		end

		if gitcardget then
			lg.setColor(0.5,0,0,1-math.max(0,gitt-0.5)/0.5)
			lg.print("SYLLADEX+1",gitx-60,gity-40*gitt-200, 0,2)
		end
		if crowbarget then
			lg.setColor(1,104/256,0,1-math.max(0,crot-0.5)/0.5)
			lg.print("+CROWBAR",crox-60,croy-40*crot-240, 0,2)
		end

		lg.pop()

		lg.setColor(0,0,0,mapsdarkness); lg.rectangle("fill", 0,0, sysW,sysH); lg.setColor(1,1,1)

		panels.draw()

		lg.draw(xbutton, sysW-6,sysH-4, 0,1,1, 94,86)
		if panels.isActive() then lg.draw(notifarrow, sysW-50,sysH-70, 0,3,3, notifarrow:getWidth()/2,notifarrow:getHeight()/2)
		elseif plyr.isInInteractable() then lg.draw(notiftext, sysW-50,sysH-70, 0,3,3, notiftext:getWidth()/2,notiftext:getHeight()/2) end
		--lg.setColor(0,0.7,1,1) -- stown house color
	elseif gamestate == "strife" then
		lg.draw(stormcanv)
		lg.draw(strifebg)

		if fightstate ~= "intro" and fightstate ~= "outro" then
			lg.draw(cheezbols,200,70)
			local time = lt.getTime()

			local function dadanimated()
				--lg.draw(dadd, enmy.x,enmy.y, 0,1,0.95+math.abs(0.05*math.sin(time*3)), dadd:getWidth(),dadd:getHeight())
				if fightstate=="choose" then
					lg.draw(animdadd.stand.img, animdadd.stand[5], enmy.x,enmy.y + (holddown and 3 or 0), 0,1,1, 161,370)
					for i=4,1,-1 do
						lg.draw(animdadd.stand.img, animdadd.stand[i], enmy.x,enmy.y + ((0.25+0.25*(5-i+1)*0.75<=time%2 and time%2<=0.75+0.25*(5-i+1)*0.75) and 1 or 0) + (holddown and 3 or 0), 0,1,1, 161,370)
					end
				elseif fightstate=="action" and turns[turnnum]:sub(1,-2)=="enmy" then
					if atkdone=="back" then
						lg.draw(animdadd.stand.img, animdadd.stand[5], enmy.x,enmy.y + (holddown and 3 or 0), 0,1,1, 161,370)
						for i=4,1,-1 do
							lg.draw(animdadd.stand.img, animdadd.stand[i], enmy.x,enmy.y + ((0.25+0.25*(5-i+1)*0.75<=time%2 and time%2<=0.75+0.25*(5-i+1)*0.75) and 1 or 0) + (holddown and 3 or 0), 0,1,1, 161,370)
						end
					else
						local o = {
							{180, animdadd.attack[1]:getHeight()},
							{227, animdadd.attack[2]:getHeight()},
							{333, animdadd.attack[3]:getHeight()},
							{265, 365}
						}
						lg.draw(animdadd.attack[daddframe or 1], enmy.x,enmy.y, 0,1,1, o[daddframe or 1][1],o[daddframe or 1][2])
					end
				elseif enmy.ishurt or enmy.isrockn then
					if enmy.ishurt then
						local t = pingpong(enmy.hurtdt/0.075)
						lg.draw(animdadd.hurt, enmy.x+60-20*t,enmy.y+14*t, math.pi/512,1,1, 140,370)
					else
						local t = pingpong(enmy.rockndt/0.075)
						lg.draw(animdadd.block, enmy.x+10-14*t,enmy.y+6*t, 0,1,1, 140,370)
					end
				else
					lg.draw(animdadd.stand.img, animdadd.stand[5], enmy.x,enmy.y + (holddown and 3 or 0), 0,1,1, 161,370)
					for i=4,1,-1 do
						lg.draw(animdadd.stand.img, animdadd.stand[i], enmy.x,enmy.y + ((0.25+0.25*(5-i+1)*0.75<=time%2 and time%2<=0.75+0.25*(5-i+1)*0.75) and 1 or 0) + (holddown and 3 or 0), 0,1,1, 161,370)
					end
				end
			end


			local function simonanimated()
				--lg.draw(simn, plyr.x,plyr.y, 0,1,0.95+math.abs(0.05*math.sin(lt.getTime()*3)), simn:getWidth()/2,simn:getHeight())
				if fightstate=="action" and turns[turnnum]:sub(1,-2)=="plyr" and mainopts[cursel] == "crowbar" then
					--if dmgplus then lg.setColor(0,0,0) end
					if atkdone == "go" then
						local x,y,w,h = animsimn.attack[1]:getViewport()
						lg.draw(animsimn.attack.img, animsimn.attack[1], plyr.x,plyr.y, 0,1,1, w/2,h)
					elseif atkdone == "smash" or atkdone == "hold" then
						local x,y,w,h = animsimn.attack[2]:getViewport()
						lg.draw(animsimn.attack.img, animsimn.attack[2], plyr.x+82,plyr.y, 0,1,1, w/2,h)
					elseif atkdone == "back" then
						local x,y,w,h = animsimn.attack[3]:getViewport()
						lg.draw(animsimn.attack.img, animsimn.attack[3], plyr.x,plyr.y, 0,1,1, w/2,h)
					end
				elseif plyr.ishurt then
					local t = pingpong(plyr.hurtdt/0.075)
					lg.draw(animsimn.hurt[plyr.hurtf], plyr.x-20*t-80,plyr.y+14*t, -math.pi/32,1,1, 130,280)
				elseif plyr.onguard or plyr.isrockn or (fightstate=="action" and turns[turnnum]:sub(1,-2)=="enmy" and atkblocked) then
					local t = pingpong(plyr.rockndt/0.075)
					lg.draw(animsimn.block, plyr.x-14*t,plyr.y+6*t, 0,1,1, 130,280)
				else
					lg.draw(animsimn.stand.img, animsimn.stand[5], plyr.x,plyr.y, 0,1,1, 130,280)
					for i=4,1,-1 do
						lg.draw(animsimn.stand.img, animsimn.stand[i], plyr.x,plyr.y + ((0.25+0.125*(5-i+1)*0.75<=time%1.5 and time%1.5<=0.75+0.125*(5-i+1)*0.75) and 1 or 0), 0,1,1, 130,280)
					end
				end
			end

			if fightstate=="choose" or (fightstate=="action" and turns[turnnum]:sub(1,-2)=="plyr") then
				dadanimated()
				simonanimated()
			else
				simonanimated()
				dadanimated()
			end

			-- lg.setColor(0,0,0)
			-- lg.print("HV: "..enmy.hv,800-166,440)
			-- lg.print("AV: "..enmy.av,800-166,460)
			-- lg.print("fightstate: "..fightstate, 500,460)
			-- lg.setColor(1,1,1)
			
			lg.setFont(numfont)
			lg.draw(statplate,0,-statplate:getHeight()*(1-uipull1))
			lg.print(":"..(plyr.hv>=10 and "" or " ")..plyr.hv, 136,4-statplate:getHeight()*(1-uipull1), 0,2,2)
			lg.print(":"..(plyr.av>=10 and "" or " ")..plyr.av, 136,36-statplate:getHeight()*(1-uipull1), 0,2,2)
			lg.setFont(defaultfont)
			lg.draw(uicrowbar, 34-statplate:getHeight()*(1-uipull2),96)
			lg.draw(uiguard, 34-statplate:getHeight()*(1-uipull3),134)
			lg.setColor(mainoptscolor[cursel])
			lg.draw(uiarrow, 6-statplate:getHeight()*(1-_G["uipull"..(cursel+1)]),64+cursel*38)
			local w,h = 0,0
			if cursel==1 then w,h = uicrowbar:getDimensions()
			elseif cursel==2 then w,h = uiguard:getDimensions()
			end
			local c = {unpack(mainoptscolor[cursel])}
			c[4] = pingpong(lt.getTime()*1.5)
			lg.setColor(c)
			lg.rectangle("fill", 34-statplate:getHeight()*(1-_G["uipull"..(cursel+1)]),58+cursel*38,w,h)
			lg.setColor(1,1,1)
		elseif fightstate == "intro" then
			lg.draw(cheezbols,200,70)
			local time = lt.getTime()

			local ox,oy = 0,0
			if dadintrofnum==1 then     ox,oy = 109,422
			elseif dadintrofnum==2 then ox,oy = 109,422
			elseif dadintrofnum==3 then ox,oy = 143,422
			elseif dadintrofnum==4 then ox,oy = 111,422
			elseif dadintrofnum==5 then ox,oy = 109,438
			elseif dadintrofnum==6 then ox,oy = 109,422
			elseif dadintrofnum==7 then ox,oy = 109,467
			elseif dadintrofnum==8 then ox,oy = 162,495
			elseif dadintrofnum==9 then ox,oy = 165,422
			elseif dadintrofnum==10 then ox,oy = 193,422
			end
			lg.draw(dadintrof[dadintrofnum], enmy.x,enmy.y + (holddown and 1 or 0), 0,1,1, ox,oy)

			lg.draw(animsimn.stand.img, animsimn.stand[5], plyr.x,plyr.y, 0,1,1, 130,280)
			for i=4,1,-1 do
				lg.draw(animsimn.stand.img, animsimn.stand[i], plyr.x,plyr.y + ((0.25+0.125*(5-i+1)*0.75<=time%1.5 and time%1.5<=0.75+0.125*(5-i+1)*0.75) and 1 or 0), 0,1,1, 130,280)
			end
		elseif fightstate == "outro" then
			local time = lt.getTime()

			local function dadanimated()
				if outrof == 1 or outrof == 5 then
					if outrof == 1 then lg.draw(cheezbols,200,70) end
					lg.draw(animdadd.stand.img, animdadd.stand[5], enmy.x,enmy.y + (holddown and 3 or 0), 0,1,1, 161,370)
					for i=4,1,-1 do
						lg.draw(animdadd.stand.img, animdadd.stand[i], enmy.x,enmy.y + ((0.25+0.25*(5-i+1)*0.75<=time%2 and time%2<=0.75+0.25*(5-i+1)*0.75) and 1 or 0) + (holddown and 3 or 0), 0,1,1, 161,370)
					end
				elseif outrof == 2 then
					lg.draw(animdadd.outro[1], enmy.x,enmy.y, 0,1,1, 401,375)
				elseif outrof == 3 then
					lg.draw(animdadd.outro[lt.getTime()%0.0625>0.0625/2 and 2 or 3], enmy.x,enmy.y, 0,1,1, 176,605)
				elseif outrof == 4 then
					lg.draw(animdadd.outro[4], enmy.x,enmy.y, 0,1,1, 392,370)
				end
			end


			local function simonanimated()
				if outrof == 1 or outrof == 2 or outrof == 3 then
					lg.draw(animsimn.stand.img, animsimn.stand[5], plyr.x,plyr.y, 0,1,1, 130,280)
					for i=4,1,-1 do
						lg.draw(animsimn.stand.img, animsimn.stand[i], plyr.x,plyr.y + ((0.25+0.125*(5-i+1)*0.75<=time%1.5 and time%1.5<=0.75+0.125*(5-i+1)*0.75) and 1 or 0), 0,1,1, 130,280)
					end
				elseif outrof == 4 then
					mutiny:stop()
					lg.draw(animsimn.hurt[lt.getTime()%0.0625>0.0625/2 and 2 or 1], plyr.x-80-2400*outrodt,plyr.y+40, -math.pi/32,1,1, 130,280)
					lg.draw(cheezbols, plyr.x+20-2400*outrodt,plyr.y-140, math.pi/512)
				end
			end

			simonanimated()
			dadanimated()

			lg.setFont(numfont)
			lg.draw(statplate,0,-statplate:getHeight()*(1-uipull1))
			lg.print(":"..(plyr.hv>=10 and "" or " ")..plyr.hv, 136,4-statplate:getHeight()*(1-uipull1), 0,2,2)
			lg.print(":"..(plyr.av>=10 and "" or " ")..plyr.av, 136,36-statplate:getHeight()*(1-uipull1), 0,2,2)
			lg.setFont(defaultfont)
			lg.draw(uicrowbar, 34-statplate:getHeight()*(1-uipull2),96)
			lg.draw(uiguard, 34-statplate:getHeight()*(1-uipull3),134)
			lg.setColor(mainoptscolor[cursel])
			lg.draw(uiarrow, 6-statplate:getHeight()*(1-_G["uipull"..(cursel+1)]),64+cursel*38)
			local w,h = 0,0
			if cursel==1 then w,h = uicrowbar:getDimensions()
			elseif cursel==2 then w,h = uiguard:getDimensions()
			end
			local c = {unpack(mainoptscolor[cursel])}
			c[4] = pingpong(lt.getTime()*1.5)
			lg.setColor(c)
			lg.rectangle("fill", 34-statplate:getHeight()*(1-_G["uipull"..(cursel+1)]),58+cursel*38,w,h)
			lg.setColor(1,1,1)
		end

		lg.draw(xbutton, sysW-6,sysH-4, 0,1,1, 94,86)
		if fightstate == "action" then
			if turns[turnnum]:sub(1,-2)=="enmy" then
				lg.draw(notifshield, sysW,sysH-16, 0,1,1, 72,86)
			elseif turns[turnnum]:sub(1,-2)=="plyr" then
				local t = 0
				if mainopts[cursel]=="crowbar" and atkdone=="smash" and 0.475<=hopdt and hopdt<=0.63 then t = 20*math.abs(math.sin(lt.getTime()*120)) end
				lg.draw(notifcrowbar, sysW,sysH-t, 0,1,1, 96,94)
			end
		end
	elseif gamestate == "intro" then
		lg.setColor(0,0,0); lg.rectangle("fill",0,0,sysW,sysH); lg.setColor(1,1,1)

		local i = intro
		lg.draw(panelbg, sysW/2,-50-700*(1-i.pval), 0,1,1, 375,0)
		lg.draw(i["i"..i.part], sysW/2,-700*(1-i.pval), 0,1,1, 325,0)
		if i.part > 1 then
			if intro.winon then
				if intro.right then lg.setColor(0,1,0) elseif intro.wrong then lg.setColor(1,0,0) end
			else lg.setColor(0,0,0) end
			lg.printf(i.typed, sysW/2,122, 160,"center", 0,4,4, 80,20)
			if #i.typed < 17 and not (intro.right or intro.wrong) then lg.setColor(0,0,0, math.abs(math.sin(lt.getTime()*2))); lg.rectangle("fill",sysW/2+16*#i.typed,80, 40,10) end
		end

		lg.setColor(1,1,1)
		lg.draw(textbox, sysW/2,sysH+36*(1-i.tval)*3, 0,3,3, textbox:getWidth()/2,textbox:getHeight())
		lg.setColor(0,0,0)
		if i["t"..i.part] then lg.printf(i.tcur or "", sysW/2,sysH-32*3+36*(1-i.tval)*3+2, 200*3,"center", 0,1,1, 100*3) end
		lg.setColor(1,1,1)

		if i.cantype then
			lg.draw(i.typebutton, sysW-100,sysH-90+4*math.sin(lt.getTime()))
		else
			lg.draw(xbutton, sysW-100,sysH-90)
			lg.draw(notifarrow, sysW-50,sysH-70, 0,3,3, notifarrow:getWidth()/2,notifarrow:getHeight()/2)
		end
	elseif gamestate == "heartbeat" then
		if heartbeatf<4 then
		local t = {{412,580}, {1064,140}, {574,100}}
			lg.draw(heartbeatbg, sysW/2,sysH/2, 0,3-0.5+heartbeatdt/3,nil, t[heartbeatf][1],t[heartbeatf][2])
			lg.setColor(0,0,0,1-pingpong(math.min(1.25*math.sin(clamp(heartbeatdt,0,2)/2*math.pi),1)))
			lg.rectangle("fill",0,0,sysW,sysH)
			lg.setColor(1,1,1)
		else
			lg.setColor(0,0,0)
			lg.rectangle("fill",0,0,sysW,sysH)
			lg.setColor(1,1,1)
		end
	elseif gamestate == "credits" then
		lg.setColor(0,0,0); lg.rectangle("fill",0,0,sysW,sysH)
		lg.setColor(1,1,1); lg.draw(credits[creditsframe], sysW/2,sysH/2, 0,1,1, credits[creditsframe]:getWidth()/2,credits[creditsframe]:getHeight()/2)
	elseif gamestate == "easteregg" then
		if eastereggnum == 1 or eastereggnum == 2 then lg.draw(eastereggasset) end
	else
		local s = "gamestate \""..gamestate.."\" has no programming!"
		lg.printf(s, 400,240, 480,"center", 0,2,2, 240,16)
		lg.printf("<:::", 400,280, 480,"center", 0,2,2, 240,16)
		local w,h = font:getWidth("<:::")*2,16*2
		lg.setColor(1,0,0,0.5); lg.rectangle("fill", 400-w/2,280-h/2-20, w,h); lg.setColor(1,1,1)
	end

	lg.setColor(0,0,0,blackoutdt); lg.rectangle("fill", 0,0, sysW,sysH)

	if _DEBUG then
		lg.setColor(0,0,0,0.5); lg.rectangle("fill",0,0,80,20)
		lg.setColor(0,1,0); lg.print("fps : "..lt.getFPS(),2,4)
		lg.setColor(1,1,1)
	end
end


-- love2d event functions
function love.keypressed(k)
	--if k=="p" then _DEBUG = not _DEBUG end
	if gamestate == "overworld" then
		if panels.isActive() then panels.keypressed(k)
		else plyr.keypressed(k) end
	elseif gamestate == "intro" then
		local i = intro
		local f = function()
			i.part = i.part + 1
			if i.part > 6 then
				tostate = "overworld"
				gamestate = "overworld"
			end
			i.tcur = ""
			i.tpos = 0
			i.t_dt = 0
			if i.cantype then
				if checkeasterstring(i.typed) then return end
				intro.check()
			else
				if i.part == 2 then i.cantype = true end
			end
		end
		if (k=="x" and not i.cantype) or ((k=="return" or #i.typed>=18) and i.cantype and not i.waittype and i.part~=5) then
			if i["t"..i.part] then
	 			if i.tpos==#i["t"..i.part] then
	 				f()
				else
					i.tpos = #i["t"..i.part]
					i.tcur = i["t"..i.part]
				end
			else
				f()
			end
		elseif k=="backspace" and i.cantype and not i.waittype and i.part~=5 then
			if #i.typed ~= 0 then i.typed = i.typed:sub(1,-2) end
		end
	elseif gamestate == "strife" then
		if fightstate=="choose" then
			if k=="up" then
				cursel = cursel - 1; if cursel <= 0 then cursel = #mainopts end
			elseif k=="down" then
				cursel = cursel + 1; if cursel >= #mainopts+1 then cursel = 1 end
			elseif k=="x" then
				fightstate = "action"
				if mainopts[cursel] == "guard" then
					plyr.onguard = true
					turnnum = turnnum + 1
				end
			end
		elseif fightstate=="action" then
			if turns[turnnum]:sub(1,-2)=="plyr" and mainopts[cursel]=="crowbar" and atkdone=="smash" then
				if k=="x" and 0.475<=hopdt and hopdt<=0.63 then
					dmgplus = true
				end
			elseif turns[turnnum]:sub(1,-2)=="enmy" then
				if k=="x" and plyr.canguard and not plyr.ishurt then
					plyr.onguard = true
					plyr.canguard = false
				end
			end
		end
	end
end

function love.textinput(t)
	if gamestate == "intro" and intro.cantype and not intro.waittype and intro.part~=5 then
		if not intro.cantype2 then
			intro.cantype2 = true
			return
		end
		local i = intro
		t = t:upper()
		if ("ABCDEFGHIJKLMNOPQRSTUVWXYZ "):find(t) then
			i.typed = i.typed .. t
		end
		if #i.typed>=18 then
			love.keypressed("return")
		end
	end
end

function love.mousepressed(x,y, b)
if b==1 then -- ignores all other mouse buttons, we dont need em
	if gamestate == "title" then
		local f = {
			function() tostate = "intro" end,
			function() --[[tostate = "options"]] end,
			function() --[[tostate = "credits"]] end,
			function() le.quit() end,
		}
		for i,v in ipairs({"start","options","credits","quit"}) do
			if (38<=x and x<font:getWidth(v)*2+40) and (260+40*i<=y and y<260+40*i+font:getHeight(v)*2) then
				f[i]()
				break
			end
		end
	elseif gamestate == "overworld" then
		if sysW-100<=x and x<=sysW-4 and sysH-98<=y and y<=sysH-4 then
			if panels.isActive() then panels.keypressed("x")
			else plyr.keypressed("x") end
		end
	end
end end

function love.quit(a) print("goodbye!", a) end


function checkeasterstring(s)
	s = s:lower()
	eastereggnum = 0
	if s=="dick werepaw" then
		eastereggnum = 1
		eastereggasset = lg.newImage("assets/gfx/eastereggs/dickwerepaw.png")
	elseif s=="dedcollision" then
		eastereggnum = 2
		eastereggasset = lg.newImage("assets/gfx/eastereggs/dedcollision.png")
	end

	if eastereggnum ~= 0 then
		tostate = "easteregg"
		gamestate = "easteregg"
	end

	return eastereggnum ~= 0 
end

-- extra functions
function clamp(x, a,b) return (x<a and a) or (x>b and b) or x end

function sign(x) return (x<0 and -1) or (x>0 and 1) or 0 end

function pingpong(x) return 1 - math.abs(1 - x % 2) end

-- https://github.com/rxi/lume/
local ripairs_iter = function(t, i)
	i = i - 1
	local v = t[i]
	if v ~= nil then return i, v end
end
function ripairs(t) return ripairs_iter, t, (#t + 1) end

function orderY(a,b) return a.y < b.y end
