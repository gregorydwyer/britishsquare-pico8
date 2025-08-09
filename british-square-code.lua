function _init()
	status = {
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
	ox = 32
	oy = 24
	pointloc = {
		p1x = 32,
		p2x = 80,
		y = 80
	}
	scores = {
		p1 = 0,
		p2 = 0}

	timer = 0
	firstturn = true
	lastplaced = status.red
	
	player = {
		isactive = true,
		isvalid = true,
		sprite = sprites.p1,
		row=1,
		col=1}

	initgrid()
end

function _update()
	doturn()

end

function _draw()
	cls()
	map()
	drawgrid()
	drawplayer()
	drawscore()
end

function doturn()

	if not player.isactive then
	compturn()
	return
	end

	if not hasvalidspaces(status.redinv) then
		roundend()
	end
	-- only move one dir at a time
	if (btnp(⬅️)) player.col-=1
	if (btnp(➡️)) player.col+=1
	if (btnp(⬆️)) player.row-=1
	if (btnp(⬇️)) player.row+=1
	
	-- keep player in bounds
	if (player.col < 1) player.col = 1
	if (player.row < 1) player.row = 1
	if (player.col > 5) player.col = 5
	if (player.row > 5) player.row = 5

 setisvalid()

	if btnp(🅾️) and player.isactive
	 and player.isvalid then
		placetile(player.row,player.col)
		player.isactive = not hasvalidspaces(status.blueinv)	
	end
end

function drawplayer()
	if player.isactive then
		spr(player.sprite, player.col * 8 + ox, player.row * 8 + oy)
	end
end

function drawscore()
	spr(sprites.p1point, pointloc.p1x, pointloc.y - (scores.p1 * 8))
	spr(sprites.p2point, pointloc.p2x, pointloc.y - (scores.p2 * 8))
end

function placetile(row, col)
	if firstturn then
		grid[3][3] = status.empty
		firstturn = false
	end
	-- get correct color
	local tile = status.red
	local block = status.redb
	if not player.isactive then
	 tile = status.blue
	 block = status.blueb
	end
	-- add tile to grid
	grid[row][col] = tile
	lastplaced = tile
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
	for r=1, 5 do
		for c=1, 5 do
			local tile = grid[r][c]
			if tile & status.red == status.red then
			 --place red
			 spr(sprites.red, ox+(8*c), oy+(8*r))
			end
			if tile & status.blue == status.blue then
			 --place blue
			 spr(sprites.blue, ox+(8*c), oy+(8*r))
			end
		end
	end
end

function initgrid()
	grid = {}
	for i=1, 5 do
	 grid[i] = {
	 status.empty,
	 status.empty,
	 status.empty,
	 status.empty,
	 status.empty,
	 }
	end
	-- set center invalid for first turn
	grid[3][3] = status.blueb | status.redb
	firstturn = true
	
end

function setisvalid()
	local tile = grid[player.row][player.col]
	if tile & status.redinv == 0
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
 
 local spcs = {}
 for r = 1, 5 do
 	for c = 1, 5 do
 		if grid[r][c] & status.blueinv == 0 then
   			add(spcs, {row = r, col = c})
  	end  
  end
 end
 
 if #spcs == 0 then
 	roundend()
 	return
 end
 local space = ceil(rnd(#spcs))
 local tile = spcs[space]
 placetile(tile.row, tile.col)
 player.isactive = hasvalidspaces(status.redinv)
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

function roundend()
	local red = 0
	local blue = 0
	for r = 1, 5 do
		for c = 1, 5 do
		 if grid[r][c] & status.blue > 0 then
		 	blue+=1
		 elseif grid[r][c] & status.red > 0 then
				red+=1
		 end
		end
	end
	
	if red > blue then
		scores.p1 += red - blue
		player.isactive = false
	elseif blue > red then
		scores.p2 += blue - red
		player.isactive = true
	else
		player.isactive = lastplaced == status.blue
	end
	if scores.p1 > 7 or scores.p2 > 7 then
		--trigger end of game
	else
		initgrid()
	end
end