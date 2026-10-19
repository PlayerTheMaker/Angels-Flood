pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
cart_id = 29

#include pico32/pico32_base_custom.lua

poke(0x5f5c,255)
poke(0x5602,9)

credstring = chr(peek(0x3f8c,1000))

credit_text = split(credstring,"`")

function gameplay_update()
 
	player:update()
	
	if not level_summited then
	 camtz = player.z-79
	 camty = player.y-28
	else
	 player.highest = camy
		camtz = endz-95
		camty = endy-45
		
		if 
		--lvl_boss[level].hp == 0 and
		speech_active == false then
			start_convo(level*2)
			music"56"
			
			if level == 3 then
				lavatide = true
				angel.dy += 23
			end
		end
		
	end
	camz += (camtz-camz)*.075
	camy += (camty-camy+player.highest-camy)*.01
	
	for obj in all(world) do
	 if obj.onscreen then
		 obj:update()
		end
	end
	
	for actor in all(actors) do
		actor:update()
	end
	
	ui_update()
end

function add_particles(
amt,size,force,col,x,y,z)
 if z != nil then
 	x,y = p2s(x,y,z)
 end
 
 for i = 1,amt do
 	local ang = rnd()
 	
 	add(particles,
 	{
 	global=_ENV,
 	x=x,
 	y=y,
 	vx=cos(ang)*(force+rnd()),
 	vy=sin(ang)*(force+rnd()),
 	s=size,
 	vs=.1,
 	sgrav=.01,
 	col=col
 	}
 	)
 	
 end
 
end

draw_shapes = {}
colorwipecol = 0
colorwipes = 0
function gameplay_draw()
 cls()
 if not level_summited and lavah > endy then
  lavah -= lavaspds[level]
 else
 	lavah += (lasty-lavah-8)*.05
 end
 if lavatide then
 	lavah -= .5
 	shanim2 += .75
 	player.y = lavah-16
 	player.vy *= .95
 	if player.vy > -.1 then
 		player.vy -= 1
		end
 end
 
 lava_dist = camy-lavah
 lava_point = (lava_dist+300)/40
 
 local ol_flr = lava_point_flr
 lava_point_flr = flr(lava_point)
 
 lava_col = lava_colors[lava_point_flr]
 lavax,lavay=p2s(camx,lavah,camz + 450)
 
 fillp()
 
 rectfill(
 0,lavay,127,127,
 lava_colors[lava_point_flr])
 
 fillp(rnd() < .4 and ▒ or -▒)
 if ol_flr != lava_point_flr then
 	colorwipes = 300
 	colorwipecol = lava_colors[ol_flr]
 end
 if colorwipes > 1 then
 	colorwipes -= 1
 	colorwipes *= .985
 	ovalfill(
 	64-colorwipes,112-colorwipes*lavadist*.0025,
 	64+colorwipes,112+colorwipes*lavadist*.0025,colorwipecol)
 end
 
 for p in all(lava_particles) do
 	
 	p.s += p.vs
 	p.vs -= p.gravs
 	
 	
 	local cx1,cy1 = p2s(p.x-p.s,lavah,p.z-p.s/2)
 	local cx2,cy2 = p2s(p.x+p.s,lavah,p.z+p.s/2)
 	
 	ovalfill(
 	cx1,cy1,
 	cx2,cy2,
 	p.col)
 	
 	if p.s < 0 then
 		del(lava_particles,p)
		end
 	
 end
 fillp()
 
 while #lava_particles < 30-stat(1)*30 do
		add(lava_particles,
			{x=rnd(500)-250,z=camz+rnd(400)+lavadist,
			s=0,vs=rnd(),gravs=rnd(.02)+.01,
			col=lava_colors[1+lava_point_flr+flr(rnd(2))]}
		)
	end
	
	rectfill(0,33,127,lavay,0)
 
	player:draw()
	for obj in all(world) do
	 obj.onscreen = obj:on_screen()
	 if obj.onscreen then
 		obj:draw()
		end
	end
	
	for actor in all(actors) do
		actor:draw()
	end
	
	foreach(draw_shapes,get_order_val)
	
	draw_shapes = insert_sort(draw_shapes)
	
	foreach(draw_shapes,render_shape)
	
	draw_shapes = {}
	
	fillp()
	
	ui_draw()
	
	for _ENV in all(particles) do
	 circfill(x,y,s,col)
	 s += vs
	 vs -= sgrav
	 x += vx
	 y += vy
	 vx *= .9
	 vy *= .9
	 
	 if s <= 0 then
	 	del(global.particles,_ENV)
  end
	end
	
end
-->8
--setup
function unpack_split(...)
	return unpack(split(...))
end

global = _ENV

dmgingcols = split"2,8,2,2,4"

--the holy box
box=setmetatable(
{

new=function(self,dat)
 dat=dat or {}
 setmetatable(dat,
 {__index = self})
 return dat
end,

update=function(_ENV)
 x += vx
 y += vy
 z += vz
 w+=vs
 h+=vs
 d+=vs
 vs-=vg
 if dmg then
  vy += (player.y-y)*.001
 end
 if w < 0 or h < 0 or d < 0 then
 	del(world,_ENV)
 end
 
 if collision(_ENV,global.player) then
 	global.player:damage()
 	del(world,_ENV)
 end
 
end,

onscreen = false,

on_screen = function(_ENV)
 
 if z-camz > 250
 or z < camz+40 then
 	return false
 end
 
 return true
 
end,

draw=function(_ENV)
 
 local cpal = currpal.blocks
 if dmg then
 	cpal = dmgingcols
 	shadow(_ENV,global.player.shadowh,"s")
 end
 
 draw_shape(4,
 x,y,z-2,w,h,d-2,
 
 cpal[2],
 cpal[4],
 cpal[3],
 z-camz < 125 and cpal[5] or cpal[1],
 dmg and "e" or ""
 )
 
 if lavah > y+h/2+1 and
 not level_summited then
 shadow(_ENV,lavah) end
end,

shadow = function(_ENV,y,tags)
 draw_shape(
	 1,
	 {
		 {x-w/2,y,z},
		 {x+w/2,y,z},
		 {x+w/2,y,z-d/2},
		 {x-w/2,y,z-d/2}
	 },
	 5,
	 tags and tags or ""
 )
end

},
{__index=_ENV})

_ENV = box

x,y,z,vx,vy,vz,vs,vg,w,h,d,
col,draw_tags,grav,rot=
unpack_split(credit_text[23])
_ENV = global
-->8
--3d

function p2s(x,y,z)
	sz = (max(z,camz+40)-camz)*.0075
	
	if sz == 0 then
		sz = .001
	end
		
	return (x-camx)/sz+64,(y-camy)/sz+48
end

draw_order_function = function(a,b)
	return a.order > b.order
end

function get_order_val(a)
	
	shape_type = a[1]
	entity = false
	if #split(a[#a],"entity") > 1 then
		entity = true
	end
	
	if not a.order then
		if shape_type == 1 then
			a.order = face_dist(a[2],entity)
		end
		
		if shape_type == 2 then
			a.order = face_dist({{a[6],a[7],a[8]}},entity)
		end
		
		if shape_type == 3 then
			a.order = face_dist({{a[2],a[3],a[4]}},entity)
		end
	end
	
	return a.order
end

function face_dist(face, entity)
 
 
 if entity then
	 avg = 0
	 for point in all(face) do
	 	avg += point[2]-camy
	 	+point[3]-camz
	 	+abs(point[1]-camx)
	 end
	 
	 return avg/#face-1000
 end
 
 highest = 0
 for point in all(face) do
 	highest = max(point[3],highest)
 end
 
 return highest
 
end

