local lg = love.graphics

panels = {}

panelbg = lg.newImage("assets/gfx/panelbg.png")
textbox = lg.newImage("assets/gfx/textbox.png")

local tcur = ""
local tpos = 0
local t_dt,tmax = 0,1/30
local pval,tval = 1,0.5

local blackness = 1
local canwhite = true

local txtg = {}
local queue = {"wake1"}
local panel = {}
panel = {
	-- bedroom
	["wake1"] = {txt="Your name is SIMON, though many of your friends call you by your middle name, EZRA. You've woken up in the early hours of a humid summer day, which also happens to be your BIRTHDAY. Might as well stay up for a bit. Various ELECTRONICS are strewn across your room, given to you as gifts by your DAD.",
	funcexit = function()
		table.insert(queue, 1, "wake1")
		panel.wake1.txt = "You love to read and watch SCI-FI MEDIA. You have a great aspiration to one day develop VIDEO GAMES for a living, though currently you REALLY SUCK AT IT. For now, you're just stuck with whatever new piece of technology your DAD gives you.\n\nWhat will you do?"
		panel.wake1.funcexit = function()end
	end},
	--[[
	["wake1"] = {imgpath = "wake1.png",
	txt = "On this day, in the middle of summer, in the first half of July, a young boy sits in his bed on the morning of his birthday.\n\nHe is incredibly tired.", --\nCare to remind him of his name?
	-- funcupdt = function(dt) end, -- function ran during showing
	-- funcdraw = function() end, -- function ran instead of drawing the panel
	-- functxtinput = function() end, -- text input handling
	funcexit = function() canwhite = true end, -- function ran on exit of text
	},
	--]]

	["bed"] = {txt="This is your dog LUDO! He's so cute when he sleeps on your bed. Better not disturb him or else he might wake up groggy.",
	funcexit = function()
		panel.bed.txt = "Look at em.\n\nSuch a sweet lil pupper.\n\nYou wonder what he's dreaming about."
		panel.bed.funcexit = function() panel.bed.txt = "\nGood dog.\n\n\nBest friend." end
	end
	},

	["arcadecase"] = {imgpath = "arcase1.png",
	txt="Here it is, the best cabinet in the house. You helped your DAD build this thing about a year ago for your last birthday, you wonder why you haven't touched it in so long...",
	funcexit = function()
		table.insert(queue, 1, "arcadecase")
		panel.arcadecase.txt = "Oh.\nThis is why.\n\nYou should probably tell your DAD at some point."
		panel.arcadecase.imgpath = "arcase2.png"
		mapg.arcadeborkd = true
		currentmapdata.back[1].img:release(); currentmapdata.back[1].img = lg.newImage("assets/gfx/rooms/act1part1/bedroom/arcadecabinetborkd.png")
		panel.arcadecase.funcexit = function()
			panel.arcadecase.imgpath = "arcase3.png"
			panel.arcadecase.txt = "Yup. Still broken."
			panel.arcadecase.funcexit = function()end
		end
	end
	},
	["arcadecaseside"] = {txt="You decorated the cabinet with some AWESOME STICKERS. They're from an AWESOME GAME FRAMEWORK that is super cool to use.\n\n(love2d.org)"},

	["serverrack"] = {txt="This is your server rack that your DAD gave to you one winter. It's mostly been a larger hard drive and has pretty much been collecting only dust.",
	funcexit = function()
		table.insert(queue, 1, "serverrack")
		panel.serverrack.txt = "Oh! Here's where you left your crowbar! You misplaced it before you went to bed. It's a good thing you found it, you never know when you'll have to bash some alien brains in.\n\nYou add ONE CAPTCHALOGUE CARD to your sylladex."
		panel.serverrack.funcexit = function()
			mapg.gotcrowbar = true
			currentmapdata.zway[1].img:release(); currentmapdata.zway[1].img = lg.newImage("assets/gfx/rooms/act1part1/bedroom/serverracknocro.png")
			panel.serverrack.txt = "You wonder if this dust collector is even plugged in."
			crowbarget = true
			crox = plyr.x
			croy = plyr.y
			panel.serverrack.funcexit = function()end
		end
	end
	},

	["computer"] = {txt="Oh no.\n\nYou should probably get this fixed...",imgpath="computertemp.png"},

	["dadcard"] = {txt="Oh hey, this captchalogue card contains a note from your DAD. It reads:\n\nHAPPY BIRTHDAY KIDDO, I DON'T KNOW IF YOU'RE AWAKE DURING THIS STORM BUT COME ON DOWN WHEN YOU'RE READY FOR YOUR BIRTHDAY TREAT!",
	funcexit = function()
		table.insert(queue, 1, "dadcard")
		panel.dadcard.txt = "You wonder if he's talking about that virtual mining rig he keeps pestering you about. It would be fun to build something with him again, with some kickin tunes too.\n\nYou add ONE CAPTCHALOGUE CARD to your sylladex."
		panel.dadcard.funcexit = function() gitcardget=true; gitx,gity=plyr.x,plyr.y; panel.dadcard.funcexit = function()end end
	end},


	-- hallway
	["circuit"] = {txt="\nYou stare at the fine lines of this framed picture of a PRINTED CIRCUIT BOARD.\n\nYou don't know why your dad put this up here."},
	["familyphoto"] = {txt="\nThis is you and your DAD from years ago. You're postive that he still has that same shirt. Your DAD likes to tease you about how your COOKY HUBBLE HAIR has grown with you over the years, and you tend to make a similar comment about his beard."},
	["daddoor"] = {txt="\nThe door isn't locked, but you and your DAD usually ask each other before entering the other's room. You don't think he's really hiding anything in there, but it's always tempting to sneak in uninvited."},

	-- tvroom
	["couch"] = {txt="\nThis is not a couch you'd be caught sleeping on, otherwise you'd be 2 feet deep into the cushions by morning."},
	["table"] = {txt="\nYou're not sure what you're more disgusted by, the fact that you and your DAD are always putting your feet on top of this or the countless amounts of snack foods that have also sat on this same plane."},
	["frontdoor"] = {txt="\nYou see no reason to go outside currently. Unless you want to be completely drenched and possibly electrecuted."},
	["tvset"] = {txt="This thing can only display up to 1080p. Absolutely pathetic. Your 15 inch monitor does the exact same at an even higher refresh rate. Totally disgusting.\n\nNot bad for MOVIE NIGHT though."},
	["lamp"] = {txt="NO! YOU WILL NOT SMASH THE LAMP! NEVER!"},
	["warncrowbar"] = {txt="You hear noises coming from the kitchen, you think it might be your DAD.\nDon't wanna go in unarmed, though."},
	["endmessage"] = {txt="Your dad sends you flying back with his incredible CHEESE TOSS and you end up back in the TV ROOM. You laugh as you get up and dust yourself off, and you give your DAD a thumbs up. He apologizes and gives a thumbs up right back to you.",
	funcexit = function()
		tostate = "credits"
	end}
}

