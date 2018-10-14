-- OBJPaint, collision creation tool
-- from an older prototype, repurposed

function love.load()
	lg = love.graphics
	lk = love.keyboard
	lm = love.mouse

	lg.setBackgroundColor(127,127,127)
	lg.setPointSize(4)
	lg.setLineStyle('rough')
	lg.setLineWidth(1)
	lk.setKeyRepeat(true)
	io.stdout:setvbuf("no")

	objState = 'origin' -- origin, paint, name, zheight
	objPnts = {c=1,ox=0,oy=0, {z='0'}}
	objFile = nil
	objText = 'Drop an image to edit'

	objUI = lg.newImage('objpaintUI.png')
end

function love.updt() end

function love.draw()
	lg.setColor(0,0,0)
	lg.print('ID = '..objText,34,0)
	lg.print('Z  = '..objPnts[objPnts.c].z,34,16)
	lg.print('STATE = '..objState,272,0)
	lg.print('LAYER = '..objPnts.c,272,16)

	lg.setColor(255,255,255); lg.draw(objUI,0,0)
	if objFile then
		lg.push()
		lg.translate(32,32)

		lg.setColor(63,63,63,63);lg.rectangle('fill',0,0,objFile:getDimensions())
		lg.setColor(255,255,255);lg.draw(objFile,0,0)
		if lk.isDown('lshift','rshift') then lg.setColor(63,63,63,63);lg.rectangle('fill',0,0,objfile:getDimensions()) end

		for i,v in ipairs(objPnts) do
			lg.setColor(0,200,0)
			if #v>=6 then lg.polygon('line',v) end
			if #v>=2 then lg.points(v) end
			local t,z = {unpack(v)},tonumber(v.z) or 0
			for i=1,#t do  if i%2==0 then t[i] = t[i] - z end  end
			lg.setColor(0,200,200)
			if #v>=6 then lg.polygon('line',t) end
			if #v>=2 then lg.points(t) end
		end
		lg.points(objPnts.ox,objPnts.oy)

		lg.pop()
	end

	lg.setColor(0,200,0); lg.points(lm.getPosition())
end

function love.filedropped(f)
	love.load()
	objFile = lg.newImage(f)
	local t = f:getFilename():split('\\')
	objText = t[#t]:sub(1,-5)
end

function love.keypressed(k)
	if k == 'escape' then return love.event.quit() end -- quit
	if lk.isDown('lctrl','rctrl') then
		if k == 's' then
			file = io.open('saves/'..objText..'.objdat','w+')
			local t = 'id = '..objText..',\nox='..objPnts.ox..',oy='..objPnts.oy..',\npnts = {\n'
			for i=1,#objPnts do
				t=t..'{ z='..objPnts[i].z..', '
				for x=1,#objPnts[i],2 do  t=t..objPnts[i][x]..','..objPnts[i][x+1]..', '  end 
				t=t..' },\n'
			end
			t=t..'}'
			file:write(t)
			file:close()
		end
	elseif objState == 'name' then
		if k=='backspace' then
			objText = objText:sub(1,-2)
		end
	elseif objState == 'zheight' then
		if k=='backspace' then
			objPnts[objPnts.c].z = objPnts[objPnts.c].z:sub(1,-2)
		end
	end
end
function love.textinput(t)
	if not lk.isDown('lctrl','rctrl','lalt','ralt') then
		if objState == 'name' then objText = objText..t end
		if objState == 'zheight' then objPnts[objPnts.c].z = objPnts[objPnts.c].z..t end
	end
end
function love.mousepressed(x,y)
	if inBox(x,y, 0,0,32,224) then
		if inBox(x,y, 0,0,32,32) then print("E S C A P E")--require 'main'; love.load()
		elseif inBox(x,y,32, 0,256,32)then objState = 'name'
		elseif inBox(x,y, 0,32,32,32) then objState = 'origin'
		elseif inBox(x,y, 0,64,32,32) then objState = 'paint'
		elseif inBox(x,y, 0,96,32,32) then objState = 'paint'; objPnts[#objPnts+1] = {z='0'}; objPnts.c = #objPnts
		elseif inBox(x,y,0,128,32,64) then
			if inBox(x,y,0,128,32,32) then objPnts.c = objPnts.c + 1 end
			if inBox(x,y,0,160,32,32) then objPnts.c = objPnts.c - 1 end
			if objPnts.c>#objPnts then objPnts.c = 1 end
			if objPnts.c<1 then objPnts.c = #objPnts end
		elseif inBox(x,y,0,192,32,32) then objState = 'zheight'
		end
	else
		if objState == 'paint' then
			objPnts[objPnts.c][ #objPnts[objPnts.c]+1 ] = x - 32
			objPnts[objPnts.c][ #objPnts[objPnts.c]+1 ] = y - 32
		elseif objState == 'origin' then
			objPnts.ox = x - 32
			objPnts.oy = y - 32
		end
	end
end


function inBox(a,b, x,y,w,h) return (a >= x and b >= y and a <= x+w and b <= y+h) end

function string:split(delimiter) -- https://gist.github.com/jaredallard/ddb152179831dd23b230
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end