function draw_shape(...)
 dat = {...}
 shape_type = dat[1]
 if shape_type == 4 or
 shape_type == 5 then
  
  
	 shape = dat
	 tags = shape[#shape]
	 shape[9] = shape[9] or shape[8]
	 shape[10] = shape[10] or shape[9]
	 shape[11] = shape[11] or shape[10]
  
	 x=shape[2]
	 y=shape[3]
	 z=shape[4]
	 
	 hw = shape[5]/2--half width
	 hh = shape[6]/2--half height
	 hd = shape[7]/2--half depth
		
		if type(shape[12]) == "number" then
			rot = shape[12]
		else
			rot = 0
		end
		
		--sides
		l,r,t,b,f,c =
		x-hw, x+hw,
		y-hh, y+hh,
		z+hd, z-hd
		
		--corners
		ltf, ltc, lbf, lbc,
		rtf, rtc, rbf, rbc =
		{l,t,f},{l,t,c},{l,b,f},{l,b,c},
		{r,t,f},{r,t,c},{r,b,f},{r,b,c}
		
		--rotation
		if rot and rot != 0 then
			
			for corner in all({
			ltf, ltc, lbf, lbc,
		 rtf, rtc, rbf, rbc
			}) do
				dist = dist2d(x,z,corner[1],corner[3])
				ang = atan2(corner[1]-x,corner[3]-z)
    corner[1] = x+cos(ang+rot)*dist
    corner[3] = z+sin(ang+rot)*dist
			end
			
		end
		
		--box,x,y,z,w,h,d,colfrnt,csid,csrsid,ctop
		if shape_type == 4 then
		 
		 --left
		 if x-hw > camx then
	 	draw_shape(
	 	 1,
		  {
			  lbf,
			  ltf,
			  ltc,
			  lbc,
			 
			 },
			 shape[10],
			 tags
	  )
		 end
		 
		 --right
		 if x+hw < camx then
		 	draw_shape(
		 	 1,
			  {
			   rtf,
				  rbf,
				  rbc,
				  rtc,
				 },
				 shape[9],
				 tags
		  )
		 end
		 
		 --front
		 draw_shape(
		 	1,
		  {
			  lbc,
			  rbc,
			  rtc,
			  ltc,
			  
			 },
			 shape[8],
			 tags
		 )
		 
		 --top
		 draw_shape(
		 	1,
		  {
			  ltc,
			  rtc,
			  rtf,
			  ltf,
			  
			 },
			 shape[11],
			 tags
		 )
		 
		end
		
		--pyramid,x,y,z,w,h,d,cfrnt,csid,crsid
		if shape_type == 5 then
		 
		 --left
		 draw_shape(
	 	 1,
		  {
			  lbf,
			  lbc,
			  {x,t,z},
			 },
			 shape[9],
			 tags
	  )
	  
	  --right
		 draw_shape(
	 	 1,
		  {
			  rbf,
			  rbc,
			  {x,t,z},
			 },
			 shape[10],
			 tags
	  )
		 
		 --front/back
		 for a = 0,1 do
		 draw_shape(
		  1,
		  {
			  a==0 and lbc or lbf,
			  a==0 and rbc or rbf,
			  {x,t,z},
			 },
			 shape[8],
			 tags
		 )
		 end
		 
		 --bottom
		 if hh < 0 then
			 draw_shape(
			 	1,
			  {
				  lbc,
				  rbc,
				  rbf,
				  lbf,
				  
				 },
				 shape[11],
				 tags
			 )
   end
		 
		end
 else
  
  if shape_type < 4
  then
			add(draw_shapes,
			dat)
		end
	end
	
	return draw_shapes[#draw_shapes]
end

function render_shape(shape)
 fillp()
 tags,shadow,outline,shape_type
  = split(shape[#shape])
 ,false
 ,false
 ,shape[1]
 
 for tag in all(tags) do
  
		if tag == "dots" then
			fillp(░)
		end
		if tag == "dith" then
			fillp(▒)
		end
		
		shadow = shadow or tag == "s"
		outline = outline or tag == "o"
	end
	
	--polygon, 3d points, color
	if shape_type == 1 then
		face(shape[2],shape[3],outline,shadow)
	end
	
	--circle, x,y,z,rad,col,dcol
	if shape_type == 3 then
		
		local x,y =
		 p2s(
		  shape[2],shape[3],shape[4]
		  )
		local sx,sy =
		 p2s(
		  shape[2]+shape[5],shape[3],shape[4]
		  )
		
		local func = outline and circ or circfill
		func(x,y,sx-x,shape[6])
		circ(x,y,sx-x,1)
	end
	
--sprite, sheet x,y,w,h, pos x,y,z,w,h
	if shape_type == 2 then
		
		local sizex,sizey =
		 shape[9]/2,
		 shape[10]/2
		 
		local tlx,tly =
		 p2s(
		  shape[6]-sizex,shape[7]-sizey,shape[8]
		  )
		local brx,bry =
		 p2s(
		  shape[6]+sizex,shape[7]+sizey,shape[8]
		  )
		
		sspr(
		 shape[2],shape[3],
		 shape[4],shape[5],
		 tlx,tly,brx-tlx,bry-tly
		 )
	end
end

--werxyz
function insert_sort(tab)
    local sorted = {}
    
    for d in all(tab) do
        local lo, hi = 1, #sorted+1
        while lo ~= hi do
            local pivot = (lo+hi)\2
            if d.order < sorted[pivot].order then
                lo = pivot+1
            else
                hi = pivot
            end
        end
        add(sorted, d, lo)
    end
    
    return sorted
end

function poly(points,col)
 point_list = {}
 for i = 1,#points,2 do
 	add(point_list,{x=points[i],y=points[i+1]})
 end
	draw_polygon157(point_list,col)
end

function face(points,col,outline,shadow)
 
 local z = points[1][3]
 local filltype = z-camz > 225 and ░
 or (z-camz > 200 or z-camz < 50) and ▒
 or nil
 
 if filltype then
  fillp(filltype)
 end
 
 point_list = {}
 for point in all(points) do
  sx,sy = p2s(point[1],point[2],point[3])
 	add(point_list, {x=sx,y=sy})
 end
 
 if outline or shadow then
  draw_polygon157(point_list,col,outline,shadow)
 elseif #point_list == 3 then
 	p01_triangle_163(
 	point_list[1].x,point_list[1].y,
 	point_list[2].x,point_list[2].y,
 	point_list[3].x,point_list[3].y,
 	col)
 elseif #point_list == 4 then
 	p01_triangle_163(
 	point_list[1].x,point_list[1].y,
 	point_list[2].x,point_list[2].y,
 	point_list[3].x,point_list[3].y,
 	col,outline,shadow)
 	p01_triangle_163(
 	point_list[1].x,point_list[1].y,
 	point_list[4].x,point_list[4].y,
 	point_list[3].x,point_list[3].y,
 	col)
 else
	 draw_polygon157(point_list,col,outline,shadow)
 end
end

function dist3d(self,obj)
 
 if self.x == nil then
 	self.x = self[1]
 	self.y = self[2]
 	self.z = self[3]
 end
 
	floor_dist =
	 dist2d(self.x,self.z,obj.x,obj.z)
	
	return dist2d(self.y,0,obj.y,floor_dist)
end

--by tetrapengwin
function dist2d(x1,y1,x2,y2)
	local xdif=x1-x2
	local ydif=y1-y2

	local atan=atan2(xdif,ydif)

	local xdist=cos(atan)*xdif
	local ydist=sin(atan)*ydif

	return xdist+ydist
end

--@p01
function p01_triangle_163(x0,y0,x1,y1,x2,y2,col)
 color(col)
 if(y1<y0)x0,x1,y0,y1=x1,x0,y1,y0
 if(y2<y0)x0,x2,y0,y2=x2,x0,y2,y0
 if(y2<y1)x1,x2,y1,y2=x2,x1,y2,y1
 col=x0+(x2-x0)/(y2-y0)*(y1-y0)
 p01_trapeze_h(x0,x0,x1,col,y0,y1)
 p01_trapeze_h(x1,col,x2,x2,y1,y2)
end
function p01_trapeze_h(l,r,lt,rt,y0,y1)
 lt,rt=(lt-l)/(y1-y0),(rt-r)/(y1-y0)
 if(y0<0)l,r,y0=l-y0*lt,r-y0*rt,0
 y1=min(y1,128)
 for y0=y0,y1 do
  rectfill(l,y0,r,y0)
  l+=lt
  r+=rt
 end
end

--poly from paranoidcactus
function draw_polygon157(points,col,outline,shadow)
 
 local xl,xr,ymin,ymax={},{},129,0xffff
 for k,v in pairs(points) do
  local p2=points[k%#points+1]
  local x1,y1,x2,y2,x_array=v.x,flr(v.y),p2.x,flr(p2.y),xr
  if y1==y2 then
   xl[y1],xr[y1]=min(xl[y1] or 32767,min(x1,x2)),max(xr[y1] or 0x8001,max(x1,x2))
  else
   if y1>y2 then
    x_array,y1,y2,x1,x2=xl,y2,y1,x2,x1
   end    
   for y=y1,y2 do
    x_array[y]=flr(x1+(x2-x1)*(y-y1)/(y2-y1))
   end
  end
  ymin,ymax=min(y1,ymin),max(y2,ymax)
 end
 
  
	if outline then
	 for y=ymin,ymax do
			pset(xl[y],y,col)
			pset(xr[y],y,col)
	 end
	elseif shadow then
	 for y=ymin,ymax do
	  if xl[y] != nil and xr[y] != nil then
		 darken(xl[y],y,xr[y]-xl[y],1) end
	 end
	else
	 for y=ymin,ymax do
			rectfill(xl[y],y,xr[y],y,col)
		end
	end

end

function sword(x,y,z,alt)
	
	
	
	local loctime = time()*.25
	
	
	local col1,col2,col3,col4
	= unpack_split"13,12,7,6"
	if alt then
		col1,col2,col3,col4
	= unpack_split"8,2,14,5"
	 loctime += .25
	end
	
	local xrot,zrot,tag =
	cos(loctime),sin(loctime),
	"e"
	
	for i = 0,1 do
		draw_shape(
		 1,
	  {
		  {x,y,z-i},
		  {x+xrot*2,y+12,z+zrot*2-i},
		  {x-xrot*2,y+12,z-zrot*2-i}
		 },
		 i == 0 and col1 or col2,
		 tag
	 )
	 tag = tag..",o"
 end
	
	--pyramid,x,y,z,w,h,d,cfrnt,csid,crsid
	draw_shape(5,
	x,y+14,z,6,-5,2,col4,col3,nil,col1-4,
	loctime,
	"e"
	)
	
end

shanimt,shanim,shanim2 = 0,0,100

swordhandle = box:new({

update = function(_ENV)
 shanim += (shanimt-shanim)*.1
 shanim2 = global.shanim2
 shanim2 *= .95
 global.shanim2 = shanim2
end,

draw = function(_ENV)
 sword(10,y-shanim2,z-25+shanim2,false)
 sword(-15+shanim*.5,y-10-shanim*.15,z+2-shanim,true)
end
})
-->8
--player
playerobj = box:new({

damage = function(_ENV,lavadmg)
 
	global.score_add -= 20
 
 dashcharged,doublecharged = true
 
 if not lavadmg and (hurt > 0 or bounce) then
 	return
 end
 
 add_particles(
	unpack_split"25,3,1,8,22,8"
	)
 
 add_particles(
	20,2,2,1,x,y,z
	)
 
 hurt = 120
 if lavadmg then
	 y = lavah - 10
		vy = -abs(vy)
		bounce = true
		if floor and floor.rownum then
			blockrow = floor.rownum
		end
	end
 
 hp -= 1
 
 if hp <= 0 then
  
  _ENV = global
  dead = true
 	
 	
 	death()
  
 	sfx"15"
 else
 	sfx"14"
 end
end,

update=function(_ENV)
 
 if wings == -1 then
 	wings = min(2,level-1)
 end
 
 if y > lavah then
 	damage(_ENV,true)
 end
 
 if bounce then
 	if floor and not level_summited then
 		if y <= floor.y-floor.h then
 			bounce = false
			end
			player.z = floor.z
			player.vx += (floor.x-player.x)*.03
			player.vy = -1.5
		else
			bounce = false
			floor = nil
		end
 end
 
 control = not (speech_active)
 jumpbuffer = max(0,jumpbuffer-1)
 
 if btn(⬆️) and control then
 	vz = (vz-speed)/1.25+speed
 elseif btn(⬇️) and control then
 	vz = (vz+speed)/1.25-speed
 else
 	vz /= 2
 end
 if btn(➡️) and control then
 	vx = (vx-speed)/1.25+speed
 elseif btn(⬅️) and control then
 	vx = (vx+speed)/1.25-speed
 else
 	vx /= 2
 end
 
 if control and (btnp(🅾️) or jumpbuffer > 0) then
  
  if floored or coyote > 0 then
	 	vy = -1.5
	 	jumping = true
	 	sfx"8"
	 	if floored then
	 	 jumps += 1
	 	end
	 	jumpbuffer = 0
		elseif level > 1 and doublecharged and shadowh-y > 10 then
				vy = -1
				sfx"12"
				jumping = true
				doublecharged = false
				dashing = 0
		elseif not bounce and btnp(🅾️) then
 		jumpbuffer = 10
 	end
 end
 coyote = max(0,coyote-1)
 
 if jumping then
 	if vy >= 0 then
 		jumping = false
		elseif not btn(🅾️) then
	  jumping = false
	  vy *= .5
		end
 end
 
 if level >= 3 and btnp(❎) and control and dashcharged then
 	dashcharged = false
 	dashing = 20
 	sfx"13"
 end
	
	if dashing != 0 then
		dashing -= 1
		vz += sin(ang)*.25
 	vx += cos(ang)*.25
 	squish -= .8-rnd(.4)
 	vy = -.2
 	
 	add_particles(
	1,1,-.5,10,x-vx,y-5,z-vz
	)
  
 	if btn()%16 == 0 then
 		dashing = 0
		end
 	
	end
	
	if hurt > 0 then
		hurt -= 1
	end
 
 y += vy
 x += vx
 z += vz
 
 
 --collision
 global.overlapi = nil
 shadowh = 100
 behind = false
 local was_floored = floored
 floored = false
 if not bounce then
 for obj in all(world) do
 	if obj.onscreen and not obj.nocollision then
 	 local loops = 0
 	 
 	 overlap,blap = collision(_ENV,obj)
 	 
 	 if obj.dmg and overlap != nil then
 	  damage(_ENV,obj.lavadmg)
 	 elseif obj.solid then
	 		if overlap != nil do
	 		 
	 		 if  abs(overlap.w) < abs(overlap.h)
	 		 and abs(overlap.w) < abs(overlap.d) then
	 			 x -= overlap.w
	 			 vx = 0
	 			end
	 			
	 			if  abs(overlap.h) < abs(overlap.w)
	 		 and abs(overlap.h) < abs(overlap.d) then
	 			 y -= overlap.h
	 			 vy = min(vy,0)
	 			 floored = true
	 			 doublecharged = true
	 			 dashcharged = true
	 			 coyote = 10
	 			 
	 			 
	 			 local floornum = ((floor and floor.num) and floor.num or -1)
	 			 
	 			 floor = obj
	 			 jumps = 0
	 			 
	 			 if not was_floored and floor.y-floor.h/2 >= y then
	 			 	
	 			 	if floor and floor.rownum then
		 			 	highest = floor.y-32
		 			 	if blockrow+1 != floor.rownum then
		 			 	 score_increase = flr((floor.rownum-1-blockrow)^1.5*15)
		 			 	 set_trophy(2)
		 			 	 if score_increase > 0 then
		 			 	 	sfx"10"
		 			 	 	global.score_add += score_increase
         end
		 			 	end
		 			 	blockrow = max(floor.rownum,blockrow)
		     end
	 			 	sfx"9"
      end
	 			 
	 			 
	 			 if not level_summited then
	 			 	if floor.lastblock then
	 			 		global.level_summited = true
	 			 		global.score_add += flr(lavah-highest)
							 start_convo(level*2-1)
		      hp = 3
		      
		      
							end
	     end
	 			 
	 			 shadowh = min(y+h/2,shadowh)
	 			end
	 			
	 			if  abs(overlap.d) < abs(overlap.h)
	 		 and abs(overlap.d) < abs(overlap.w) then
	 			 z -= overlap.d
	 			 vz = 0
	 			end
	 			
	 			overlap,blap = collision(_ENV,obj)
	 			
	 			
	 			
				elseif loops == 0 and blap.x and blap.z then
					shadowh = min(obj.y-obj.h/2,shadowh)
					floor = obj
					global.overlapi = blap
				end
			
			elseif obj.pickup then
			 if overlap != nil then
			 	
			 	add_particles(
	20,2,2,obj.col,x,y,z
	)
	    add_particles(
	25,3,1,obj.col,16,16
	)
			 	
			 	if obj.health then
			 		hp = min(hp+1,maxhp)
					else
						global.score_add += 25+5*level
					 if obj.egg then
					 	global.score_add += 60
      end
					end
					sfx"11"
			 	
			 	del(world,obj)
			 	
    end
			end
			
			
		end
 end
 end
 
 if floor then
 	if z > floor.z-floor.d/2 and y+3 > floor.y-floor.h/2 then
 		behind = true
		end
		if floored and floor.vx then
			x += floor.vx
			z += floor.vz
		end
 end
 
 vy += grav
 
 squishv += vy*.25
 squish += squishv
 
 squishv *= .8
 squishv -= squish * .1
 
end,

draw=function(_ENV)
 
 --shadow
 draw_shape(
	 1,
	 {
		 {x-w/2,shadowh,z},
		 {x+w/2,shadowh,z},
		 {x+w/2,shadowh,z-d/2},
		 {x-w/2,shadowh,z-d/2}
	 },
	 1,
	 "s"
 )
 
 if not ang or (abs(vx)>.1 or abs(vz) >.1) then
  ang = atan2(vx,vz)
 end
 
 local angdiff = ang-animang
 
 while abs(angdiff) > .5 do
 	angdiff -= sgn(angdiff)
 end
 animang += angdiff*.15
 
 local tags = "entity"
 
 if behind or bounce or hurt > 0 then
 	tags = tags..",o"
 end
 
 draw_shape(5,
  x,y,z,w,h+squish,d,
  currpal.player[1],currpal.player[2],nil,
  nil,animang-.25,tags)
 
 draw_shape(3,
  x,y-h/1.75-squish,z,2,4+level,"entity")
 
 for i = -.5,1,1.5 do
 draw_shape(
	  2,
	  0,0,3,8,
			x+(w/4)*i+cos(animang)*4,y-squish,z+sin(animang)*8,--pos
			w/4,h/2+squish
			,"entity"
	 )
 end
 
 
 draw_wings(x,y-2-squish,z,wings,animang-.25,13,12,vy,true,doublecharged,dashcharged)
 
end

})

_ENV = playerobj

maxhp,hp,
squish,squishv,
floored,blockrow,
coyote,jumpbuffer,jumping,
bounce,speed,shadowh,
hurt,jumps,doublecharged,
dashcharged,dashing,
highest,animang,wings
=
unpack_split(credit_text[24])


_ENV = global
-->8
--comp and physics


block = box:new(
{
solid = true,

update = function(_ENV)
 
 if moving then
  vx = x
  x = sin(cycle)*amp+rootx
  cycle += spd
  vx = x-vx
	end
	
	local failsafe = 0
	while lavah < y+h/2 do
		h -= 1
		y -= .5
		if player.floor == _ENV then
	 	player.floor = nil
  end
		
		if h <= 0 or failsafe > 20 then
			del(world,_ENV)
			break
		end
		failsafe += 1
	end
	
	if level_summited and not lastblock then
		del(world,_ENV)
	end
	
end
}
)



function collision(obj,_ENV)
 local xcol,ycol,zcol = 0,0,0
	
	xcol, ycol, zcol=
	collision_axis(x,w,obj.x,obj.w),
	collision_axis(y,h,obj.y,obj.h),
	collision_axis(z,d,obj.z,obj.d)
	
 overlap = {
 x=xcol.x,y=ycol.x,z=zcol.x,
 w=xcol.w,h=ycol.w,d=zcol.w
 }
	 
	return overlap.x and overlap.y and overlap.z and overlap, overlap
end

function collision_axis(x,w,ox,ow)
	local overlap = {}
	
	if
	ox-ow/2 == mid(x-w/2,ox-ow/2,x+w/2)
	then
		overlap.x = ox-ow/2
		overlap.w = x+w/2-overlap.x
		overlap.x += overlap.w
		overlap.w *= -1
	end
	
	if
	ox+ow/2 == mid(x-w/2,ox+ow/2,x+w/2)
	then
		overlap.x = x-w/2
		overlap.w = ox+ow/2-overlap.x
	end
	
	overlap.x = overlap.x and (overlap.x+overlap.w)/2
	
	return overlap
end
-->8
--ui

function ui_draw()
	
	rectfill(unpack_split"0,0,127,32,0")
	rect(unpack_split"1,1,126,31,6")
	rect(unpack_split"2,2,125,30,14")
	rect(unpack_split"3,3,124,29,5")
 
 
 --print("mem "..ceil((stat(0)/2048)*100).."%",5,5,15)
	--print("cpu "..ceil(stat(1)*100).."%",5,13)
	--print("polys "..#draw_shapes,5,21)
 
 for i = 0,player.maxhp-1 do
 	print("♥",6+i*9,5,1)
 	if player.hp > i then
 		print("♥",5+i*9,4,8)
		end
 end
 
 print(""..sub("000"..score,-4),5,13,6)
 
 if score_add != 0 then
  print((score_add>0and"+"or"")..sub("00"..score_add,-3),5,21,7)
 	if score_add_wait <= 0 then
 		score = max(score+sgn(score_add))
		 score_add -= sgn(score_add)
		else
			score_add_wait -= 1
		end
		if score_add == 0 then
			score_add_wait = 60
		end
 end
 
 if not level_summited then
	 zdist,ydist
	 =(endz-startz),(endy-starty)
	 
	 lavauiy,
	 playeruiy=
	 min(26,26-(lavah-starty)/ydist*16),
  26-(player.y-starty)/ydist*16
  
	 
	 playeruix,midy =
	 81+(player.z-startz)/zdist*40,
  (playeruiy+lavauiy)/2
	 
	 
	 if not mapblocklist or #mapblocklist == 0 then
	 	mapblocklist = {}
	 	for b in all(world) do
	 		if b.solid then
	 			add(mapblocklist,{x=81+(b.z-startz)/zdist*40,y=26-(b.y-starty)/ydist*16})
				end
			end
  end
  for b in all(mapblocklist) do
  	pset(b.x,b.y,1)
  end
	 
  line(unpack_split"81,26,120,26,14")
  line(unpack_split"120,26,120,10,14")
  
  
  lavadist = flr(lavah-player.highest)
  
	 print(sub("00"..lavadist,-3),54,max(14,lavauiy-7.5),6)
	 
	 line(81,lavauiy,75,lavauiy,5)
	 line(75,playeruiy)
	 line(playeruix,playeruiy)
	 line(75,midy,74,midy)
	 
	 fillp(▒)
	 rectfill(81,lavauiy,120,28,currpal.lava[3])
  fillp()
  pset(playeruix,playeruiy,currpal.player[1])
	 
	 print("\^o0ff"..levels[level],34,5,currpal.lava[3])
	 
 end
 
 if speech_y < 32 then
  camera(0,speech_y)
  for i = 1,3 do
   darken(unpack_split"0,0,127,32")
	 end
	 print(
		 speech_print
	 ,4,4,7)
	 
	 if #speech_print == #speech_text then
	  print("❎/🅾️",100,21)
	 end
	 local x,y = speech_params[1],speech_params[2]
	 
	 draw_polygon157(
	 {
	 {x=x,y=y-speech_y},
	 {x=96,y=32},
	 {x=120,y=32}},
	 1)
	 
	 camera()
 end
 
end


-->8
--world gen

endz,endy = 0,0

-->8
--items
item = box:new({
col=7,
colb=6,

pickup=true,
draw = function(_ENV)
 
 if not loaded then
 	loaded = true
 	if player.hp == 1 or rnd() < .25 and player.hp < player.maxhp then
 		health = true
 		col = 8
 		colb = 2
		end
 end
 
 rot -= .005
 for i = 0,1 do
 draw_shape(5,
 x,y+4*i,z+i,
 4,4-8*i,4,
 col,colb,colb,
 nil,rot+.25*i,"e")
 end
 if rot < -1 then
 	rot = 0
 end
 
 shadow(_ENV,floory and floory or lavah,"dith")
end

})
-->8
--entities

angel = box:new(
{

initfunc = function(_ENV)
if not init then
done = false
ang = .5
desiredang = .5
timeoff=rnd()-.5
animang=timeoff
purity = not (scorch or scrubs)
y = endy-20
z = endz+1+rnd()
if scrubs then z += 15 end
if purity then

	y -= 5
	h=12
	if level != 3 then
		x = -30
	else
	 x = 0
	end
else
	h=8
end
dx=x
dy=y
dz=z
init = true
end
end,

update = function(_ENV)
initfunc(_ENV)
x += (dx-x)*.1
y += (dy-y)*.1
z += (dz-z)*.1
animang += .001*sgn(timeoff)
if abs(animang) > .5 then
	animang -= sgn(animang)
end
squish = sin(time()*.4+timeoff)
ang += (desiredang-ang)*.1
while ang != mid(-.5,ang,.5) do
	desiredang -= sgn(ang)
	ang-= sgn(ang)
end
shadow(_ENV,endy-10,"s")
if y < camy - 20 and done then
	del(global.world,_ENV)
end
end,

draw = function(_ENV)
 initfunc(_ENV)
 
 draw_shape(4,
  x,y-10+squish,z,5,5,5,
  abs(ang) < .25 and col or col2,
  col,col,
  col,ang+sin(time()+timeoff)*.03,"e")
 
 draw_shape(5,
  x,y,z,w,(scorch and -1 or 1)*(h+squish),d,
  col2,col,col,
  col,animang-.25,"e")
 
 draw_wings(x,y,z+sin(ang),wings,ang,wingcol,wingoutlinecol,timeoff)
 
 
 for i = -.5,1,1.5 do
 draw_shape(
	  2,
	  0,16,3,8,
			x+(w/4)*i+cos(ang+.25)*4,y-10-squish,z+sin(ang+.25)*9,
			w/4+.15,h/2+squish+.3
			,"entity"
	 )
	end
	
	draw_shape(
  2,
  purity and 16 or scorch and 8 or 0,24,8,4,
		x+.5,y-14+squish,z+1,
		8,4
		,"entity"
 )
 
end
}
)

function draw_wings(x,y,z,wings,ang,wingcol,wingoutlinecol,timeoff,playerwings,doublecharged,dashcharged)
 wingflap = sin(time()+(timeoff or 0))
 
 if not playerwings then
 	doublecharged,dashcharged =
 	true, true
 end
 
	for j = 0,1 do
	if type(wings) != "number" then
		wings = 0
	end
 for i = 0,wings-1 do
  
  local q = 0
  if i == 1 and playerwings then
  	q = -4
  elseif i == 0 and playerwings and j==1 then
  	q = 4
  end
  wingcol += q
  wingoutlinecol += q
  	
  
  local xoff = cos(ang+i*.5)
  if playerwings then
  	xoff*=.5
  end
  draw_shape(
  1,
  {
  {x,y-4,z-j},
  {x+10*xoff,y-wingflap,z+10*sin(ang+i*.5)},
  {x+20*xoff,y+sin(ang+i*.5)-10-wingflap*2,z+20*sin(ang+i*.5)}
  }
  ,j == 0 and wingcol or wingoutlinecol,
  "e"..(j == 0 and "" or ",o")..((i==0 and doublecharged or i==1 and dashcharged) and "," or ",dith")
  )
 end
 end
end



boxbot = box:new(
{
w=6,
h=4,
d=6,
vy=0,
col=6,
spiked=false,
shooter=false,
squish = 0,
cycleup = true,

update = function(_ENV)
if floor then
 lowest_pos = floor.y-floor.h/2-h/2
	if y > lowest_pos then
		vy = 0
		y = lowest_pos
	else
		vy += .01
	end
	x = mid(floor.x-floor.w/2,x,floor.x+floor.w/2)
	z = mid(floor.z-floor.d/2,z,floor.z+floor.d/2)
end
y += vy
x += vx
z += vz
vx *= .99
vz *= .99
if not shooter then
 vx += rnd()*.05-.025
 vz += rnd()*.05-.025
end
vx -= (x-floor.x)*.001
vz -= (z-floor.z)*.001
overlap,blap = collision(_ENV,player)

if overlap then
	if player.vy > .1 and not spiked or player.dashing != 0 then
		player.jumping = true
		player.doublecharged = true
 	player.dashcharged = true
 	player.dashing = 0
		player.coyote = 10
		player.y -= player.vy
		global.score_add += 25*player.jumps*(spiked and 2 or 1)
		if spiked then
			set_trophy(3)
		end
		del(global.world,_ENV)
		player.vy = -1.5
		sfx"11"
		player.jumps += 1
		add_particles(
20,2,2,6,x,y,z
)
	else
	 player:damage()
		player.vx = sgn(player.x-x)
		player.vz = sgn(player.z-z)
		player.vy = -1
	end
end

if shooter then
	spiked = false
	if cycleup then
		squish += (6-squish)*.01
		if squish > 5 then
			cycleup = false
			col = 2
		end
	else
		squish += (0-squish)*.1
		if squish < .6 then
cycleup = true
col = 6
local ang = atan2(player.x-x,player.z-z)
sfx"12"
add(world,
box:new({
w=3,h=3,d=3,
x=x,y=y,z=z,dmg=true,
vx=cos(ang),vz=sin(ang),
vy=0,
vs=.008,
vg=.001}))
		end
	end
end
end,

draw = function(_ENV)
 
 playerabove = false
 if abs(player.z-z) < 9 and abs(player.x-x) < 9 then
 	player.shadowh -= 10
 	playerabove = true
 end
 
 draw_shape(4,
 x,y-squish/2,z,w,h+squish,d,
 level == 2 and 14 or col,
 5,
 5,
 playerabove and 5 or 14, player.z < z and "" or "e")
 
 if not shooter or true then
	 draw_shape(
		  2,
		  0,8,8,8,
		  x+.4,y,z-4,
		  5,5,"entity")
	 
	 if spiked then
	 	draw_shape(5,
	 x,y-h,z,w/2,h,d/2,7,6,5,nil,"entity")
	 end
 end
 
 if floor then
  shadow(_ENV,floor.y-floor.h/2-1)
 end
 
end

}
)

_ENV = angel
hp,squish,ang,animang,wings,
scrubs,scorch,init,col,col2,
wingcol,wingoutlinecol,
desiredang,done,cycle,cycleup,init

= unpack_split"0,0,0,0,2,false,false,false,7,6,1,10,.5,false,0,0,false"
_ENV = global
-->8
--menu + parens8
function nothing()
	
end

function to_menu()
	game_update = menu_update
 game_draw = menu_draw
 game_init()
 return true
end


function logo_render()
	draw_wings(unpack_split"-25,-19,100,2,0,13,12,0,true,true,true")
 sword(unpack_split"13.5,-22,100,true")
 sword(unpack_split"-6.1,-9,100")
 foreach(draw_shapes,get_order_val)
 
 draw_shapes = insert_sort(draw_shapes)
 
 foreach(draw_shapes,render_shape)
	fillp()
	draw_shapes = {}
	
	spr(unpack_split"3,20,16,8,3")
	spr(unpack_split"55,52,40,2,1")
	spr(unpack_split"45,88,24,1,2")
	spr(unpack_split"60,80,32")
	sspr(unpack_split"88,0,17,18,34,36")
	sspr(unpack_split"85,23,11,9,62,44")
	sspr(unpack_split"85,23,11,9,74,45,12,9")
	spr(unpack_split"46,86,39,2,2")
end

#include ps8_vm.p8l
reload(0x8000, 0, 0x4300, "bytecode.p8")
run_ps8(chr(peek(0x8002, %0x8000)))


scrubs = angel:new(
{x=0,scrubs=true,
col=13,col2=1,wingcol=7,
wingoutlinecol=1}
)
scorch = angel:new(
{x=30,scorch=true,init=false,
col=9,col2=15,wingcol=8,
wingoutlinecol=4}
)
angel.scorch = false
angel.scrubs = false

game_update = menu_update
game_draw = menu_draw
__gfx__
070000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ddddccdcccc1000000011000000000000
11700e00002f22000fffff000000000000000000000000000000000000000000000000000000000000000000000000ddddddddddddd000000177100000000000
1610e02002200220fff0fff0000000000022f000000000000000000000000000000000000000000000000000000000ddd1d1dddd1d1000000177100000000000
11600200020210f0ff000ff0000000002222f00000000000000000000000000000000000000000000000000000000ddd100000000000000001e7711110000000
111020000f012020ff000ff0000000022422200000000000000000000000000000000000000000000000000000000dddd00000000000000000177e7e71000000
d1100000022002200fffff000000000242222f0000000000000000000000000000000000000000000000000000000ddd0000000000000000011777777e100000
d11000000022f2000000000000000002220222000000000000000000000000000000000000000000000000000000dddddcdddcc100000000177e77777e100000
0d000000000000002ff9ff2400000042220022f000000000000000000000000000000000022f2f40000000000000dddddddddddd000000001777777eeee10000
0000000000000000429f9240000000224000422fff0000022f2ff0000000000000000000222222f0000000000000dddd1111111100000000017777e111e10000
000000000042f40000000000000000222400222fff000002222222f00000000000000002222f222000000000000d1ddd000000000000000000117e111e100000
70000007042002400fffff00000fff2222442222ff00002222222f2f00022ff222f0002222002220000000000001ddd0000000000000000000001eeee1000000
170000710f014020ff000ff00ffff22224444222f00002242204222200422222222f00224004222000000000000d1d1000000000000000000000011110000000
11000011020410f0ff000ff00222222244400422f0000242200042220042222f2222f022244222000000000000d1d10000000000000000000000000000000000
d100001d04200240fff0fff004422222000011222000022240000222f0222200f22220222222240000000000001d1d0000000000000000000000000000000000
0d0000d0004f24000fffff0000112222101110422f00022240000422f04240002222f04222240002f400000001d1d10000000000000000000000000000000000
00000000000000000000000000022220111100422f00422240000422202224442222f042200000222f000000111d100000000000000000000000000000000000
0700700007007000428f9a7000042220110011022ff0442200000044204222222222f04422004222220000001111d000000000000000000000000000000ddcc0
7e77d7007d77e70001d3c670000422011000001422f04444000000000004444422222044222222222000000011110000000000000000000000000000000dddc0
7e77d7007d77e7000145e670000442100000000442f00000000000000000000042222004422222240000000000000000000000000200000000000000001dddd0
7e77d7007d77e7000000000000044400000000000000000000000000000000000422200044444200000000000000000000000000f00000000000000000dddd00
7577170071775700000000000000000000000000000000000000000000000000022200000000000000000000000000000000000f200000000000000001ddd100
e5ed1d00d1de5e0000000000000000000000000000000000000000004f00040f42220000000000000000000000000000000000020000000000001dd00dddd000
e5ed1d00d1de5e00000000000000000000000000000000000000000004400f22222400000000000000000000000000000000000002f2fff00001dccd0ddc1000
0e00d0000d00e000000000000000000000000000000000000000000002444422222000000000000000000000dcdcdcc00000000022222f0000ddcddd1dcd0000
066706700220022009ffff90088888800222222000000000000000000422222444000000000000000000000dddddddcc000000002220000000dddddddddd0000
ee666667280000829000000a88888888222222220000000000000000044444440000000000000000000000dddddddddc000000002224000001ddd000ddd10000
0eeeeee08f0000f80aaaaaa08888888822222222000000000000000000000000000000000000000000000ddddd10dddd0000000042222f000ddd1000ddd00000
00000000f990099f000000008888888822222222000000000000000000000000000000000000000000000ddd11000ddd00000000002222f00dddd100dcd00000
00000000000000000000000088888888222222220000000000000000000000000000000000000000000001ddd100dddc000000420000222001dddd1dddd00000
000000000000000000000000888888882222222200000000000000000000000000000000000000000000011ddd11dddd0000002220042220001ddddddcd00000
0000000000000000000000008888888822222222000000000000000000000000000000000000000000000111ddddddd000000044222222400011dddddd100000
00000000000000000000000008888880022222200000000000000000000000000000000000000000000000011111dd0000000004442224000000111111000000
5080a00000100000333333337730333379822228003373732222222222773339333233223a323332b32323333330309301111101170002122111822211213223
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bfbd9d31bdbd71fffffdfd7cadad74ffffffffffffff5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
301010101000000000002020202030002261c1b0c170400000000030300000000000000000306000000000007050700050500000000000007050700000000000
0000000000000000808080404000002090900000000000004141f321f3a0a00080c3a0e041f02000b0b04040c1a1200060903063d19063004020000000000000
4020101010102000204040404020100090a0c073c04140004040c3b08080000000000000000020100000c3320000000000000000000020000101808080404000
e0b1b1b1b1b1e000c0e0c0c0c0c0c100f08181c06030f100f08181e08181f000c0a0b0b0f1c0c000f130f08181b1e000e13030f0b1b1e000f18181c0c0c0c000
e0b1b1e0b1b1e000e1b1b1e1818181000020000000001000002000000000201080c0e7f7e7c0800000c33000837000008081f3f7f3818000e011018040000020
e011d353d016e300038242f722221c00c34443222464b300c52393101013e100c14282272a62b100c12a26f01012e100c3e48080f1926000c52310911315e000
2424227297111100e083808080c04136e11111a689c060602121a07050901300404020202010f4033637a56525949c003233a26222121c00c12222121111e000
a3642422a7101010c12222121171e807a36424a360509300c32620c003768300f087808040404000322221211111e600343424242e41c000343525a5a2626c00
3434224381c26c003c2221cd0301e060d33203c0a110f403703030303030700040408080800101007060606060607000c0a011010000000000000000000000f3
10604000000000000000e001e191f000404020e02111f0000000c1201010e100010101e11190e0000000e0907011e000814030e0202020100000e091e1018160
202010d031119000400020202010100080008080808090602020a06030509000404020201010e0000000b1d2521211000000d031111190000000c1221211e000
00a16222e120101000619111e1010180000020e0311010000000e1306081f000404070c040404020000022221211e10000001212214181000000111252b29100
000021a040a0110000001111e10111e00000e302c130f100c04020302040c000808080808080800060408081804060000000e29100000000ffffffffffffffff
bfbd9d31bdbd71ff00c3c102f3f3730000c1e0f3f300e100ffffffffffffffff01c3e7c1e3f74000ffffffffffffffffffffffffffffffff007073e3e1c04000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff81c2e0e1e613f100ffffffffffffffff00e77ebdbd7ee7000033c07373408000
ffffffffffffffffffffffffffffffffc0c3f3f1e3f33000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00e7bd7e7ebde700
fffffffffffffffff755f755f755f70080e340e35594e0002122121010916000c106e1120201c000c106c331c4a291004346f143f454620084f542222211d000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6373c75373c796731613c7c03645869637029637029647e20214c6c602478656a077f627c6467237027716475627e232d2c7c7c7c0366427f6d6024786560237
b69656370247f6a0478656023657272756e647370247f6a04786560256162747860296473756c666e2323303c75303c796037613c77556c6c60246f6e656c202
c036353627572637c073e2a0940216d6020727f65746e2e2e232d2c7c7c795f65702b6e6f67702778616470236f6d65637a0e6568747e2326373c75373c79673
1613c7c036955637c202c073055727964797c036e232130343c75303c796735613c7c0669472c6c602d69637370297f657c202c036353627572637c066e23263
73c75373c796731613c7c03614e64602940297f657c202c0663536f6273686c036e23212c7d2e213c223c7e213c223c703c223326373c75373c796731613c7c0
36f48612a07586164772370247869637f332d2c7c7c7c0361402072796d696479667560266f627d6c2a02627f6577686470247f602c6966656f332130343c753
03c796735613c7c066944772370256873656074796f6e616c6c697a007572756e2e2e2323303c75303c796037613c724574702e6f6470207562766563647c697
0237f6e2a0e4f6478696e6760296370216e697d6f62756e2e2e232d2c7c7c794027796378656460247f60237565602c03697f657c073a0f66666c20226574702
163702c0663536f6273686c0730262a09402d65737470226560276f696e676c23212c7d2e22353c223c7e213c223c7e223c223323303c75303c796037613c794
4702963702c03697f65727c07302465747970247f6a07716378602167716970247869637026696e616c6a066f627d6e232d2c7c7c7354796c6c6c2029402d657
3747024716b6560216a0c0367796e676c073e20295f6570257e6465627374716e646c2a0940286f60756e2326373c75373c796731613c7c036e2e2e2940246f6
e20274f6f646269756c2a0c073055727964797e23212c7d2e22353c223c7e213c223c7e223c213323303c75303c796133613c774f6f646269756e23212c7d2e2
2353c233c7e213c223c7e223c21332130343c75303c796735613c7c066e2e2e284f6770296e646563656e647e232d2c7c7c7c066641627567756c6c6c202c036
353627572637e23212c7d2e22353c233c7e213c233c703c213326373c75373c796731613c7c036e2e2e232d2c7c7c7c036d49702c61637470274f6f646269756
e2a0a07796c6c60226560247f602c08397f657c036e232046373c75373c796731613c7c036e2e2e2f4b61697e202458656024727574786029637e2a0940246f6
02e6f64702779637860247f60246f6a0c08347869637c036e232d2c7c7c7c0367596478602f6e6c697021602c0737796e676c036c202d697a007f67756273702
46271696e656460296e647f6a0478696370227f6474756e602375616c232d2c7c7c7c036e2e2e216c6c6029402375656026696470247f60246f6a09637021696
460297f657e23212c7d2e22353c223c7e213c223c703c203326373c75373c796731613c7c0364516b65602d697027796e676e2a02556d656d62656270247f602
07275637370262a086f6c64602e8024777963656e232d2c7c7c7c0367596478602d69702c61637470207f6775627c20294a07796c6c6023756e6460297f65702
47f67716274637a077f627c6467237023627f677e6e232e732d2c7c7c7c036e4f6770247f6024627f677e6c2a096e60216e602f6365616e602f66602d69702f6
77e6a0362756164796f6e6e232a23204130343c75303c796735613c7c066140237561602f66602c0367516475627a0c06674966756e6027716970247f6023756
1602f666a0c093d41676d616c066e23212c7e253c223c7e23353c223c7e253c22332130343c75303c796735613c7c06614d602940247f602a6f696e602c03635
3627572637c066a0e6f677f33212c7d2e213c223c7e21353c223c7e253c223323303c75303c796037613c714c6d6f63747e2e2e20294470216070756162737a0
c036353627572637c07302661696c656460247f602279646a0573702f66602478696370226f647865627e232130343c75303c796737613c7c066f48602e6f6e2
0244f65637024786963702d65616e6a097f65702d6573747024716b65602d697a0c0737796e676c066f33212c7d2e213c223c7e223c223c7e253c22332130343
c75303c796735613c7c06644f60297f65702472757c69702e6f647a04727573747025737f3323303c75303c796037613c794e2e2e20247275737470297f657c2
0216e64602469646a0472757374702353627572637c2022657470296477237a016e60216364702f666024727573747e2e2e232d2c7c7c794e602d656e20294e6
02f657270207c616e60247f6a0d616b656024786560277f627c64602b6e6f677a00757279647970216761696e6e23212c7d2e213c223c7e21353c223c7e253c2
2332130343c75303c796735613c7c066940246f6e6724702c696b656029647c2022657470294a037570707f63756029402d6573747e2e2e23212c7d2e213c223
c7e223c223c7e253c22332130343c75303c796735613c7c066351697e2027586f6024656369646564602478656a077f627c646027716370296d607572756f3a0
75163702964702c07397f657c066f3323303c75303c796037613c7e2e2e24586164702963702e6f64702f666a096d607f6274716e63656e23212c7d2e213c223
c7e21353c223c7e253c22332130343c75303c796735613c7c0666496e656e2024516b65602d69702c0737796e676c066e2a0d49702469676e6964797e2323303
c75303c796037613c795f6572702469676e69647970296370216a037d616c6c60207279636560247f6020716970266f627a0075727964797e232130343c75303
c796735613c7c066955637e2e2e202c073055727964797c066e23212c7d2e22353c233c7e21353c213c703c23332130343c75303c796735613c7c066e2e2e232
04130343c75303c796735613c7c06695f6572702c0367796e676c066e2e2e2a0c03635362757267237027796e676c066e232d2c7c7c7c0669447027716370276
966756e60266275656c697e2a0458616470294023616e6024756c6c6e23212c7d2e22353c233c7e223c203c703c23332130343c75303c796735613c7c06645f6
0227f647027796478602478696370207c616e6e2a084562756723702d69702c0737796e676c066e232d2c7c7c7c066245747c202566756e60277964786024777
f6c2a0e6f67702478616470247865602169627a096473756c6660296370276f696e676c232d2c7c7c7c06697f6570277f6e67247022656021626c6560247f6a0
66c6970277964786f657470247861647020757275627a0478616e602c07360f613666667f69646c0660296473756c666e232d2c7c7c7c0662457470297f65702
3616e60207275637370279a047f60246163786024786560246962756364796f6e6a097f6577227560286f6c64696e6761232d2c7c7c7c066e4f67702265676f6
e65612023547f607a04786963702477796374756460237368656d656e232d2c7c7c7c0667496675602c073865627c066024786560266164756a0378656027616
675602c03657c09337c066e232e732130343c75303c796735613c7c066940286f607560294026696e64602c036353627572637c066a096e60247865602771667
5637e2e2e232a232046373c75373c796037613c7e2e2e27716370216e697478696e676e2e2e2a0566756270207572756f33212c703c223c7e21353c223c703c2
23326373c75373c796034623c7d497023777f6274612326373c75373c796037613c7940257e646562756374796d6164756460297f657e2a0955647c202e6f602
d61647475627e202940286166756a0e6f602e65656460266f627029647e232d2c75373c796037613c794028616675602f657477627f677e602a060f613666605
8656f6e69687c2023577f6274602f666a0342756164796f6e6e232a832d2c75373c796037613c7e4f677029402378616c6c602779656c6460260f6136666a0f4
e69787c2023577f6274602f666a0445637472757364796f6e6e2326373c75373c796037613c794724602478696e6b6024786963702d6573686a0265647475627
023757964756460247f6a036f6d6261647e232d2c7c7c7e2e2e232d2c7c7c7e4f6470267562797024716c6b61647966756c2a01627560297f657f332d2c7c7c7
95f657270236f6d60716e6970277f657c646a046f602e6f6478696e6760247f6025616375602478656a0c6f6e6c696e6563737e232a832d2c7c7c7c456470257
370256e6460247869637e2a054e6027616274656e2320632130303c73323c796137613c7c083052554353502790245f40235c4143584326373c75373c7960336
13c7f486e2024496371627d65646027796478602f6e656a037472796b656e2023586f67737029402e656675627a0472757c69702c696b656460260f6136666f4
e69787e232d2c7c7c79402e6566756270247f6f6b60247f6029647c2a0e6f6270247f602465637472757364796f6e6e2a055e64796c602e6f677e2326373c753
73c796037613c760f613666665f49444120254e67657c6660247869637a06696e616c602c616e646d6163737123204130303c73323c796037613c7e2e2e29402
375656e2024577f6023747f6c656e6a07796e6763702d6169702e6f6470216c6f6e656a0166666f627460266c696768647c232d2c7c7c7265747027796478602
47861647023777f62746c2a096470246f65637e232d2c7c7c7458696370296370237472716e67656e2a014c6c60247865602c616e6460296370276f6e656e232
d2c7c7c77556021627560216c6c60247861647723702c6566647e232d2c7c7c794026656162702478696370207c616e602771637a0d69637765796465646e202
4586f657768647a096470247f6f602c6164756e232d2c7c7c72457470297f657027696675602d6560286f60756e2a0c45647025737025737560247861647a060
f61366663777f62746e232d2c7c7c725563786160756024786560277f627c6460296e6a0075627665636470266f627d6e2327832130303c73323c796137613c7
c016072756373702e80247f602163636560747a0c083072756373702790247f60237c616378632130303c73323c796037613c7955637e20245f6765647865627
c2027756023616e6a0d616b65602160277f627c6460247861647027796c6c6a0e656675627024656361697e232a2320403c73323c796633603c714c6c602c696
6796e67602265696e6763702162756a0d69702071677e637e2322343c75363c796633603c7546756e602055727964797e2e2e2a054370756369616c6c6970205
5727964797323323c76303c796633603c73586560237167702d69702d6f64796675637a016370216c69676e6564602779647860286562737e2a0d496374716b6
56e6c697e2324303c75363c796633603c7e4f6478696e676023616e60226560296d607572756a0966602e6f6478696e67602568796374737c2324333c74383c7
96633603c726574702e6f6478696e676023616e6022656a00757275602966602e6f6478696e676a0568796374737e2324363c73383c796633603c7955647c202
3786560216c6d6f63747a06657c66696c6c6564602d656e2029402771637a016c6d6f63747021647020756163656e2325343c73363c796633603c7955647c202
16023796e676c65602265696e676c2a026f627e602f66602072796d696479667560266f627d6c2a0075627379637475646e2326363c73383c796633603c714c6
c602c6966796e67602265696e6763702162756a0d69702071677e637e2022457470247869637a0c6964747c6560207972716d69646c2328303c74363c7966336
03c79447023716c6671676564602478656a03777f6274602f66602362756164796f6e6e232130303c75393c796633603c714e6460237f602d697023747275776
76c656a026567696e6370216e65677e23204130303c7130303c73613c7c093458616e6b60297f6570266f6270226f64786a007c6169796e676026202d6163747
562796e67612a0d2b4166716e632a2320460f6136666269702c03677164756273260f6136666269702c083669627563260f6136666269702c00367f696463204
60f6136666c03677164756273260f6136666c083669627563260f6136666478656a0c073a0300330033003403654e64602f666024786560275f627c646a0c023
a040168236f6e6762716473712920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhh8hhhhhhhhhhhhhhhhhhhhhhhhhchhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhh88hhhhhhhhhhhhhhhhhhhhhhhcchhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhh8898hhhhhhhhhhhhhhhhhhhcsschhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhh889998hhhhhhhhhhhhhhhcssscchhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhh8889998hhhhhhhhhhhhhcsssscchhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhh88999998hhhhhhhhhcssssscchhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhh8889999998hhhhhcssssssscchhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhh8899999998hhhcssssssscshhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhh8899999999cssssssssschhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhh899999998scssssssscshhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhh998999998922psssssschhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhh88999982222pcsssscshhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh82hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhh9899822i222hcssschhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhh898h2i2222phscchhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhh89hh222h222hhschhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhh8hhi222hh22phhchhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh22p2pihhhhhh222hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhh22ihhhi22ppphhhhh22p2pphhhhhhhhhhhhhhhhhhh222222phhhhhh222hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhh222ihh222ppphhhhh2222222phhhhhhhhhhhhhhhh2222p222hhhhh8282hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhppp2222ii2222pphhhh2222222p2phhh22pp222phhh2222hh222hhhhh8282hhhhh2hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhpppp2222iiii222phhhh22i22hi2222hhi22222222phh22ihhi222hhhhh8282hhhhphhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhh2222222iiihhi22phhhh2i22hhhi222hhi2222p2222ph222ii222hhhhhh2882hhhh2hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhii22222hhhh11222hhhh222ihhhh222ph2222hhp2222h2222222ihhhhhh28822hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhh1122221h111hi22phhh222ihhhhi22phi2ihhh2222phi2222ihhh2pihh28822hhhh2p2ppphhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhh2222h1111hhi22phhi222ihhhhi222h222iii2222phi22hhhhh222phh28822hhh22222phhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhi222h11hh11h22pphii22hhhhhhii2hi222222222phii22hhi22222h828882hhh222hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhi22h11hhhhh1i22phiiiihhhhhhhhhhhiiiii22222hii222222222hh828882iih222ihhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhii21hhhhhhhhii2phhhhhhhhhhhhhhhhhhhhhi2222hhii222222ihiii88882m5hi2222phhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhiiihhhhhhhhhhhhhhhhhhhhhhhhhhhhhchhhhhi222hhhiiiii2hhhh555555m5hhhh2222phhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1ssssccsccchhhhchhhhh222hhhhhhhhhhhhhhh55555mhi2hhhh222hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhssssssssssshiphccihpi222hhhhhhhhhhhhhhh555555h222hhi222hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhsss1s1ssss1hhiiccp22222ihhhhhhhhhhhhhhhh555mhhii222222ihhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhsss1hhhhhhhhhh2iiii22222hhhhhhhhhhhhhhhhh555mhhhiii222ihhhsscchhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhsssshhhhhhhhhhi22222iiihhhhhhhhhhhhhhhhhhh55hhhhhhhhhhhhhhssschhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhssshhhhhhhhhhhiiiiiiihhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1sssshhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhssssscssscc1hhhhcschhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhsssshhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhsssssssssssshhhhcschhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1sss1hhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhssss11111111hhhhcscshhhhhhhscscscchhhhhhhhhhhhhhhhhh1sshhsssshhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhs1ssshhhhhhhhhhhhcsschhhhhhssssssscchhhhscsscscchhhh1sccshssc1hhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1ssshhhhhhhhhhhhhcsschhhhhssssssssschhhsssssssscchhsscsss1scshhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhs1s1hhhhhhhhhhhhhcsschhhhsssss1hsssshhsssssssssschhsssssssssshhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhs1s1hhhhhhhhhhhhhhcsschhhhsss11hhhssshsssss11hssssh1ssshhhsss1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1s1shhhhhhhhhhhhhhcsschhhh1sss1hhssschsss11hhhhssshsss1hhhssshhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1s1s1hhhhhhhhhhhhhcssschhhh11sss11ssssh1sss1hhhssschssss1hhscshhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh111s1hhhhhhhhhhhh99csssc99hh111ssssssshh11sss111ssssh1ssss1sssshhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1111shhhhhhhhhhhhh7c666666hhhh11111sshhh111sssssssshhh1sssssscshhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1111hhhhhhhhhhhhhhh766666hhhhhhhhhhhhhhhhh111111sshhhh11ssssss1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh766667hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh111111hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh6666hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh766hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh66hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhppppphhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhppphppphhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhpphhhpphhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhpphhhpphhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhi2pihhhppppphhh9hhhhhhhhhhahaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhahhhhhhhhhhhhhhhhahhhhhhhhhhhhhh
hhi2hh2ihhhhhhhhhh9pphhhhhhhhaahhhahhhahhhhhhhhhhhhhhhhhhhhhaahhhhhhhhhhhhhhhhhhhhhhhhhhaaaahhhhahhhhhhhhhhhhhhhhahhhhhhhhhhhhhh
hhph1ih2h2pp9pp2ih99pppphhhhhahhhhahhhahhhhhhhhhhhhhhhhhhhhahhhhhhhhhhhhhhhhhhhhhhhhhhhahhhaahaaahhhhhhhhhhhhhhaaahhhhhhhhhhhhhh
hh2hi1hphi29p92ihh999ppppphhhahhhahhhahhhhaaahhahhhahhhhhaahhhhahhhhhhaaahhaahaahhhhhhhahhhhhhhhaahhaaahhhahhhhhhaahhhhhhhhhhhhh
hhi2hh2ihhhhhhhhhh99pppphhhhhahaaaahhahhhhhhhahahhhahhhhhhaaahhaaahhhahhhahahaahahhhhhhhaahhhhhhahhhhhhahhaaahhhhahhhhhhhhhhhhhh
hhhip2ihhhppppphhh9pphhhhhhhahhhhhhhahhhhhaaaahhaaaahhhhhhahhhaahhahahhhhahahahhahhhhhhhhhaahhhhahhhaaaahaahhahhhahhhhhhhhhhhhhh
hhhhhhhhhpphhhpphh9hhhhhhhhhahhhhhhhahhhhahhaahhhhhahhhhhhahhhahhhhhahhhahhahhhhahhhhhaaahhaahhhahhahhaahahhhhhhhahhhhhhhhhhhhhh
hhhhhhhhhpphhhpphhhhhhhhhhhhahhhhhhhhaaahaaaahhahhhahhhhhhahhhahhhhhhaaahhhahhhahhhhhhhhhaaahhhahhhaaaahhahhhhhhahhhhhhhhhhhhhhh
hhhhhhhhhppphppphhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhaaahhhhhhahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhppppphhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhhhh7777hhhhhhhhhh7hhhhhhhhhhhhhhhh7hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhhh7hhh77hhhhhhhhh7hhhhhhhhhhhhhh777hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhhh777hh7hhhh7hh777hhh7hhhhhhhh7hhhhhhh777hhh7hhhh777hhhh777hhh77hhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhh7hh7hh7hhhh7h7hh7hhh7hhhhhhhhh77hhhh7hh7hhh7hhh7hh7hhh7hhhhhh7hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhh777hhhh7hh7hh777hhh7hhhhhhhhhhhh77hh777hhh7hhhh777hhh7hhhhhhh7hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhhh7hhh7hhh7h7hh7hhh7h7hhhhhhhh777hh77h7hhh7h7hhhh7hhh7h7hhhhhhh7hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhh7777hh7hh777hhhhh77hhh777hhh777hhhhhhhh777hhh777hhh777hh777hhh7777hh7hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh77hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh777h7hhhhhhhhhhhhhhhh7hhh7hhh7hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhh7hh77hhhhhhhhhhhhhhhhh7hhhhh777hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhh7hh777hh7hhhhh777hhhhhh7hh7hhhh77hh7777hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhhh777hh7hh7hhh7777hh7hhhh7hh77hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhh7hhhhhh77hh7h777hhh7hhh7hh7hhhh7hhh77hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhh7hhh77h7hhhhh7hhh7h7hh7hh7hhhhh7hhhhh77hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhh7777hh7hhhhhh777hhh777hh7hhhh7hhh7777hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh

__sfx__
910308100c0620c0720c0620c0320c0520c0520c0520c0520c0520c0420c0420c0320c0320c0420c0420c0520c0520c0520c0520c0520c0520c0520c0520c0520c0520c0520c0520c0520c0520c0520c0520c052
490308101816018140181501815018150181501815018140181301813018130181301813018130181301813018160181601816018160181601816018160181601816018160181601816018160181601816018160
900308100c3620c3720c3620c3320c3520c3520c3520c3520c3520c3420c3420c3320c3320c3420c3420c3520c3520c3520c3520c3520c3520c3520c3520c3520c3520c3520c3520c3520c3520c3520c3520c352
880308101827018250182601826018260182601826018250182401824018240182401824018240182401824018260182601826018260182601826018260182601826018260182601826018260182601826018260
930200002b6102b6102b6102b6102b6102d6103e6103c6103b6103961000000000000000000000376103461500000000000000000000000000000000000000000000000000000000000000000000000000000000
90030000101501c6501d6501c6500d1500a1500665004650046500565006650076500763007630066200362003620036200463000000066400662005610000000000000000000000000000000000000000000000
910f000000000000000000000000000000000000000000000000000000026100462006630076200c6100661000000000000000000000046200663004630036200362003610000000000000000000000000000000
900700000b610046200a6300e62000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300001072011740147301972500700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
920000000e7600f7701076011670106600e6500e6400d6300d6200d61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
900800000b4540f3541455416544125440f5440b5340f5341453416524125140f5140000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
30060000246430c6340c6340c6300c6200c6300b4540f3641456416554125540f5540b5440f5441453416534125240f5140000400004000040000400000000000000000000000000000000000000000000000000
910300001b6300d740116301571000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
900200001b6200d73011620157100f6100d6100b6100a6200a6200a6300a6300b6300c6400c6400e6500e6500f630106100070000700007000070000700007000070000700007000070000700007000070000700
8f010000077601477007760097600b6600d6600e6600e6600e6600e6600e6600e6600e6600b650086500865007650066400663004630046300463003620016200062000620006200000000000000000000000000
8e040000106601477024660097601c6600c660047700967009670096600a6700a6500e7500b6600865008660167600d6400a650086500763013730086100862004620046101b7200f74002610006100161000000
3510000009050000000c050000001005000000150500000009050000000c050000001005000000150500000007050000000c050000001005000000150500000007050000000c0500000010050000001705000000
3510000005050000000c050000001005000000150500000005050000000c050000001005000000150500000004050000000c05000000100500000015050000000e050000000c0500000010050000001705000000
c51000003084030830308303083034840008000080000800398403983039830398303b8403b802008000080037840378303783037830348400080000800008003584035830358323583035822358223582235822
c510000034840348303483034830308403080030800308002d8402d8302d8302d8302f8403b802308003080030840308303083030830328400000000000000003484034830348303483034840300000000000000
911000002882028830248402483028840288302d8402d8302d8202f8402f8302f8202b8402b8302b8202b8102b8402b830238402383026840268302983029820298202d8402d8302d82028840288302882028810
911000002882400000248402483028840288302d8402d8302d8202f8402f8302f8202b8402b83028840288302b84400000238402383026840268302984029830298202d8402d8302d82028840288302684026830
9510000009b4009b4009b4009b400cb400cb4015b4000b0009b4009b4009b4009b4010b4010b4015b4000b0007b4007b4007b4007b400cb400cb4013b4000b0007b4007b4007b4007b4010b4010b4017b4000b00
9510000005b4005b4005b4005b400cb400cb4015b4000b0005b4005b4005b4005b4010b4010b4015b4000b0004b4004b4004b4004b400cb400cb4007b400000004b4004b4004b4004b4010b4010b4017b4000b00
c51000003484034830348303483035850358103583035830378403783037830378303585035810358303583034840348353000034836328403283430000328363484034830348303483034820348203482034820
9510000005b4005b4005b4005b400cb400cb4015b4000b0005b4005b4005b4005b4010b4010b4015b4000b0004b4004b4004b4004b4002b400000000b4602b4002b4002b4000b4000b4000b4000b4000b4000b40
c5100000348403483034830348303784030800308003080035840358303583035830348403b802308003080032847348323483234832328453000030846328323283532836308563085230842308423083230835
c51000003083030820308203082034830008000080000800398303982039820398203b8303b80200800008003783037820378203782034830008002b8362f8222f8252f8262b8362b8322b8222b8222b8122b812
3510000005050000000c050000001005000000150500000005050000000c050000001005000000150500000004050000000c0500000010050000001505611040110350000010020000000e010000000c01500000
011000000c62507a00000000c62500000006360c6250000000000000000c625000000c6250000000000000000c62500000000000c62500000006360c6250000000000000000c625000000c6360c6150c62500000
011000000c62500000000000c62500000006360c6250000000000000000c625000000c6250000000000000000c62500000000000c62500000006360c625000000c600000000c6230000018633000002462500000
0110000024840000002d8402f8402b84000000288400000000000000002d8402f8402b84000000248400000024840000002d8402f8402b84000000288400000000000000002f8402d8402b840000002a84000000
0110000023840000002d8402f8402b84000000288400000000000000002d8402f8402b8400000021850000001f850000002d8402f8402b840000001e850000001c840000002b8402a84028840000001a86000000
c11000000762009620096200c62011630116400d6300962005620036200462007630096400c6300e6300d62008620076200664005630066200b6200e630096300562005620056200762008630076200563005620
c510000000b2000b3000b4000b3000b2000b3004b4004b3005b5500b0000b0000b000bb200bb300bb400bb3007b2007b3007b4007b3007b2007b2005b3005b4004b5500b0000b0000b0002b2002b3002b4002b35
c9060b002601500000000002101121025000002101500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c1100000189201c92721920189201c92021920189261c920189201092723920189201c92023920189261c92018920139271f92018920139201f920189261392017920139271f92017920139201f9201792613920
c1100000189201c92721920189201c92021920189261c920189201092723920189201c92023920189261c92018920139201f92018922139201f9201892118925179201792013920139201f9201f9252193021910
350d000009b4000b000cb4000b0010b4000b0015b4000b0009b4000b000cb4000b0010b4000b0015b4000b0007b4000b000cb4000b0010b4000b0015b4000b0007b4000b000cb4000b0010b4000b0017b4000b00
350d000005b4000b000cb4000b0010b4000b0015b4000b0005b4000b000cb4000b0010b4000b0015b4000b0004b4000b000cb4000b0010b4000b0015b4000b000eb4000b000cb4000b0010b4000b0017b4000b00
ad181b003f643000000f6452764500000276450f645000000f6350b0530b0330f6452764500000276450f645000000f6350b0530b0730f645276451b634276450f645000000f6350000000000000000000000000
ad1800000b150000000f14014150000001615012140000000f1300b150000000f14014150000001615012140000000f1300c150000000f14014150000001615012140000000f1300c1300c1350c1250c1250c115
8c18001e0b151000000f14014154141001615012140000000f1300c150000000f14014154151541615012140000000f1300d1500d1340f1401412014124161501915217162161421416514134121720000000000
d5181e003f643000000f64527645276351b64533665000002764527645276351b64533665276351b64533665276351b645336650f6001b64327633276351b65527633276351b65527633276353f6430000000000
03181e0000000000000f64527645276351b64533665000002764527645276351b64533665276351b64533665276351b645336650f6001b64327633276351b65527633276351b6552763327635000000000000000
95180000172261b2262022622226172261b2262022622226172261b2262022622226172261b22620226222260c2261b22620226222260c2261b22620226222260c2261b2262022622226002261b2262022622226
d41818000b7500b7500f7400f740147501475016750167500f7300f7300b7500b7550b7500b7500f7400f740147501475016750167500f7300f73014750147550000000000000000000000000000000000000000
d41818000b7500b7500f7400f740147501475016750167500f7300f73017750177550b7500b7500f7400f740147501475016750167500f7300f73014750147550000000000000000000000000000000000000000
d50a000013530185301a5301c5351f5352453526535285352b53524535265351f5351c5401c510185401c5101c540185101e5401c5101a5401e510215401a5102354023540235322353223522235222351223510
d50a000024530265302b530305353253534535375353453532535305352b535265352452024522245222451224512245122652026522265222651226512265122852028520285222851228512285122851228515
c5080000185301d53022530275352c5353353522525275252c5253352522515275152c51533515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e200c390c4330c4430452633546271762c0020c41303576245262c0020c41614147341622006032426345162e0500c0432d45421137211762040422506395062e506395062b5060a4400c433284062e4562e406
657265640d5272e51628556291762c050094400c406101662154725117141462556421556251172c05009440090602651432506395762e160374420a0503e00226576321022d576325262016021160211052f537
6f757263200163910210506325262e5172d0430a4400c036165642f4142f566305462c52632150094400c443145762b5262e1021350636526321500944009060384620d54633517204642f527335260a06023515
6e630a09251022f176204342912708527221500906024104101662154725117141462556421556251170a06037073200362f117204662f117251060c4330c01606506331272002429517345062e5162510206527
730a0c392d0023452634117211072517627537291760a06033025325462003435176231500946220007304030a060241052f166395362f176200343517623150094622000721117211762f546245162151634527
20746f201414638102345762000738002235762d566351762912739502201052c50639102261172f5662041534506321272016425137251662041525166255163410603117251262912733106125263452732176
6f7520680d5262e527201252f53627166251020d52733546231060511721517251021350636526201603840423127355062c1663910205117215172510213506365262011525127351172e106064763103626545
20202020211372510222526251760a0500a420261020c433200022000220002200022000220002200022000210527325462654625126201302f50326136195763510228506365260a06037002200022000220002
666f722020426335162110725126201302f50326136285762c12620870200272f102341173910221536215462e1060647631036261462f166241020e2023457620007325762352625126201462f1662410217202
2c302c302d5262e527201302f503261360a41523576325263a0022053521127251172013429117251061657629126205242e1273257630547205062e5362516633575261662f576241063106231062370032c003
2c7472752c0032c0032c0432c0432c0432c4132c012220622e003350623000633062330623006231062265062c51725162300623006230062265062c51725162265062c517251622e43335062330132c0032c003
000000002516234117355262c0032c0032c0032c46231000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 10594350
00 115a4350
00 10124350
00 11134350
00 10144350
00 11154350
00 16145b50
00 17155c50
00 16125950
00 17184350
00 10164350
00 11174350
00 16121050
02 191a1b1c
01 492e484b
02 492f4a4b
01 1d126150
00 1e186150
01 1d142150
00 1e152150
00 1d1f4350
00 1e205250
00 221d4350
00 22214350
00 211f6250
02 1e202162
01 16525950
00 17584350
01 161d5950
00 171e4350
00 16121d50
00 17131e50
00 16241d50
00 19251e50
00 24125d50
02 25185e50
01 101d4350
00 111e4350
00 161d1050
00 171e1150
00 101d2450
00 111e2550
00 161d1f50
00 171e2050
00 161d1250
00 171e1350
00 1612105d
02 191a1b1c
00 28294a4b
00 282a4a4b
00 2b294a4b
02 2b2a2c2d
00 41424344
00 41424344
00 41424344
00 41424344
03 62214350
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 30314344

