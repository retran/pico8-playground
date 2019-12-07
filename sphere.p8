pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

light1 = 64
light2 = 64
light3 = 32

mode = 0

color = 1

ambient = 0

zbuffer = { }

function _draw()
 cls()
 if mode == 0 then
    light3 = 32
    render_sphere(32, 32, 30, 14, light1 - 32, light2 - 32, light3)
    render_sphere(64, 96, 30, 12, light1 - 64, light2 - 96, light3)
    render_sphere(96, 32, 30, 11, light1 - 96, light2 - 32, light3)
 elseif mode == 1 then
    light3 = 32
    render_sphere2(32, 32, 30, 14, 2, light1 - 32, light2 - 32, light3)
    render_sphere2(64, 96, 30, 12, 1, light1 - 64, light2 - 96, light3)
    render_sphere2(96, 32, 30, 11, 3, light1 - 96, light2 - 32, light3)
 elseif mode == 2 then
    zbuffer = {}
    light3 = 32
    render_sphere3(48, 48, 30, 14, 2, light1 - 48, light2 - 48, light3)
    render_sphere3(64, 76, 30, 12, 1, light1 - 48, light2 - 76, light3)
    render_sphere3(76, 48, 30, 11, 3, light1 - 76, light2 - 48, light3)
 elseif mode == 3 then
    zbuffer = {}
    light3 = 32
    render_sphere3(32, 32, 25, 14, 2, light1 - 32, light2 - 32, light3)
    render_sphere3(96, 32, 25, 11, 3, light1 - 96, light2 - 32, light3)
    render_sphere3(64, 64, 30, 9, 4, light1 - 64, light2 - 64, light3)

    render_sphere3(32, 96, 25, 6, 5, light1 - 32, light2 - 96, light3)
    render_sphere3(96, 96, 25, 15, 9, light1 - 96, light2 - 96, light3)

 else
    light3 = 96
    render_sphere(64, 64, 48, 10, light1 - 64, light2 - 64, light3)
 end
end

function _update()
 if (btnp(0)) then
  light1 -= 5
 end
 
 if (btnp(1)) then
  light1 += 5
 end
 
 if (btnp(2)) then
  light2 -= 5
 end

 if (btnp(3)) then
  light2 += 5
 end

 if (btnp(4)) then
  if mode == 3 then
   mode = 0
  else
   mode += 1
  end
 end
end

function render_sphere(x0, y0, radius, color, l1, l2, l3)
 local lvec = sqrt(l1 * l1 + l2 * l2 + l3 * l3)
 for y = -radius, radius, 1 do
  local angle = asin(y / radius)
  local width = flr(abs(cos(angle) * radius))
  for x = -width, width, 1 do
    z = sqrt(radius * radius - x * x - y * y)
    local light = (x * l1 + y * l2 + z * l3) / (radius * lvec) + ambient

     local x1 = x0 + x
     local y1 = y0 + y

     local c = dither(x1, y1, light)
     if (c == 1) then
      pset(x1, y1, color)
     else
      pset(x1, y1, colordark)
     end
  end
 end
end

function render_sphere2(x0, y0, radius, color, colordark, l1, l2, l3)
 local lvec = sqrt(l1 * l1 + l2 * l2 + l3 * l3)
 for y = -radius, radius, 1 do
  local angle = asin(y / radius)
  local width = flr(abs(cos(angle) * radius))
  for x = -width, width, 1 do
    z = sqrt(radius * radius - x * x - y * y)
    local light = (x * l1 + y * l2 + z * l3) / (radius * lvec) + ambient
    local x1 = x0 + x
    local y1 = y0 + y
    local c = dither(x1, y1, light)
    if (c == 1) then
     pset(x1, y1, color)
    else
     pset(x1, y1, colordark)
    end
  end
 end
end

function render_sphere3(x0, y0, radius, color, colordark, l1, l2, l3)
 local lvec = sqrt(l1 * l1 + l2 * l2 + l3 * l3)
 for y = -radius, radius, 1 do
  local angle = asin(y / radius)
  local width = flr(abs(cos(angle) * radius))
  for x = -width, width, 1 do
    local z = sqrt(radius * radius - x * x - y * y)

     local x1 = x0 + x
     local y1 = y0 + y

    local addr = y1 * 128 + x1
    local sz = zbuffer[addr] -- peek(addr)

    if (sz == nil) then
     sz = 0
    end

    if (sz <= flr(z)) then
     --poke(addr, flr(z))
     zbuffer[addr] = flr(z)
     local light = (x * l1 + y * l2 + z * l3) / (radius * lvec) + ambient

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

function acos(x)
 return atan2(x,-sqrt(1-x*x))
end

function asin(y)
 return atan2(sqrt(1-y*y),-y)
end
