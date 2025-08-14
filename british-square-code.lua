function _init()
	-- create enums
	status = {
		empty = 0,
		red = 1,
		redb = 2,
		blueinv = 7,
		blue = 4,
		blueb = 8,
		redinv = 13,
		standard = 16,
		prime = 32}
	sprites = {
		p1 = 3,
		p2 = 4,
		red = 1,
		blue = 2,
		p1point = 5,
		p2point = 6,
		invalid = 7}
	states = {
		menu = 0,
		rules = 1,
		game = 2,
		roundend = 3,
		gameend = 4}
	colors = {
		red = 8,
		blue = 12,
		white = 7}
	pointloc = {
		p1x = 32,
		p2x = 80,
		y = 72}
	ox = 32
	oy = 24
	modes ={
		easy = 0,
		hard = 1,
		rules = 2}
	mode = modes.easy
	redcount = 0
	bluecount = 0
	anim = {
		x = 0,
		y = 0,
		w = 24,
		h = 24,
		vx = .8,
		vy = 1.3}
	bgind = 1
	bckgrdclrs = {1,2,3,5}
	--initialize game components
	initgrid()
	initgamevariables()
end

function initgamevariables()
	player = {
		isactive = true,
		isvalid = true,
		sprite = sprites.p1,
		row=1,
		col=1}
	comp = {
		sprite = sprites.p2,
		row = 1,
		col = 1,
		hasdest = false,
		destcol = 0,
		destrow = 0}
	scores = {
		p1 = 0,
		p2 = 0}
	state = states.menu
	timer = 0
	firstturn = true
	lastplaced = status.red
end

function _update()
	if state == states.game then doturn()
	elseif state == states.roundend then waitfornewround()
	elseif state == states.gameend then waitfornewgame()
	elseif state == states.menu then menu()
	end
end

function _draw()
	if (state == states.game) drawgame()
	if (state == states.roundend) drawroundend()
	if (state == states.gameend) drawgameend() 
	if (state == states.menu) drawmenu()
end

function drawmenu()
	cls()
	map(17,2)
	print("easy", 18, 122, colors.white)
	print("hard", 47, 122, colors.white)
	print("how to play", 76, 122, colors.white)
	if mode == modes.easy then
		spr(sprites.red, 8, 120)
		print("easy", 18, 122, colors.red)
	elseif mode == modes.hard then
		spr(sprites.red, 37, 120)
		print("hard", 47, 122, colors.red)
	else
		spr(sprites.red, 66, 120)
		print("how to play", 76, 122, colors.red)		
	end
end

function drawgame()
	cls(bckgrdclrs[bgind])
	drawanim()
	map()
	drawgrid()
	drawplayer()
	drawscore()
end

function drawanim()
	local sprite = 8
	if (not player.isactive) sprite = 16
	sspr(sprite,0,8,8,anim.x,anim.y,anim.w,anim.h)
	anim.x+= anim.vx
	anim.y+= anim.vy
	if anim.x > 128 - anim.w or anim.x < 0 then
		anim.vx *= -1
	end
	if anim.y > 128 - anim.h or anim.y < 0then
		anim.vy *= -1
		bgind = (bgind + ceil(rnd(3))) % #bckgrdclrs + 1
	end
end

function menu()
	if btnp(⬆️) or btnp(⬅️) then
		mode = (mode + 2) % 3
	elseif 	btnp(⬇️) or btnp(➡️) then
		mode = (mode + 1) % 3	
	end
	if btn(🅾️) and mode != modes.rules then
		state = states.game
	elseif btn(🅾️) then
		state = states.rules
	end
end

function doturn()

	if not player.isactive then
		compturn()
		return
	end

	if not hasvalidspaces(status.redinv) then
		roundend()
		return
	end
	
	checkcontroller()
end

function checkcontroller()
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

function waitfornewround()
	if timer < 10 then
		timer += 1
		return
	end
	if btnp(🅾️) then
		state = states.game
		initgrid()
		timer = 0
		if redcount > bluecount then
			player.isactive = false
		elseif bluecount > redcount then
			player.isactive = true
		else
			player.isactive = lastplaced == status.blue
		end
	end
end

function waitfornewgame()
	if timer < 10 then
		timer += 1
		return
	end
	if btnp(🅾️) then
		state = states.game
		initgamevariables()
		initgrid()
		timer = 0
	end
	if btnp(❎) then
		state = states.menu
		initgamevariables()
		initgrid()
		timer = 0
	end
end

