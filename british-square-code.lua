function _init()
	tilestatus = {
		empty = 0,
		red = 1,
		redb = 2,
		blueinv = 7,
		blue = 4,
		blueb = 8,
		redinv = 13}
	sprites = {
		p1 = 17,
		p2 = 18,
		red = 1,
		blue = 2,
		p1point = 33,
		p2point = 34,
		invalid = 49}
	ox = 5*8
	oy = 4*8
	bx = ox + 32
	by = oy + 32
	timer = 0
	firstturn = true
	
	player = {
		isactive = true,
	 isvalid = true,
	 sprite = sprites.p1,
		x=ox,
		y=oy}

	buildgrid()
end

function _update()
	doturn()

end

function _draw()
	cls()
	map()
	drawgrid()
	drawplayer()
end

function doturn()

 if not player.isactive then
  compturn()
  return
 end
	-- only move one dir at a time
	if (btnp(⬅️)) player.x-=8
	if (btnp(➡️)) player.x+=8
	if (btnp(⬆️)) player.y-=8
	if (btnp(⬇️)) player.y+=8
	
	-- keep player in bounds
	if (player.x<ox) player.x = ox
	if (player.y<oy) player.y = oy
	if (player.x>bx) player.x = bx
	if (player.y>by) player.y = by

 setisvalid()

	if btnp(🅾️) and player.isactive
	 and player.isvalid then
		placetile(playerrow(),playercol())
		player.isactive = not hasvalidspaces(tilestatus.blueinv)	
  firstturn = false
	end
end

function drawplayer()
	if player.isactive then
		spr(player.sprite, player.x, player.y)
	end
end

function placetile(row, col)
	-- get correct color
	local tile = tilestatus.red
	local block = tilestatus.redb
	if not player.isactive then
	 tile = tilestatus.blue
	 block = tilestatus.blueb
	end
	-- add tile to grid
	grid[row][col] = tile
 --printh("row "..row.." col "..col)
	-- set blocked tiles
	if row != 1 then
	 grid[row-1][col] = grid[row-1][col] | block
	end
	if row != 5 then
	 grid[row+1][col] = grid[row+1][col] | block
	end
	if col != 1 then
	 grid[row][col-1] = grid[row][col-1] | block
 end
 if col != 5 then
	 grid[row][col+1] = grid[row][col+1] | block
	end
end

function drawgrid()
	for r=0, 4 do
		for c=0, 4 do
			local tile = grid[r+1][c+1]
			if tile & tilestatus.red == tilestatus.red then
			 --place red
			 spr(sprites.red, ox+(8*c), oy+(8*r))
			end
			if tile & tilestatus.blue == tilestatus.blue then
			 --place blue
			 spr(sprites.blue, ox+(8*c), oy+(8*r))
			end
		end
	end
end

function buildgrid()
	grid = {}
	for i=1, 5 do
	 grid[i] = {
	 tilestatus.empty,
	 tilestatus.empty,
	 tilestatus.empty,
	 tilestatus.empty,
	 tilestatus.empty,
	 }
	end
	
end

function playercol()
	return ((player.x - ox) / 8) + 1
end

function playerrow()
	return ((player.y - oy) / 8) + 1
end

function setisvalid()
	local row = playerrow()
	local col = playercol()
	local tile = grid[row][col]
	if tile & tilestatus.redinv == 0
	 then
	 player.isvalid = true
		player.sprite = sprites.p1
	else
		player.isvalid = false
		player.sprite = sprites.invalid
	end
end

function compturn()
 if timer < 30 then
  timer +=1
  return
 end
 timer = 0
 
 if not firstturn
  and grid[3][3] & tilestatus.blueinv == 0 then
   placetile(3,3)
   player.isactive = hasvalidspaces(tilestatus.redinv)
  return
 end
 
 local spcs = {}
 for r = 1, 5 do
 	for c = 1, 5 do
 		if grid[r][c] & tilestatus.blueinv == 0 then
   			add(spcs, {row = r, col = c})
  	end  
  end
 end
 if #spcs == 0 then
 	--end game
 	print("end of round")
 end
 local space = ceil(rnd(#spcs))
 local tile = spcs[space]
 placetile(tile.row, tile.col)
 player.isactive = hasvalidspaces(tilestatus.redinv)
 firstturn = false
end

function hasvalidspaces(invalid)
	for r = 1, 5 do
		for c = 1, 5 do
		 if grid[r][c] & invalid == 0 then
		 	return true
		 end
		end
	end
	return false
end