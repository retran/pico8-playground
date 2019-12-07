pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- smoke by Andrew @retran Vasilyev

grid_width = 16
grid_height = 16

gradients = { }

function _init()
  cls()
  create_gradients()
end

function _update()
  update_gradients()
end

function create_gradients()
  gradients = { }
  for x = 0, grid_width, 1 do
    for y = 0, grid_height, 1 do
      local index = y * grid_width + x + 1
      local vec = { }
      local angle = rnd(100) / 100
      vec.x = cos(angle)
      vec.y = sin(angle)
      vec.a = angle
      gradients[index] = vec
    end
  end
end

function update_gradients()
  for x = 0, grid_width, 1 do
    for y = 0, grid_height, 1 do
      local index = y * grid_width + x + 1
      local vec = gradients[index]
      local angle = vec.a + 0.02
      vec.x = cos(angle)
      vec.y = sin(angle)
      vec.a = angle
      gradients[index] = vec
    end
  end
end


function _draw()
 for x = 0, 128, 1 do
  for y = 0, 128, 1 do
   local v = perlin(x / grid_width, y / grid_height)
   if v < 0 then
    local p = dither(x, y, v * 2 + 1)
    if p == 1 then
        pset(x, y, 6)
    else
      pset(x, y, 5)
    end

   else   
    local p = dither(x, y, v * 2)
    if p == 1 then
     pset(x, y, 7)
    else
     pset(x, y, 6)
    end
   end
  end
 end
end

function perlin(x, y)
 local ix0 = flr(x)
 local ix1 = ix0 + 1
 local iy0 = flr(y)
 local iy1 = iy0 + 1

 local x0 = ix0
 local x1 = ix1
 local y0 = iy0
 local y1 = iy1

 local sx = x - x0
 local sy = y - y0

 local n0 = 0
 local n1 = 0

 n0 = dot(ix0, iy0, x0, y0, x, y);
 n1 = dot(ix1, iy0, x1, y0, x, y);

 local x00 = lerp(n0, n1, sx)

 n0 = dot(ix0, iy1, x0, y1, x, y);
 n1 = dot(ix1, iy1, x1, y1, x, y);

 local x10 = lerp(n0, n1, sx)

 return lerp(x00, x10, sy)
end

function dot(ix, iy, gx, gy, x, y)
 local index = iy * grid_width + ix + 1
 local vec = gradients[index]

 local dx = x - gx
 local dy = y - gy

 return dx * vec.x + dy * vec.y
end

function lerp(a0, a1, w)
  return (1 - w) * a0 + w * a1
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