function drawplayer()
	if player.isactive then
		spr(player.sprite, player.col * 8 + ox, player.row * 8 + oy)
	else
		spr(comp.sprite, comp.col * 8 + ox, comp.row * 8 + oy)
	end
end

function drawscore()
	print(scores.p1, pointloc.p1x, pointloc.y + 10, colors.red)
	print(scores.p2, pointloc.p2x + 5, pointloc.y + 10, colors.blue)
	spr(sprites.p1point, pointloc.p1x, pointloc.y - (scores.p1 * 8))
	spr(sprites.p2point, pointloc.p2x, pointloc.y - (scores.p2 * 8))
end

function placetile(row, col)
	if firstturn then
		-- reset center to its default
		grid[3][3] = status.prime
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

function drawgameend()
	drawanim()
	if scores.p1 >= 7 then
		printcenter("red wins!",6,colors.red)
	else
		printcenter("blue wins!",6,colors.blue)
	end 
	printcenter("press 🅾️ to play again.", 14,colors.white)
	player.isactive = scores.p1 >= 7
end

function drawroundend()
	drawgame()
	printcenter("end of the round.", 6, colors.white)
	printcenter("press 🅾️ to continue.", 14, colors.white)
	if redcount > bluecount then
		print("+"..redcount-bluecount, 56, 82, colors.red)
	elseif bluecount > redcount then
		print("+"..bluecount-redcount, 56, 82, colors.blue)
	else
		print("no points", 43, 82, colors.white)
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
		if i % 5 <= 1 then
			grid[i] = {
			status.empty,
			status.standard,
			status.standard,
			status.standard,
			status.empty}
		else
			grid[i] = {
			status.standard,
			status.prime,
			status.prime,
			status.prime,
			status.standard}
		end
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
	if comp.hasdest then
		if comp.row == comp.destrow 
		and comp.col == comp.destcol then
			placetile(comp.row, comp.col)
			comp.hasdest = false
			player.isactive = hasvalidspaces(status.redinv)
			timer = 0
		else
			movecomp()
		end
	elseif mode == modes.easy then
		easyturn()
	else
		hardturn()
	end
end

function movecomp()
	if timer < 13 then
  		timer +=1
  		return
 	end
 	
	timer = 0
	if comp.row > comp.destrow then
		comp.row -= 1
	elseif comp.col > comp.destcol then
		comp.col -= 1
	elseif comp.row < comp.destrow then
		comp.row += 1
	elseif comp.col < comp.destcol then
		comp.col += 1
	end

	if grid[comp.row][comp.col] & status.blueinv == 0 then
		comp.sprite = sprites.p2
	else
		comp.sprite = sprites.invalid
	end
end

function easyturn()
 local valid = {}
 local prime = {}
 local standard = {}
 local empty = {}
	for r = 1, 5 do
 		for c = 1, 5 do
			local currtile = grid[r][c]
 			if currtile & status.blueinv == 0 then
   				add(valid, {row = r, col = c})
				if currtile & status.prime > 0  
				 and currtile & status.blueb == 0 then
					add(prime,{row = r, col = c})
				end  
				if currtile & status.standard > 0  
				 and currtile & status.blueb == 0 then
					add(standard,{row = r, col = c})
				end
				if currtile & status.blueb == 0 then
					add(empty, {row = r, col = c})
				end
			end -- end if is valid
		end -- end for c
	end --end for r
 
 if #valid == 0 then
 	roundend()
 	return
 end
 
 local tile = {}
 if #prime != 0 then
		tile = prime[ceil(rnd(#prime))]
 elseif #standard != 0 then
 	tile = standard[ceil(rnd(#standard))]
 elseif #empty != 0 then
	tile = empty[ceil(rnd(#empty))]
 else
		tile = valid[ceil(rnd(#valid))]
 end
 comp.destcol = tile.col
 comp.destrow = tile.row
 comp.hasdest = true
end

function hardturn()
	--hard logic, for now do easyturn
	easyturn()
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
	redcount = 0
	bluecount = 0
	for r = 1, 5 do
		for c = 1, 5 do
		 if grid[r][c] & status.blue > 0 then
		 	bluecount+=1
		 elseif grid[r][c] & status.red > 0 then
			redcount+=1
		 end
		end
	end
	
	if redcount > bluecount then
		scores.p1 += redcount - bluecount
	elseif bluecount > redcount then
		scores.p2 += bluecount - redcount
	end

	if scores.p1 >= 7 or scores.p2 >= 7 then
		--trigger end of game
		state = states.gameend
	else
		state = states.roundend
	end
end

function printcenter(text, y, color)
	print(text, #text * -2 + 64, y, color)
end