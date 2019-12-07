pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- fireworks demo by andrew @retran vasilyev

max_particles_count = 1024
particles_by_explosion = 100
gravity = 0.05
explosion_treshold = max_particles_count / 3
garbage_collection_count = 100

particles = {}
particles_count = 0

function _init()
    init_particles_pool()

    print(max_particles_count)
    print(particles_count)
end

function _update()
    if particles_count < explosion_treshold then
        make_explosion()
    end

    for i = 1, particles_count, 1
    do
        local particle = particles[i]
        particle.x += particle.dx
        particle.y += particle.dy

        if particle.y > 128 or particle.x < 0 or particle.x > 128 then
            destroy_particle(i)
        end

        particle.dy += gravity
    end

end

function _draw()
    cls()

    for i = 1, particles_count, 1
    do
        local particle = particles[i]
        pset(particle.x, particle.y, particle.color)
    end
end

function make_explosion()
    local x = 64 + rnd(100) - 50
    local y = 64 + rnd(100) - 50
    local color = rnd(15) + 1

    for i = 1, particles_by_explosion, 1
    do
        local particle = create_particle()

        particle.x = x
        particle.y = y

        local velocity = rnd(15) / 10
        local angle = rnd(360) / 360
        particle.dx = cos(angle) * velocity
        particle.dy = sin(angle) * velocity

        particle.color = color
    end

    sfx(0)
end

function init_particles_pool()
    for i = 1, max_particles_count, 1
    do
        local particle = {}
        particle.x = 0
        particle.y = 0
        particle.dx = 0
        particle.dy = 0
        particle.color = 0

        add(particles, particle)
    end
end

function create_particle()
    if particles_count >= max_particles_count then
        for i = 1, garbage_collection_count, 1
        do
            destroy_particle(1)
        end
    end

    particles_count += 1
    return particles[particles_count]
end

function destroy_particle(index)
    if index > particles_count then
        return
    end

    local particle = particles[particles_count]
    particles[particles_count] = particles[index]
    particles[index] = particle
    particles_count -= 1
end
__sfx__
000500003c670336702d6602966026650226501e6501c6401964017640166301363012630106300e6300d6300c6200b6200a6100a610096100861007610076100761007610066100661006610066100661000070
