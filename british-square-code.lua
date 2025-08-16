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
		invalid = 7,
		check = 14,
		cross = 15}
	states = {
		menu = 0,
		rules = 1,
		game = 2,
		roundend = 3,
		gameend = 4,
		pause = 5}
	colors = {
		red = 8,
		blue = 12,
		white = 7,
		gray = 6,
		darkgray = 5}
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
	anim = {
		x = rnd(25),
		y = rnd(20) + 70,
		w = 24,
		h = 24,
		vx = .8,
		vy = 1.3}
	anim2 = {
		x = rnd(30) + 40,
		y = rnd(50),
		w = 24,
		h = 24,
		vx = 1.4,
		vy = -.9}
	state = states.menu
	rulesstate = 1
	timer=0
	--initialize game components
	initrules()
end

function initgamevariables()
	initgrid()
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
	redcount = 0
	bluecount = 0
	timer = 0
	pausestate = false
	firstturn = true
	lastplaced = status.red
end

function _update()
	if (state == states.game) doturn()
	if (state == states.roundend) waitfornewround()
	if (state == states.gameend) waitfornewgame()
	if (state == states.menu) menu()
	if (state == states.rules) howtoplay()
	if (state == states.pause) pausemenu()
end

function _draw()
	if (state == states.game) drawgame()
	if (state == states.roundend) drawroundend()
	if (state == states.gameend) drawgameend() 
	if (state == states.menu) drawmenu()
	if (state == states.rules) drawhowtoplay()
	if (state == states.pause) drawpause()
end

function drawmenu()
	cls()
	map(16,0)
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
	cls(colors.darkgray)
	drawanim(anim)
	drawanim(anim2)
	checkcollision()
	map()
	drawgrid()
	drawplayer()
	drawscore()
end

function drawanim(obj)
	local spritex = 8
	if (not player.isactive) spritex = 16
	sspr(spritex,0,8,8,obj.x,obj.y,obj.w,obj.h)
	obj.x+= obj.vx
	obj.y+= obj.vy
	if obj.x >= 128 - obj.w or obj.x < 0 then
		obj.vx *= -1
	end
	if obj.y >= 128 - obj.h or obj.y < 0 then
		obj.vy *= -1
	end
end

function checkcollision()
	if ((anim.x < anim2.x and anim.x + anim.w > anim2.x)
		or (anim2.x < anim.x and anim2.x + anim2.w > anim.x))
		and 
		((anim.y < anim2.y and anim.y + anim.w > anim2.y)
		or (anim2.y < anim.y and anim2.y + anim2.w > anim.y)) then
		
		local vx1 = anim.vx
		anim.vx = anim2.vx
		anim2.vx = vx1
		local vy1 = anim.vy
		anim.vy = anim2.vy
		anim2.vy = vy1
	end
end

function menu()
	if (waitfortimer(10)) return

	if btnp(⬆️) or btnp(⬅️) then
		mode = (mode + 2) % 3
	elseif 	btnp(⬇️) or btnp(➡️) then
		mode = (mode + 1) % 3	
	end
	if btn(🅾️) and mode != modes.rules then
		state = states.game
		initgamevariables()
		timer = 0
	elseif btn(🅾️) then
		state = states.rules
		rulesstate = 1
		timer = 0
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
		return
	end
	if btnp(❎) then
		state = states.pause
		pausestate = false
		return
	end
end

function drawpause()
	rectfill(30, 38, 89, 60, 0)
	print("exit to menu?", 34, 42, colors.white)
	print("no", 48, 52, colors.white)
	print("yes", 72, 52, colors.white)
	if pausestate then
		print("yes", 72, 52, colors.red)
		spr(sprites.red, 62, 50)
	else
		print("no", 48, 52, colors.red)
		spr(sprites.red, 38, 50)
	end
end

function pausemenu()
	if (waitfortimer(10)) return

	if btnp(⬆️) or btnp(⬅️)
	 or btnp(⬇️) or btnp(➡️) then
		pausestate = not pausestate
	end

	if btnp(🅾️) and pausestate then
		state = states.menu
		timer = 0
		return
	end

	if btnp(❎)  
	 or (btnp(🅾️) and not pausestate) then
		state = states.game
		timer = 0
		return
	end
end

function waitfornewround()
	if (waitfortimer(10)) return

	if btnp(🅾️) then
		state = states.game
		initgrid()
		timer = 0
		if redcount > bluecount then
			player.isactive = false
		elseif bluecount > redcount then
			player.isactive = true
		else
			player.isactive = lastplaced == status.red
		end
	end
end

function waitfornewgame()
	if (waitfortimer(10)) return

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

function howtoplay()
	if (waitfortimer(10)) return

	if btnp(🅾️) or btnp(❎)
		or btnp(⬆️) or btnp(⬅️)
		or btnp(➡️) or btnp(⬇️) then
		rulesstate += 1
		timer = 0
	end

	if rulesstate >= 6 then
		state = states.menu
	end
end

function drawplayer()
	if player.isactive then
		spr(player.sprite, player.col * 8 + ox, player.row * 8 + oy)
	else
		spr(comp.sprite, comp.col * 8 + ox, comp.row * 8 + oy)
	end
end

function drawhowtoplay()
	cls(5)
	rect(-1,12,128,14,colors.gray)
	line(1,13,126,13,0)
	printcenter("how to play british square", 4, colors.white)
	local rule = rules[rulesstate]
	local y = 10
	for i = 1, #rule do
		y += 10
		printcenter(rule[i], y, colors.white)
	end
	if rulesstate == 2 then
		map(0,-5)
		spr(sprites.cross,56,88)
	elseif rulesstate == 3 then
		rect(2,90,125, 124, colors.gray)
		map(51, -11)
		local check = 94
		-- red by blue
		spr(sprites.cross,12,check)
		-- red by red
		spr(sprites.check,44,check)
		-- blue by blue
		spr(sprites.check,76,check)
		-- diagonal
		spr(sprites.check, 108, check)
	elseif rulesstate == 4 then
		map(36, -7)
	elseif rulesstate == 5 then
		rect(18,113, 110, 125, colors.gray)
		printcenter("no points", 117, colors.white)
		print("+2", 24, 117, colors.red)
		print("+2", 98, 117, colors.blue)
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
	drawanim(anim)
	drawanim(anim2)
	checkcollision()
	if scores.p1 >= 7 then
		printcenter("red wins!",6,colors.red)
	else
		printcenter("blue wins!",6,colors.blue)
	end 
	printcenter("press 🅾️ to play again.", 14,colors.white)
	player.isactive = scores.p1 >= 7
	printcenter("press ❎ to go to the menu", 100, colors.white)
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
	if (waitfortimer(13)) return
 	
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

function waitfortimer(time)
	if timer < time then
		timer += 1
		return true
	end
	return false
end

function initrules()
	rules = {
		{"the object of the game is", "to end each round with more", 
		"of your tiles on the board", "than your opponent.",
		"", "the first player to 7", "points wins!",
		"", "press any button to continue."},
		{"the first player may place", "a piece anywhere on the board",
		"except the center square on", "the first move."},
		{"the second player may place", "a piece on any square",
		"including the center square", "so long as its side is not",
		"facing an opponent's piece.", "pieces may be placed by",
		"their own color."},
		{"play continues until no more", "moves are possible for",
		"either color."},
		{"at the end of the round", "the tiles are counted",
		"and the player with the most", "tiles is awarded points",
		"equal to the difference.", "", "the player with the least",
		"points will go first at", "the beginning of the next round."}
	}
end