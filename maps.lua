local lg = love.graphics
local lf = love.filesystem

currentmap = "bedroom"
tomap = currentmap
currentmapdata = nil
maptox,maptoy = 0,0 -- coords for the future
outsiderain = {}
outsideraindt = 0
outsiderainmax = 0.05
mapsdarkness = 0
mapstile = lg.newImage("assets/gfx/tile.png")

function map_calcWall(x,y, w,h, tw,th)
	tw = tw and tw/2 or 192/2
	th = th and th/2 or 96/2
	t = {x,y, w*tw+x,-(w+1)*th+y+th, (w+h)*tw+x,(h+1)*th-(w+1)*th+y, h*tw+x,(h)*th+y}
	return t
end

local p = "assets/gfx/" -- long prefix
mapg = {} -- a space for interactables and triggerzones variables

collidables = {}
triggerzones = {}
interactables = {}

function maps_load(newmap, actstr)
	assert(newmap~=nil,"newmap arg must be filled, it cannot be nil!")
	assert(type(newmap)=="string", "newmap arg must be a string!")
	assert(type(actstr)=="string", "actsrt arg must be a string!")
	assert(lf.getInfo("assets/gfx/rooms/"..actstr.."/"..newmap..".json"), "map data doesnt exist!")
	--assert(maps[newmap]~=nil, "map \""..newmap.."\" does not exist!")
	
	if currentmapdata then
		-- release all data of stored images
		local m = currentmapdata
		for _,k in ipairs({"back","zway","frnt"}) do
			if m[k] then -- if any of those elements exist...
				for i,v in ipairs(m[k]) do -- go through them and remove their images
					if v.img then v.img:release(); v.img = nil end
				end
			end
		end

		-- delete all current collision
		for _,k in ipairs({"collidables","triggerzones","interactables"}) do
			local v
			for i=1,#_G[k] do
				v = _G[k][i]
				v:setUserData(nil)
				hc.remove(v)
				_G[k][i] = nil
			end
		end
		hc.resetHash()
	end

	currentmap = newmap
	currentmapdata = json.decode(lf.read("assets/gfx/rooms/"..actstr.."/"..newmap..".json"))
	-- map data really shouldnt be in the gfx folder
	-- but ive been too busy to move it ¯\_(ツ)_/¯

	local m,c = currentmapdata,collidables

	if m.bg then
		m.bg = lg.newImage("assets/gfx/rooms/"..actstr.."/"..newmap.."/"..m.bg)
	else
		error("you need a background image!")
	end

	for _,k in ipairs({"back","zway","frnt"}) do
		if m[k] then
			for i=1,#m[k] do
				m[k][i] = json.decode(lf.read("assets/gfx/rooms/"..actstr.."/"..newmap.."/"..m[k][i]..".json"))
				if m[k][i].fn then
					m[k][i].fn = m[k][i].fn:gsub("this",("currentmapdata[%q][%i]"):format(k,i))
					loadstring(m[k][i].fn)()
				end
				if m[k][i].path then
					m[k][i].img = lg.newImage("assets/gfx/rooms/"..actstr.."/"..newmap.."/"..m[k][i].path)
				end
				if m[k][i].coll then
					c[#c+1] = hc.polygon(unpack(m[k][i].coll))
					c[#c]:move(m[k][i].x-m[k][i].ox,m[k][i].y-m[k][i].oy)
					c[#c]:move(m.x,m.y)
				end
			end
		end
	end

	for _,k in ipairs({"interactables","triggerzones","collidables"}) do
		if m[k] then
			local l,e
			for i=1,#m[k] do
				l,e = loadstring(m[k][i])
				if e then error(e) end
				m[k][i] = l()
			end
		end
	end

	-- load collision
	local m,c,t,io = currentmapdata,collidables,triggerzones,interactables
	if m.collidables then for i,v in ipairs(m.collidables) do
		c[#c+1] = hc.polygon(unpack(v))
		c[#c]:move(m.x,m.y)
	end end
	if m.triggerzones then for i,v in ipairs(m.triggerzones) do
		t[#t+1] = hc.polygon(unpack(v.coll))
		t[#t]:move(v.x,v.y)
		t[#t]:move(m.x,m.y)
		t[#t]:setUserData(v.func)
	end end
	if m.interactables then for i,v in ipairs(m.interactables) do
		io[#io+1] = hc.polygon(unpack(v.coll))
		io[#io]:move(v.x,v.y)
		io[#io]:move(m.x,m.y)
		io[#io]:setUserData({pd1=v.pd1,pd2=v.pd2,func=v.func})
	end end
end
maps_load(currentmap,"act1part1")

function maps_update(dt)
	if currentmap~=tomap then
		if mapsdarkness<1 then mapsdarkness = mapsdarkness + dt end
		if mapsdarkness>=1 then
			currentmap = tomap
			maps_load(currentmap,"act1part1") -- just assume its act1part1 for now
			plyr.x,plyr.y = maptox,maptoy
			outsiderain = {}
		end
	else
		if mapsdarkness>0 then mapsdarkness = mapsdarkness - dt end
	end
end

function maps_drawOBJ(v)
	if v.path then
		lg.draw(v.img, v.x+currentmapdata.x,v.y+currentmapdata.y, 0,1,1, v.ox,v.oy)
	end
end
