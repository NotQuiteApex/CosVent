if false then
	maps = {
		["bedroom"] = {
			bg = lg.newImage(p.."owroom1/bg.png"), -- the room itself
			--ref = lg.newImage(p.."owroom1/ref.png"), -- only for lining up objects from art to game
			x = 80, y = 700,
			ox = 127, oy = 785,
			w = 7, h = 7, -- dont use this, its for debugging
			xb = 800, yb = 460, -- camera bounds
			back_ = {  -- objects that are always "behind" the player
				{path="owroom1/arcadecabinet.png", x=556,y=-262,ox=18,oy=322, coll={9,324, 136,384, 261,324}},
				{path="owroom1/gitcard.png", x=888,y=-166,ox=48,oy=46, --[[coll={1,18, 60,-7, 99,66, 40,96}]]}
			},
			z_way = {  -- objects whose draw order are determined by the player's y coord
				{path="owroom1/serverrack.png", x=1013,y=11,ox=5,oy=240, coll={5,235, 155,310, 149,153}},
				{path="owroom1/deskchair.png", x=764,y=156,ox=135,oy=285, coll={240,282, 129,332, 20,278, 132,241}},
			},
			front = {  -- objects that are always "in front of" the player
				{path="owroom1/bed.png", x=25,y=2,ox=1,oy=236, coll={2,235, 327,396, 531,294, 210,136}},
				{path="owroom1/desk.png", x=417,y=201,ox=12,oy=278, coll={12-2*18,280-18, 399,330, 155-2*18,208-18}},
			},
			collidables = { -- its just walls (or anything with no image)
				map_calcWall(-194,0, 9,1),
				map_calcWall(574,384, 9,1),
				map_calcWall(-194,0, 1,9),
				map_calcWall(574,-384, 1,9)
			},
			interactables = { -- special collidables that have functions triggered on a button press
				{x=216,y=-108, pd1=-1,pd2=1, coll=map_calcWall(0,0, 1,21, 32,16), func=function() panels.addToQueue("bed") end},
				{x=530,y=-256, pd1=1,pd2=2, coll=map_calcWall(0,0, 1,8, 32,16), func=function() panels.addToQueue("arcadecase") end},
				{x=674,y=-200, pd1=-1,pd2=2, coll=map_calcWall(0,0, 8,1, 32,16), func=function() panels.addToQueue("arcadecaseside") end},
				{x=1000,y=15, pd1=1,pd2=2, coll=map_calcWall(0,0, 1,9, 32,16), func=function() panels.addToQueue("serverrack") end},
				{x=526,y=112, pd1=-1,pd2=1, coll=map_calcWall(0,0, 1,16, 32,16), func=function() panels.addToQueue("computer") end},
			},
			triggerzones = { -- special collidables that trigger associated functions
				{x=840,y=-212, coll={1,18, 60,-7, 99,66, 40,96}, func=function()
					if not mapg.gitcard then mapg.gitcard=true; maps.bedroom.back_[2]=nil; panels.addToQueue("dadcard") end
				end}, -- gitcard trigger
				{x=846,y=-246, coll=map_calcWall(0,0, 1,10, 32,16), func=function()
					tomap = "hallway" --maps_load("hallway")
					tox,toy = 370+32,590+16
					--if not mapg.ended then mapg.ended=true; tostate="credits" end
				end}, -- door
			},
		},
		["hallway"] = {
			bg = lg.newImage(p.."owroom2/bg.png"),
			x=90,y=510,
			ox=90,oy=556,
			w=2,h=8,
			xb=374,yb=520,
			collidables = {
				map_calcWall(-194,0, 5,1),
				map_calcWall(574+148-44,384+40+22, 5,1),
				map_calcWall(-160,28, 1,7),
				map_calcWall(574-320-96-40,-384+160+48+20, 1,10)
			},
			interactables = {
				{x=216+64-24,y=-108+32, pd1=1,pd2=2, coll=map_calcWall(0,0, 1,12, 32,16), func=function() panels.addToQueue("circuit") end},
				{x=216+64*5.2-24,y=-108+32*5.2, pd1=1,pd2=2, coll=map_calcWall(0,0, 1,8, 32,16), func=function() panels.addToQueue("familyphoto") end},
				{x=216+64*8.5-24,y=-108+32*8.5, pd1=1,pd2=2, coll=map_calcWall(0,0, 1,10, 32,16), func=function() panels.addToQueue("daddoor") end},
			},
			triggerzones = {
				{x=136,y=90, coll=map_calcWall(0,0, 1,9, 32,16), func=function()
					tomap = "bedroom" --maps_load("bedroom")
					tox,toy = 956,534
				end}, -- ezra's door
				{x=136+32*14.5,y=90+16*14.5, coll=map_calcWall(0,0, 1,10, 32,16), func=function()
					tomap = "tvroom" --maps_load("tvroom")
					tox,toy = 550,1060
				end}, -- stairs
			},
		},
		["tvroom"] = {
			bg = lg.newImage(p.."owroom3/bg.png"),
			--ref = lg.newImage(p.."owroom3/ref.png"),
			x=64,y=792,
			ox=64,oy=792,
			w=7,h=6,
			xb=650,yb=710,
			back_ = {
				{path="owroom3/tvset.png", x=308,y=-139,ox=0,oy=378, coll={-6,373, 59+16,420-8, 460,220}}
			},
			z_way = {
				{path="owroom3/lamp.png", x=1030,y=-60,ox=11,oy=291, coll={12,292, 103,337, 190,286, 105,240}},
				{path="owroom3/table.png", x=542,y=-26,ox=12,oy=190, coll={12,189, 156,261, 348,164, 204,90}},
				{path="owroom3/couch.png", x=662,y=83,ox=3,oy=215, coll={3,217, 151,290, 405,167, 251,91}},
				{path="owroom3/stairs.png", x=396,y=206,ox=348,oy=247}
			},
			collidables = {
				map_calcWall(-194,0, 9,1),
				map_calcWall(574-64*3+22-96,380+48, 10,1),
				map_calcWall(574-64*3+22-84+96,380+96, 1,-4),
				map_calcWall(-194,0, 1,5.2),
				map_calcWall(574+24,-384-12, 1,9)
			},
			interactables = {
				{x=216+96+100+32,y=-140, pd1=-1,pd2=2, coll=map_calcWall(0,0, 12,1, 32,16), func=function() panels.addToQueue("tvset") end},
				{x=216+64*7-32+8,y=-108+32*6+24-16, pd1=1,pd2=2, coll=map_calcWall(0,0, 1,9, 32,16), func=function() panels.addToQueue("couch") end},
				{x=216+64*5,y=-108+32*5-96+24, pd1=1,pd2=2, coll=map_calcWall(0,0, 1,9, 32,16), func=function() panels.addToQueue("table") end},
				{x=216+64*5,y=-108+32*5-90, pd1=1,pd2=1, coll=map_calcWall(0,0, 12,1, 32,16), func=function() panels.addToQueue("table") end},
				{x=216+64*6,y=-108+32*12, pd1=1,pd2=1, coll=map_calcWall(0,0, 12,1, 32,16), func=function() panels.addToQueue("frontdoor") end},
			},
			triggerzones = {
				{x=136+32*2.5,y=90+16*12, coll=map_calcWall(0,0, 10,1, 32,16), func=function()
					tomap = "hallway"--maps_load("hallway")
					tox,toy = 818,848
				end}, -- stairs
				{x=28,y=-24, coll=map_calcWall(0,0, 14,1, 32,16), func=function()
					if not mapg.ended then mapg.ended=true; tostate="credits" end
				end}, -- kitchen
			},
		},
		["kitchen"] = {},
		["bathroom"] = {},
		["basement"] = {},
	}

	-- fix object offsets with bg coords
	for _,map in ipairs({"bedroom","hallway","tvroom"}) do
		local m = maps[map]
		for _,k in ipairs({"back_","z_way","front","interactables","triggerzones"}) do
			if m[k] then for i,v in ipairs(m[k]) do
				if v.x then
					v.x = v.x + m.x
					v.y = v.y + m.y
				end
			end end
		end
		if m.collidables then for _,v in ipairs(m.collidables) do
			for i=1,#v,2 do
				v[i]   = v[i]   + m.x
				v[i+1] = v[i+1] + m.y
			end
		end end
	end
end