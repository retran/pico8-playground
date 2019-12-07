pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- sphere renderer
-- by Andrew @retran Vasilyev
-- https://twitter.com/retran/

light1 = -64
light2 = 64
light3 = -64

u = 0
v = 0

mode = 1

ambient = 0.2

offset = 0

zbuffer = { }
sintable = { }
costable = { }
asintable = { }
acostable = { }
sqrttable = { }

modelid = 1
model = { }

function _init()
  create_model_one()
end

function _draw()
 cls()
 zbuffer = {}

 for s in all(model) do
  render(s.x, s.y, s.z, s.radius, s.color, s.color2, mode)
 end

 color(11)
 if mode == 0 then
   print("ortho", 0, 0)
 else
   print("perspective", 0, 0)
 end
 print("fps: "..tostr(stat(7)), 0, 6)

 print("use \139\145\148\131 to rotate model", 0, 111)
 print("press \151 to change model", 0, 117)
 print("press \142 to change projection", 0, 123)
end

function _update()

 if (btn(2)) then
  u += 0.01
 end

 if (btn(3)) then
  u -= 0.01
 end

 if (btn(0)) then
  v -= 0.01
 end

 if (btn(1)) then
  v += 0.01
 end

 if (u != 0 or v != 0) then
  for s in all(model) do
   local rxz = s.z * cost(u) - s.y * sint(u)
   local rxy = s.y * cost(u) + s.z * sint(u)

   local rzx = s.x * cost(v) - rxy * sint(v)
   local rzy = rxy * cost(v) + s.x * sint(v)

   s.x = rzx
   s.y = rzy
   s.z = rxz
  end

  u = 0
  v = 0
 end

 if (btnp(4)) then
  mode += 1
  if mode == 2 then
   mode = 0
  end
 end

 if (btnp(5)) then
  modelid += 1
  if modelid == 4 then
   modelid = 0
  end

  if modelid == 0 then
    create_model_zero()
  elseif modelid == 1 then
    create_model_one()
  elseif modelid == 2 then
    create_model_two()
  elseif modelid == 3 then
    create_model_three()
  end
 end

end

function render(x, y, z, radius, color, colordark, mode)
 if mode == 0 then
  local px = flr(64 + x)
  local py = flr(64 + z)
  local pz = flr(y)
  rasterize(px, py, pz, radius, color, colordark, light1 - x, light2 - y, light3 - z)
 else
  local div = 1 - y / 150
  local px = flr(64 + x / div)
  local py = flr(64 + z / div)
  local pz = flr(y)
  local r = flr(radius / div)
  rasterize(px, py, pz, r, color, colordark, light1 - x, light2 - y, light3 - z) 
 end
end

function rasterize(x0, y0, z0, radius, color, colordark, l1, l2, l3)
 local lvec = sqrtt(l1 * l1 + l2 * l2 + l3 * l3)
 for y = -radius, radius, 1 do
  local angle = asin(y / radius)
  local width = flr(abs(cost(angle) * radius))
  for x = -width, width, 1 do
    local z = sqrtt(radius * radius - x * x - y * y)

    local x1 = x0 + x
    local y1 = y0 + y
    local z1 = flr(z + z0)

    local addr = y1 * 128 + x1
    local sz = zbuffer[addr]

    if (not sz or sz <= z1) then
     zbuffer[addr] = z1
     local light = (x * l1 + y * l3 + z * l2) / (radius * lvec) + ambient

     local c = dither(x1, y1, light)
     if (c == 1) then
      pset(x1, y1, color)
     else
      pset(x1, y1, colordark)
     end
    end
  end
 end
end

