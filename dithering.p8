pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- simple 1-bit dithering by Andrew @retran Vasilyev

function _draw()
 cls()

 for x = 0, 128, 1 do
    for y = 0, 128, 1 do
        local intensity = x / 128
        local color = flr(y / 8) * dither(x, y, intensity)
        pset(x, y, color)
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
