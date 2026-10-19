
-- pico32 backend v4
do
-- font from SmellyFishstiks and para
memcpy(0x5600,0x800,0x500)
poke(0x5f58,129)

local curx,cury,_cartdata,_cd_id,save_addr,playtime,paused,paused_forced,curxt,curyt = 130,74,cartdata
function cartdata(id)
	if _cd_id ~= id then
		_cd_id = id
		_cartdata(id)
	end
end

local function unpause(n)
	if not paused_forced and n == 4 or not n then 
		paused = false
		sfx"4"
		if(on_unpause) on_unpause()
	end
end
local pause_i, pause_t, pause_items, custom_items = 1, 0, {}, {}

function _init()
	save_addr = 0x5e00 + cart_id*8
	playtime = get_playtime()
	if(game_init) game_init()
end

-- keep colors in editor
-- sets up display palette
?"⁶@5f2e0001\1⁶@5f100010\129\1\2\3\130\5\6\7\8\9\10\11\12\140\134\0"
local darken_pal, darken_16 = split"0,4,1, 0,4,14,6, 2,5,14,3, 13,1,5,0, 0", split"0,0,4,1, 2,4,14,6, 2,5,14,3, 13,5,2,14, 0,0,0,1, 4,4,5,14, 2,5,3,3, 1,4,5,14"

pal(15, 137, 1)

function darken(x, y, w, h)
	?"⁶j00⁶@5f540001\96"
	pal(darken_pal, 0)
	sspr(x-%0x5f28, y-%0x5f2a, w, h, x, y)
	?"⁶j00⁶@5f540001\0⁶!5f00\16\1\2\3\4\5\6\7\8\9\10\11\12\13\14\15"
end

-- replace time function to keep game consistent
local _t, _tn, _td, _ts = t, 0, 0, 60
function t()
	return _tn + _td/_ts
end
time = t


function pauseitem(i, name, func)
	if i > 0 and i < 11 then
		custom_items[i] = name and {name, func or function() end} or nil
	end
	pause_items = {{"Resume", unpause}}
	for i = 1,10 do
		add(pause_items, custom_items[i])
	end
	add(pause_items, {"Exit Chapter", function(n)
		if n == 4 then
			if(on_exit) on_exit()

			sfx"35"
			music(-1, 200)
			for i = 1, 24 do
				curx += i
				_draw()
				flip()
			end
			assert(load(stat"101" and "#pico32" or "pico32.p8"), "Cannot load launcher")
		end
	end})
end


