pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include ps8/serializers/generic.lua
#include ps8/compilers/vmgen.lua
#include ps8/compilers/core.lua
#include ps8/compilers/platform/crescent_p8.lua
#include ps8/compilers/crescent.lua

local source_code = [[

musicon = true
function music_reset(notset)
	music(-1,1000)
	if notset != "true" then
		musicon = not musicon
	end
	if musicon then
		if game_update == menu_update then
	  music(0)
	 else
	 	music(level*10+6)
	 end
	end
	return true
end

function start_gameplay(lvl)
	level = lvl
	game_update = gameplay_update
	game_draw = gameplay_draw
	game_init()
	sfx"10"
end

function change_options(new_options)
	curr_options = new_options
	if #new_options > 4 then
		opty -= #new_options*4-16
	else
		opty = 68
	end
	selected_opt = 1
	sfx"13"
end

level_options = {}
main_options = {
{credit_text[4],start_gameplay,1},
{credit_text[5],change_options,level_options},
{credit_text[6],function()credits = .1 end}
}

credits = 0

selected_opt = 1
curr_options = main_options
opty = 68
function menu_draw()
 
 fillp(rnd()<.5 and ▒ or -▒)
 for i = 0,20 do
 	circfill(rnd(127),rnd(127),rnd(8)+2,0)
 end
 
 local y,i = opty,1
	for opt in all(curr_options) do
	 local selected = selected_opt == i
		print(opt[1],28,y,(selected and 10 or 7))
		y += 12
		i += 1
		if selected then
		 for j = 0,1 do
			spr(1+flr(.99+sin(time()))*16,1,y-14)
			spr(2,9,y-18,1,2)
			draw_polygon157({
			{x=18,y=y-13},
			{x=18,y=y-7},
			{x=24+sin(time()+j*.25)*2-2*j,y=y-10}
			},15-j*6)
			end
		end
	end
	
	if credits > 0 then
	 cls()
	 if credits >= 1 then
		 if btnp(➡️) and credits < 3 then
		 	credits += 1
		 	sfx"13"
	  elseif btnp() > 0 then
	  	credits = 0
	  	sfx"7"
	  end
  else
  	credits = 1
   sfx"13"
  end
  print(credit_text[credits],4,64)
	end
 
 logo_render()
end

function menu_update()
	if btnp(🅾️) then
		if curr_options[selected_opt] then
			curr_options[selected_opt][2](curr_options[selected_opt][3])
		end
	end
	
	if btnp(⬇️) then
		selected_opt += 1
		sfx"8"
	elseif btnp(⬆️) then
		selected_opt -= 1
		sfx"8"
	end
	selected_opt = mid(1,selected_opt,#curr_options)
end

--init stuff
function game_init()
opty = 68
curr_options = main_options

local i = 0
cartdata(credit_text[22])
total_score = 0
for i = 1,4 do total_score += dget(i) end
while #level_options > 0 do deli(level_options) end
add(level_options,{credit_text[11],change_options,main_options})
while i <= dget(0) do
 i += 1
 if i == 4 and total_score < 1000 then
  add(level_options,{"\f2\t\t\t"..total_score.."\fd/1000",nothing})
 elseif i <= 4 then
 	add(level_options,{"Level "..i.."\f1 - \f2"..dget(i),start_gameplay,i})
 end
end

if dget(0) > 3 then
	add(level_options,{"\fd\t\t\t\t\|e "..total_score,nothing})
end

set_highscore(total_score)

lavatide = false
dead = false

speech_active=false
speech_y = 32
speech_convo_point = 1
speech_text=""
speech_print = ""
speech_wait = 1

if angel then
 angel.init = false
 scrubs.init = false
 scorch.init = false
end

render_dist = 250

pauseitem(1, credit_text[7], to_menu)
pauseitem(2, credit_text[8], music_reset)
pauseitem(3, credit_text[9], function() pauseitem(4, credit_text[10], function() cartdata(credit_text[22]) for i = 0,64 do dset(i,0) end set_highscore(0) to_menu() return true end) end)

music_reset("true")

cam = {x=0,y=0,z=0}
camx,camy,camz = 0,0,0
lavadist = 0
score = 0
score_add = 0
score_add_wait = 60

lavah = 150

player = playerobj:new({
x=0,y=0,z=100
})
world = {}
actors = {}

startz,starty=100,40



add(world,block:new({
w=20,
d=20,
y=40,
z=100,
moving=false
}))
create_world()

--forgotten island
add(world,block:new({
	w=80,
	d=100,
	y=40,
	z=-70,
	moving=false
}))
add(world,item:new({
	egg=true,
	z=-80,
	y=15
}))
add(world,box:new({
z=-100,
h=20,
y=40,
draw = function(_ENV)

if stat(54) < 48 then
	music"48"
end

draw_shape(4,
0,33,z,7,10,7,
4,2,2,nil,
nil,nil,"e")

draw_shape(4,
5,21,z,7,15,7,
4,2,2,nil,
nil,nil,"e")

for j = -10,10,6 do
for i = -24+abs(j),24-abs(j),10 do
local leafoff = sin(j*.1+i*.1+time())
draw_shape(
2,
24+((i-j<-15 or abs(i-j) < 5) and 8 or 0),24,8,8,--sheet coords
x+5+i+leafoff*.5,y-35+j,z-20+leafoff,--pos
12,7,
"entity"
)
end
end

end
}))

add_particles(unpack_split"20,2,2,14,64,64")
add_particles(unpack_split"20,2,2,6,64,64")
add_particles(unpack_split"20,2,2,7,64,64")

level_summited = false
currpal=pals[level]
lava_colors = currpal.lava

end

pals = 
{
{
lava = split"0,1,13,12,13,12,6,7",
player=split"9,15",
blocks=split"3,2,5,4,11"
},
{
lava = split"4,2,8,15,9,10,7,7",
player=split"12,13",
blocks=split"14,5,4,1,6"
},
{
lava = split"7,6,14,5,4,1,0,0",
player=split"11,3",
blocks=split"15,2,4,4,9"
},
{
lava = split"8,9,10,11,3,2,1",
player=split"9,15",
blocks=split"14,1,4,4,13"
}
}

level = 1
lavaspds = {.0555,.0875,.0935,.1122}
lava_particles = {}
particles = {}
death_anim = -300
function death_draw()
local dead = player.hp == 0
fillp(rnd()<.5 and ▒ or -▒)
for i = 0,20 do
	circfill(rnd(127),rnd(127),rnd(8)+2,0)
end

print(dead and credit_text[12] or credit_text[13],-death_anim*.33+10,10,15)
local type = dead and deathtypes or livetypes
print(type[level],death_anim*5+60,32,15)
print((dead and credit_text[14] or credit_text[15]) .."\n"..credit_text[16],death_anim*50+10,80,7)
print(credit_text[17]..score)

rectfill(-1,126,death_anim,128,15)
end

function death()

cartdata(credit_text[22])
music"-1"
if not dead then
	if level > 2 then
music"48"
	end
	
	if level == 4 then
set_trophy(4)
	end
	cartdata(credit_text[22])
	dset(0, max(dget(0),level))
end
dset(level, max(dget(level),score))

death_anim = -300
game_draw = death_draw
game_update = death_update

sfx"6"

end

function death_update()
if btn() != 0 then
 sfx"7"
	death_anim += min(abs(death_anim)*.1+.1,5)
else
	death_anim *= .97
end
if death_anim >= 145 then
 sfx"-1"
	if level > 2 and not global.dead then
credits = .1 to_menu() selected_opt = 2
	elseif btn(❎) then
to_menu()
 else 
  if not global.dead then
level += 1
  end
 	start_gameplay(level)
 end
end
end

--ui
levels = {
"Lvl 1: "..credit_text[18],
"Lvl 2: "..credit_text[19],
"Lvl 3: "..credit_text[20],
"Lvl 4: "..credit_text[21]
}

function start_convo(num)
music(-1,5000)
speech_y = 32
speech_convo_point = 1
speech_text=""
speech_print = ""
speech_wait = 1
speech_active = true
player.z = endz - 20
player.x = 0
speech_convo=speech_convos[num]
get_params(speech_convo[1])
end

function get_params(string)
local ol_params = speech_params
speech_params = split(string,"|")
if speech_params[1] == "-" then
 speech_text = speech_params[#speech_params]
 speech_params = ol_params
else
	speech_params[1] = tonum(speech_params[1])
 speech_params[2] = tonum(speech_params[2])
 speech_text = speech_params[#speech_params]
end
end

decision = 0
function ui_update()
if speech_active then
	speech_y *= .9
	
	if #speech_print < #speech_text then
speech_wait -= 1
if speech_wait <= 0 then
 
 print("\a"..speech_params[3])
 speech_print = sub(speech_text,1,#speech_print+1)
 local lastchar = sub(speech_print,#speech_print)
 
 speech_wait = 3
 if lastchar == "." or lastchar == "!" or lastchar == "?" then
	 speech_wait += 30
	end
end
	else
if btnp(❎) or btnp(🅾️) then
 
 if decision == 1 then
 	shanimt = -1000
 	shanim2 += 10
 	sfx"11"
 	add_particles(20,2,2,8,angel.x,angel.y,angel.z)
 elseif decision == 2 then
 	if btnp(❎) then
 	 shanim2 -= 10
 	 sfx"11"
 	 add_particles(20,2,2,14,angel.x,angel.y,angel.z)
 	 del(world,angel)
 		speech_convos[6][10] = "-|||...Peace at last."
		else
			sfx"10"
		end
		set_trophy(1)
 end
 decision = 0
 
	speech_convo_point += 1
	if speech_convo_point > #speech_convo-1 then
	 speech_active = false
	else
	 speech_wait = 0
		speech_print = ""
		next_string = speech_convo[speech_convo_point]
		
		local fl = sub(next_string,1,1)
		
		if fl == "*" then
			death()
		end
		
		if fl == "⌂" then
			shanimt += 10
			speech_convo_point += 1
			next_string=speech_convo[speech_convo_point]
		end
		
		if fl == "`" then
			decision = 1
			speech_convo_point += 1
			next_string=speech_convo[speech_convo_point]
		end
		
		if fl == "♥" then
			decision = 2
			speech_convo_point += 1
			next_string=speech_convo[speech_convo_point]
		end
		
		if fl == "~" then
			add(world,lavapillar:new({
			 dmg=false,
			 x=player.x,
			 z=player.z,
			 spouty = lasty-100
			}))
			speech_convo_point += 1
			next_string=speech_convo[speech_convo_point]
		end
		
		if fl == "!" then
			
			speech_convo_point += 1
			
			commands = split(next_string,"|")
			
			for i = 2,4 do
			 local comset = split(commands[i])
				obj = i == 2 and angel or i == 3 and scorch or scrubs
				obj.desiredang = comset[1]
				if obj.wings != comset[2] then
					add_particles(
20,2,2,7,obj.x,obj.y,obj.z
)
					if comset[2] == 0 then
						player.wings += 1
					end
				end
				obj.wings = comset[2]
				if comset[2] == 3 then
					obj.dy -= 50
					obj.done = true
				end
			end
			
			next_string=speech_convo[speech_convo_point]
		end
		
		get_params(next_string)
	end
end
	end
	
	if btnp(❎) and #speech_print > 0  then
	 speech_print = speech_text
	end
	
	if btn(🅾️) then
		speech_wait -= 1.75
	end
	
else
	speech_y -= (speech_y-40)*.05
end
end

function create_world()
 
 lastz,lastd,
 lasty,lasth,
 lastx,lastw =
 100,20,
 40,8,
 0,20
 
 if level == 2 then
 	lasty -= 20
 end
 if level == 3 then
 	lastz += 110
 end
 
 local move_chance = .1+.05*level
 local enemy_chance = .05*level
 local number_of_blocks = 65
	for i = 1,number_of_blocks do
	 
	 local extra_blocks = rnd()<.15 and 1 or 0
	 
	 for j = 0,extra_blocks do
	 w=10+rnd(20)
	 d=extra_blocks!=0 and lastd or 15+rnd(20)
	 h=8+rnd(16)
	 
	 z=
	 j == 0 and lastz+lastd/2+d/2+1+rnd(level*20)
	 or
	 lastz
	 
	 y = lasty-lasth/2+h/2 - rnd(6+2*level)
	 local raised,spread = false, false
	 if i == 1 then
	 	y = min(lasty-1+h/2,y)
	 	if level == 3 then
	 	z = lastz end
	 	raised = true
	 	spread = true
  elseif level > 1 and rnd()<.1then
   y -= 20
   raised = true
  elseif level > 2 and rnd()<.1 then
  	z += 20
  	spread = true
  end
	 
	 local levelxoff = 10+level*15
	 x= lastx+rnd(levelxoff)-levelxoff/2
	 
	 if j!= 0 then
	 	x = lastx-sgn(lastx)*(w+lastw+rnd(level*5))
  end
	 
	 x *= .95
	 
	 x = mid(-40+w/2,x,40-w/2)
	 
	 
	 local moving,amp,spd = false,min(rnd(30)+10,abs(x)-35),rnd(.0015)+.001
	 cycle = rnd()<.5 and .175 or -.175
	 if extra_blocks==0 and rnd() < move_chance then
	 	moving = true
	 	rootx = x
	 	x = sin(cycle)*amp+rootx
  end
	 
 	if rnd()<(abs(x-lastx)/175)^1.25 or (rnd()<.5 and moving) then
 		
			add(world,item:new(
			{
			x=x,
			y=y-h-rnd(10)-level*8,
			z=z,
			col=7,
			colb=6,
			floory=y-h/2
			}
			))
		end
  
  if rootx then
  	x = rootx
  	rootx=nil
  end
  
  if level > 1 and z-lastz > 50 and rnd() < .33 then
	 	local a =x-10+rnd(20)
	 	add(world,lavapillar:new({
	 	x=a,
	 	rootx=a,
	 	z = (lastz+z)/2,
	 	y=y,
	 	spouty = y-rnd(30)-5,
	 	moving=rnd()<.5,
	 	amp=amp,
	 	spd=spd,
	 	cycle=-cycle
	 	
	 	}))
  end
  
  lastz = z
	 lastd = d
	 lasty = y
	 lasth = h
	 if j==0 or rnd()<.5 then
	 lastx = x end
	 lastw = w
	 
	 add(world,block:new({
	 z=z,
	 y=y,
	 x=x,
	 rootx=x,
	 w=w,
	 d=d,
	 h=h,
	 moving=moving,
	 amp=amp,
	 spd=spd,
		cycle=cycle,
	 rownum=i
	 }))
	 if rnd()<enemy_chance and not raised then
	  local bot = boxbot:new({
	  floor=world[#world],
	  spiked = rnd()<(level*.25-.25) and not spread,
	  shooter = level > 2 and rnd()<.33
	  })
		 bot:update()
		 add(world,bot)
  end
	 end
	end
	
	endz = z+d+30
	endy = y-1
	
	add(world,block:new({
z=endz,
y=endy,
x=0,
rootx=x,
w=60,
d=60,
h=20,
moving=moving,
amp=amp,
spd=spd,
rownum=i,
lastblock = true
}))
	
	if level == 1 then
add(world,scrubs)
add(world,angel)
add(world,scorch)
	end
	
	if level == 2 then
add(world,scorch)
add(world,angel)
	end
	
	if level == 3 then
add(world,angel)
add(world,swordhandle)
swordhandle.z=endz
swordhandle.y=endy-30
	end
	
end

--decompression
function sheet_to_string()
local x,y,outputstring = 0,56,""
while y < 128 do
	
	outputstring =
	outputstring ..
	chr(sget(x,y)|(sget(x+1,y)<<4))
	
	x += 2
	if x >= 128 then
		y += 1
		x=0
	end
	
end

return outputstring

end

dialogue =sheet_to_string()
speech_convos = {}
convos = split(dialogue,"@")
for convo in all(convos) do
 local tempconvo = split(convo,"#")
 add(speech_convos,tempconvo)
end
deathtypes = speech_convos[9]
livetypes = speech_convos[10]	


lavapillar=box:new(
{
col=15,
col2=9,
col3=8,
active=true,
animang=0,
dmg=true,
lavadmg=true,
w=10,
d=10,
h=0,
spouty=10,
peakh=20,
close=200,
tags="",
update = function(_ENV)
if not init then
	init = true
	sfx"5"
end

if level != 2 then
 col,col2,col3 = lava_colors[lava_point_flr-1],lava_colors[lava_point_flr],lava_colors[lava_point_flr+1]
end

if moving then
 vx = x
 x = sin(cycle)*amp+rootx
 cycle += spd
 vx = x-vx
end

animang += .01
if animang > 1 then
	animang = 0
end

if (player.z >= z or spouty-lavah > -50) and active and not level_summited then
	active = false
	dmg = false
	sfx"13"
end

if active then
 close *= .95
 y = (lavah+spouty)/2
 h = spouty-lavah
 if level_summited then
  player.vy = 0
  local goty = min(y+close-20,player.y)
  if player.floor != nil then
  	player.floor.y = goty+4
  end
 	player.y = goty
 end
else
 close += 1
	if abs(h-close) < 10 then
		del(global.world,_ENV)
	end
end
end,

draw = function(_ENV)
 local sine = sin(time())*5
 for i = -1,0 do
 draw_shape(5,
  x,
  i==-1 and y+close or spouty-6-sine/2+close,
  z,
  w*1.5,
  i==-1 and h or 12+sine,
  d*1.5,
  col,col2,col3,
  nil,animang-.25,
  (active and "" or "dith")..tags)
 end
 
 if rnd()<.1 then
 add_particles(
	1,1,-.5,14+rnd(2)^2,x-15+rnd(30),spouty-15+rnd(20)-close,z
	)end
end
}
)


--lvl_boss = {scrubs,scorch,angel,
--{hp=0}}
]]

local bytecode = compile_crescent({
	vm_cleanup = vm_cleanup_full,
    specialized_for_ops = true,
}, source_code)

generate_ps8_vm{
}

local len = #bytecode
poke2(0x8000, len)
poke(0x8002, ord(bytecode, 1, len))
cstore(0, 0x8000, len+2, "bytecode.p8")
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