function panels.update(dt)
	if panels.isActive() then
		assert(panel[queue[1]]~=nil, "No panel data for \""..queue[1].."\"!")
		local v = panel[queue[1]]

		if v.funcupdt then v.funcupdt(dt) end

		if v.imgpath then
			if not v.img then v.img = lg.newImage("assets/gfx/panels/"..v.imgpath) end
			if pval~=1 then pval = pval>0.999 and 1 or pval + (1-pval)*dt*8 end
		else 
			if pval~=0 then pval = pval<0.001 and 0 or pval + (0-pval)*dt*8 end
		end

		if v.txt then
			if tval~=1 then tval = tval>0.999 and 1 or tval + (1-tval)*dt*8 end
			if tpos < #v.txt then
				t_dt = t_dt + dt
				for i=1,5 do if t_dt>=tmax then
					t_dt = t_dt - tmax
					tpos = tpos + 1
					tcur = tcur .. v.txt:sub(tpos,tpos)
				end end
			end
		else 
			if tval~=0 then tval = tval<0.001 and 0 or tval + (0-tval)*dt*8 end
		end
	else
		if pval~=0 then pval = pval<0.001 and 0 or pval + (0-pval)*dt*8 end
		if tval~=0 then tval = tval<0.001 and 0 or tval + (0-tval)*dt*8 end
	end

	if canwhite and blackness > 0 then blackness = blackness - dt end
end

function panels.draw()
	--lg.setColor(0,0,0); lg.rectangle("fill",0,0,sysW,sysH); lg.setColor(1,1,1)
	local k,v = queue[1],panel[queue[1]]
	
	lg.setColor(0,0,0,blackness); lg.rectangle("fill",0,0,sysW,sysH); lg.setColor(1,1,1)

	lg.draw(panelbg, sysW/2,-50-700*(1-pval), 0,1,1, 375,0)
	if k and v.img then lg.draw(v.img, sysW/2,-700*(1-pval), 0,1,1, 325,0) end
	if k and v.funcdraw then v.funcdraw() end

	lg.setColor(1,1,1,1)
	lg.draw(textbox, sysW/2,sysH+36*(1-tval)*3, 0,3,3, textbox:getWidth()/2,textbox:getHeight())
	lg.setColor(k and v.color or {0,0,0})
	lg.printf(tcur, sysW/2,sysH-32*3+36*(1-tval)*3+2, 200*3,"center", 0,1,1, 100*3)
	lg.setColor(1,1,1)
end

function panels.keypressed(k) if panels.isActive() then
	if k=="x" then
		local v = panel[queue[1]]
		local f = function()
			if v.img then v.img:release(); v.img=nil end
 			if v.funcexit then v.funcexit() end
			table.remove(queue,1)
			tcur = ""
			tpos = 0
			t_dt = 0
		end

		if v.txt then
 			if tpos==#v.txt then
 				f()
			else
				tpos = #v.txt
				tcur = v.txt
			end
		else
			f()
		end
	end
end end

function panels.textinput(a) end

function panels.isActive()
	return queue[1]~=nil
end

function panels.addToQueue(name)
	table.insert(queue,1,name)
end