local function up()

	?"⁶j00⁶!5f30\1" -- prevent pausing
	
	if btnp"6" then
		if paused then
			unpause(4)
		else
			pauseitem(0)
			paused, paused_forced = true
			sfx"4"
			if(on_pause) on_pause()

			if pause_t == 0 then
				darken(0,0,128,128)
				screen = {peek4(0x6000,0x800)}
			end
		end
	end

	pause_t = mid(1, pause_t + (paused and 2 or -2)/_ts)

	if pause_t == 0 then -- not animating pause transition
		_td += 1
		if _td >= _ts then

			_tn += 1
			_td = 0

			cartdata"pico32_achievements"
			-- increment playtime (only by full seconds)
			playtime = min(playtime + 0x0.0001, 0x5.7e3f) -- 99:59:59
			poke4(save_addr, playtime | $save_addr & 0xfff8)
		end

		game_update()
	end

	if paused then -- pause is open(ing) and ready for controlfp
		local pi = mid(1, pause_i+tonum(btnp"3")-tonum(btnp"2"), #pause_items)
		if(pi ~= pause_i) pause_i = pi ?"\a63i3v2x5c1"
		local p = pause_items[pause_i]
		for b in all"0145" do
			if(btnp(b) and p[2](tonum(b))) unpause()
		end
	end
end

_update60 = up

local pop_t, pop_s = 0
function _popup(s)
	pop_t, pop_s = 3, split(s)
end

function slerp(a, b, c, t)
	local t2 = 1-t
	return a*t2*t2 + (b*t2*2 + c*t)*t
end

function _draw()
	curxt, curyt = 130.5, 74.5
	if pause_t > 0 then
		
		poke4(0x6000, unpack(screen))

		-- opend to a better curve handler
		local bx, cx, cy, lx = slerp(0.5,128,64.5,pause_t), slerp(-63.5,32,128.5,pause_t), slerp(0.5,-30,0.5,pause_t), -2
		darken(cx-10, 0, 40-pause_t*10, 128)
		darken(0, 100, cx-10, 28)

		?"⁶j00⁶@5f550001\128⁶c7" -- poke(0x5f55, 0x80) cls"7"

		?"ᶠᶜ6⁶x3⁶w¹j_³e_⁶j1t⁵hi¹j_³e_",5,1 -- horizontal lines
		
		
		
		?"ᶠ\f7|\-e\f6\#7paused", 52, 3

		-- progress info
		local ticks = get_playtime()
		?"ᶠ\f7|\-e\f6\#7"..sub("0"..ticks\0x0.0e10, -2)..":"..sub("0"..ticks\0x0.003c%60, -2)..":"..sub("0"..ticks%0x0.003c/0x0.0001, -2),47,120
		for i = 1,5 do
			if(get_trophy(i)) ?"\-i\^o7ff\f6⁶:1f0e0e040e000000", i*6, 120
		end

		for i, p in inext, pause_items do
			local p = "ᵉ" .. p[1]
			local x, y = print(p, 64-print(p, 0, 1000)\2, i*10 + 55 - #pause_items*5, pause_i==i and 1 or 5)

			if(pause_i==i and paused) curxt, curyt = x, y
		end

		if(pause_draw) pause_draw()

		-- vertical bars on left
		?"ᶠᶜ6⁶y5⁶t⁶r1¹d█⁶j00³a⁶hᶜe¹d█⁶@5f000001\0⁶!5f54\128\96",-4,0
		
		for i = 0,1,0x0.02 do
			local x, y = slerp(0.5,bx,cx,i), slerp(0.5,0.5,cy,i)

			if x >= lx then
				if(x-lx < 0.7) pal(darken_pal, 0)
				sspr(i*128, 0, i<0.5 and 2 or 1, 128, x, y)
			else
				pal(0)
				rectfill(lx, y, x+1, y+127, lx-x > 0.5 and 14 or 5)
			end
			lx = x
		end
		pal(0)

		poke"0x5f54"
	else
		game_draw()
	end

	if pop_t > 0 then
		pop_t -= 1/_ts
		local y = max(abs(pop_t-1.5)-1.4) * 80 + 118
		for i = -9, 9 do
			darken(y-i,y+i,30,1)
		end
		?pop_s[_t()\0x.2%#pop_s+1],y,y
	end

	curx += curxt-curx >> 3
	cury += curyt-cury >> 3

	-- draw cursor
	if curx < 129 then
		spr(14,curx,cury,2,2)
	end
end

local function saddr(id)
	cartdata"pico32_achievements"
	return id and 0x5e00 + id*8 or save_addr
end

function set_highscore(n)
	poke4(saddr()+4, n)
end

function set_trophy(n)
	if n <= 5 then -- prevent messing with playtime
		if not get_trophy(n) then
			local a = saddr()+2
			poke(a, @a | 256>>n)
			if n == 1 then -- first trophy is from end game
			    music"63"
				_popup"⁶o910\fa⁶:41496b7d7f7f0000,\-h⁶oa08\f9⁶:22222a3e3e3e0000,\-h⁶o908\f2⁶:0808080808080000,⁶o210\f9⁶:22222a3e3e3e0000"
			else
				sfx"50"
				_popup"⁶o910\fa⁶:7f3e3a3e3e1c083e,\-h⁶oa08\f9⁶:3e1c1c1c1c1c081c,\-h⁶o908\f2⁶:0808080808080808,⁶o210\f9⁶:3e1c1c1c1c1c081c"
			end
			return true
		end
	end
end
function get_trophy(n, id)
	if n <= 5 then -- prevent messing with playtime
		return peek(saddr(id)+2) & 256>>n ~= 0
	end
end

function get_playtime(id)
	return $saddr(id) & 0x7.ffff
end

end