function dither(xc, yc, value)
    local ox = xc % 3
    local oy = yc % 3
    
    if value > 0.9 then
        return 1
    elseif value > 0.75 then
        if (ox == 1 and oy == 1) then
            return 0
        end
        return 1    
    elseif value > 0.6 then
        if (ox == oy or abs(ox - oy) == 1) then
            return 1
        end
        return 0
    elseif value > 0.45 then
        if (ox == oy) then
            return 0
        end
        return 1    
    elseif value > 0.3 then
        if (ox == oy) then
            return 1
        end
        return 0    
    elseif value > 0.15 then
        if (ox == oy or abs(ox - oy) == 1) then
            return 0
        end
        return 1    
    elseif value > 0 then
        if (ox == 1 and oy == 1) then
            return 1
        end
        return 0
    end

    return 0
end

function sqrtt(a)
 local r = sqrttable[a]
 if not r then
  r = sqrt(a)
  sqrttable[a] = r
 end
 return r
end

function sint(a)
 local r = sintable[a]
 if not r then
  r = sin(a)
  sintable[a] = r
 end
 return r
end

function cost(a)
 local r = costable[a]
 if not r then
  r = cos(a)
  costable[a] = r
 end
 return r
end

function acos(a)
 local r = acostable[a]
 if not r then
  r = atan2(a,-sqrtt(1-a*a))
  acostable[a] = r
 end
 return r
end

function asin(a)
 local r = asintable[a]
 if not r then
  r = atan2(sqrtt(1-a*a),-a)
  asintable[a] = r
 end
 return r
end

function create_sphere(x, y, z, radius, color, color2)
 local s = { }

 s.x = x
 s.y = y
 s.z = z
 s.radius = radius
 s.color = color
 s.color2 = color2

 add(model, s)
end

function create_model_zero()
 model = {}

 create_sphere(0, 0, 0, 35, 15, 9)

 local x = 0
 local y = 0
 local z = 0

 x = cost(0) * 20
 y = sint(0) * 20
 z = 0
 create_sphere(x, y, z, 30, 14, 2)

 x = cost(0) * 40
 y = sint(0) * 40
 z = 0
 create_sphere(x, y, z, 20, 12, 1)

 x = cost(1 / 3) * 20
 y = sint(1 / 3) * 20
 z = 0
 create_sphere(x, y, z, 30, 11, 3)

 x = cost(1 / 3) * 40
 y = sint(1 / 3) * 40
 z = 0
 create_sphere(x, y, z, 20, 14, 2)

 x = cost(2 / 3) * 20
 y = sint(2 / 3) * 20
 z = 0
 create_sphere(x, y, z, 30, 12, 1)

 x = cost(2 / 3) * 40
 y = sint(2 / 3) * 40
 z = 0
 create_sphere(x, y, z, 20, 11, 3)
end

function create_model_one()
 model = {}

 local c1 = 15
 local c2 = 4

 create_sphere(0, 0, 0, 33, c1, c2)
 create_sphere(-27, 0, -10, 20, c1, c2)
 create_sphere(27, 0, -10, 20, c1, c2)
 create_sphere(-15, 0, 25, 20, c1, c2)
 create_sphere(15, 0, 25, 20, c1, c2)
 create_sphere(0, 0, -35, 25, c1, c2)
 create_sphere(-20, 0, -45, 10, c1, c2)
 create_sphere(20, 0, -45, 10, c1, c2)
end

function create_model_two()
 model = {}

 local c1 = 6
 local c2 = 5
 for x = -30, 30, 30 do 
  for y = -30, 30, 30 do
   for z = -30, 30, 30 do
    create_sphere(x, y, z, 7, c1, c2)
   end
  end
 end
end

function create_model_three()
 model = {}

 local x = 0
 local y = 0
 local z = 0

 create_sphere(x, y, z, 30, 10, 9)

 x = cost(1 / 10) * 40
 y = sint(1 / 10) * 40
 z = 0

 create_sphere(x, y, z, 5, 8, 2)

 x = cost(3 / 10) * 50
 y = sint(3 / 10) * 50
 z = 0

 create_sphere(x, y, z, 10, 14, 8)

 x = cost(8 / 10) * 70
 y = sint(8 / 10) * 70
 z = 0

 create_sphere(x, y, z, 8, 12, 11)
end