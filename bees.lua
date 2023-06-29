--[[
    X Farming. Extends Minetest farming mod with new plants, crops and ice fishing.
    Copyright (C) 2023 SaKeL <juraj.vajda@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to juraj.vajda@gmail.com
--]]

local S = minetest.get_translator(minetest.get_current_modname())
local rand = PcgRandom(tonumber(tostring(os.time()):reverse():sub(1, 9)))

local function update_hive_infotext(pos)
    local meta = minetest.get_meta(pos)
    local data = minetest.deserialize(meta:get_string('x_farming'))
    local tod = minetest.get_timeofday()
    local is_day = false

    if tod > 0.2 and tod < 0.805 then
        is_day = true
    end

    if data then
        local text = ""
        if not is_day and data.occupancy > 0 then
            text = "The Bees are sleeping." .. "\n"
        elseif data.occupancy >= 3 then
            text = "The Bees are busy." .. "\n"
        elseif data.saturation >= 16 then
            text = "The Bees are teeming."
        end
        text = text .. 'Occupancy: ' .. data.occupancy .. ' / 3\n'
            .. 'Saturation: ' .. data.saturation .. ' / 16'
        meta:set_string('infotext', text)
    end
end

local function bee_particles(pos)
    minetest.add_particlespawner({
        amount = 20,
        time = 0.1,
        minpos = { x = pos.x - 0.25, y = pos.y, z = pos.z - 0.25 },
        maxpos = { x = pos.x + 0.25, y = pos.y, z = pos.z + 0.25 },
        minvel = { x = -0.5, y = -2, z = -0.5 },
        maxvel = { x = 0.5, y = -2, z = 0.5 },
        minacc = { x = -0.5, y = -2, z = -0.5 },
        maxacc = { x = 0.5, y = -2, z = 0.5 },
        minexptime = 0.5,
        maxexptime = 1,
        texture = 'x_farming_default_particle.png^[colorize:#FFD69C:255',
        collisiondetection = true
    })
end

local function update_bee_infotext(pos)
    local meta = minetest.get_meta(pos)
    local data = minetest.deserialize(meta:get_string('x_farming'))

    if data then
        meta:set_string('infotext', 'Hive position: ' .. data.pos_hive)
    end
end

-- how often node timers for plants will tick, +/- some random value
local function tick_hive(pos)
    minetest.get_node_timer(pos):start(math.random(15, 25))
end
-- how often a growth failure tick is retried (e.g. too dark)
local function tick_bee(pos)
    local light_level = minetest.get_node_light(pos)
    if light_level > 14 then
        minetest.get_node_timer(pos):start(math.random(90, 150))
    else
        minetest.get_node_timer(pos):start(math.random(40, 90))
    end
end

local function is_valid_hive_position(pos, params)
    if not pos then
        return false
    end

    local _params = params or {}
    local ommit_node_group_check = _params.ommit_node_group_check or false

    local hive_node = minetest.get_node(pos)

    if not hive_node then
        return false
    end

    if not ommit_node_group_check then
        if minetest.get_item_group(hive_node.name, 'bee_hive') == 0 then
            return false
        end
    end

    local meta_hive = minetest.get_meta(pos)
    local data_hive = minetest.deserialize(meta_hive:get_string('x_farming'))

    if not data_hive then
        return false
    end

    if not data_hive.occupancy then
        return false
    end

    if data_hive.occupancy >= 3 then
        return false
    end

    return true
end

local function get_valid_hive_position(pos_hive, pos_bee)
    local valid_pos = nil

    if pos_hive then
        valid_pos = vector.copy(pos_hive)
    end

    if is_valid_hive_position(valid_pos) then
        return valid_pos
    end

    valid_pos = nil

    -- Find neighboring bee hive position
    local hive_positions = minetest.find_nodes_in_area(
        vector.add(pos_bee, x_farming.beehive_distance),
        vector.subtract(pos_bee, x_farming.beehive_distance),
        { 'group:bee_hive' }
    )

    for _, p in ipairs(hive_positions) do
        if is_valid_hive_position(p, { ommit_node_group_check = true }) then
            valid_pos = p
            break
        end
    end

    return valid_pos
end

-- Hive give item
local hive_give_item = function(player, pos, stack)
    minetest.after(0, function()
        local inv = player:get_inventory()
        if inv:room_for_item("main", stack) then
            inv:add_item("main", stack)
        else
            minetest.add_item(pos, stack)
        end
    end)
end

-- Hive switcher
local hive_node_swap = function(pos, saturation, param2)
    if saturation >= 15 then
        minetest.swap_node(pos, { name = 'x_farming:bee_hive_saturated_2', param2 = param2 })
    elseif saturation >= 10 then
        minetest.swap_node(pos, { name = 'x_farming:bee_hive_saturated_1', param2 = param2 })
    elseif saturation >= 5 then
        minetest.swap_node(pos, { name = 'x_farming:bee_hive_saturated', param2 = param2 })
    else
        minetest.swap_node(pos, { name = 'x_farming:bee_hive', param2 = param2 })
    end
end

-- Hive timer
local hive_on_timer = function(pos, elapsed)
    -- Hive data
    local meta_hive = minetest.get_meta(pos)
    local data_hive = minetest.deserialize(meta_hive:get_string('x_farming'))
    local node = minetest.get_node(pos)

    if data_hive.occupancy == 0 then
        return
    end

    local flower_positions = minetest.find_nodes_in_area_under_air(
        vector.add(pos, x_farming.beehive_distance),
        vector.subtract(pos, x_farming.beehive_distance),
        { 'group:flower', 'group:bees_pollinate_crop' }
    )

    if not flower_positions then
        tick_hive(pos)
    end

    if flower_positions and #flower_positions > 0 then
        local random_pos = flower_positions[rand:next(1, #flower_positions)]
        local pos_bee = vector.new(random_pos.x, random_pos.y + 1, random_pos.z)
        local tod = minetest.get_timeofday()
        local is_day = false
        local light_level = minetest.get_node_light(pos_bee)

        if tod > 0.2 and tod < 0.710 then
            is_day = true
        end

        if data_hive and data_hive.occupancy > 0 and is_day and light_level > 13 then
            local pos_hive_front = vector.subtract(vector.new(pos.x, pos.y + 0.5, pos.z), minetest.facedir_to_dir(node.param2))

            -- Send bee out
            data_hive.occupancy = data_hive.occupancy - 1

            minetest.swap_node(pos_bee, { name = 'x_farming:bee', param2 = rand:next(0, 3) })
            tick_bee(pos_bee)

            minetest.sound_play('x_farming_bee', {
                pos = pos_bee,
            })

            bee_particles(pos_bee)
            bee_particles(pos_hive_front)

            -- Bee data
            local meta_bee = minetest.get_meta(pos_bee)
            local data_bee = {
                pos_hive = vector.new(pos):to_string()
            }

            meta_bee:set_string('x_farming', minetest.serialize(data_bee))
            meta_hive:set_string('x_farming', minetest.serialize(data_hive))

            update_hive_infotext(pos)
            update_bee_infotext(pos_bee)
        end
    end

    if data_hive and data_hive.occupancy > 0 then
        tick_hive(pos)
    end
end

-- Hive interact
local hive_on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    local stack_name = itemstack:get_name()
    local stack = itemstack
    local meta = minetest.get_meta(pos)
    local data = minetest.deserialize(meta:get_string('x_farming'))

    if not data then
        return itemstack
    end

    if stack_name == 'vessels:glass_bottle' or stack_name == 'x_farming:glass_bottle' and data.tick_hive >= 5 then
        -- Fill bottle with honey and return it
        itemstack:take_item()

        local pos_hive_front = vector.subtract(vector.new(pos.x, pos.y + 0.5, pos.z), minetest.facedir_to_dir(node.param2))

        hive_give_item(clicker, pos_hive_front, ItemStack({ name = 'x_farming:bottle_honey' }))

        hive_node_swap(pos, data.saturation - 5, node.param2)

        minetest.sound_play('x_farming_bee', {
            pos = pos,
        })

        bee_particles(pos_hive_front)

        data.saturation = data.saturation - 5
        if data.saturation < 0 then
            data.saturation = 0
        end
        meta:set_string('x_farming', minetest.serialize(data))
        update_hive_infotext(pos)

        tick_hive(pos)
    elseif stack_name == 'x_farming:honeycomb_saw' and data.saturation >= 5 then
        -- Add use to the tool and drop honeycomb
        itemstack:add_wear(65535 / 50)

        local pos_hive_front = vector.subtract(vector.new(pos.x, pos.y + 0.5, pos.z), minetest.facedir_to_dir(node.param2))

        hive_give_item(clicker, pos_hive_front, ItemStack({ name = 'x_farming:honeycomb' }))

        hive_node_swap(pos, data.saturation - 5, node.param2)

        minetest.sound_play('x_farming_bee', {
            pos = pos,
        })

        bee_particles(pos_hive_front)

        data.saturation = data.saturation - 5
        if data.saturation < 0 then
            data.saturation = 0
        end
        meta:set_string('x_farming', minetest.serialize(data))
        update_hive_infotext(pos)

        tick_hive(pos)
    end

    if data.occupancy == 3 then
        return itemstack
    end

    if minetest.get_item_group(itemstack:get_name(), 'bee') > 0 then
        data.occupancy = data.occupancy + 1
        meta:set_string('x_farming', minetest.serialize(data))
        update_hive_infotext(pos)
        itemstack:take_item()
        local pos_hive_front = vector.subtract(vector.new(pos.x, pos.y + 0.5, pos.z), minetest.facedir_to_dir(node.param2))
        hive_give_item(clicker, pos_hive_front, ItemStack({ name = 'x_farming:jar_empty' }))

        minetest.sound_play('x_farming_bee', {
            pos = pos,
        })
    end

    if data.occupancy > 0 and not minetest.get_node_timer(pos):is_started() then
        tick_hive(pos)
    end

    return stack
end

-- Hive
minetest.register_node('x_farming:bee_hive', {
    description = S('Bee Hive'),
    short_description = S('Bee Hive'),
    _tt_help = S("Houses Bees to produce Honey"),
    tiles = {
        'x_farming_bee_hive_top.png',
        'x_farming_bee_hive_bottom.png',
        'x_farming_bee_hive_side.png',
        'x_farming_bee_hive_side.png',
        'x_farming_bee_hive_side.png',
        'x_farming_bee_hive_front.png',
    },
    paramtype2 = 'facedir',
    groups = {
        -- MTG
        choppy = 2,
        oddly_breakable_by_hand = 1,
        bee_hive = 1,
        no_silktouch = 1,
        -- MCL
        handy = 1,
        axey = 1,
        building_block = 1,
        material_wood = 1,
        fire_encouragement = 5,
        fire_flammability = 5,
        -- ALL
        tree = 1,
        flammable = 2,
    },
    _mcl_blast_resistance = 2,
    _mcl_hardness = 2,
    sounds = x_farming.node_sound_wood_defaults(),
    on_timer = hive_on_timer,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local data = {
            occupancy = 0,
            saturation = 0
        }

        meta:set_string('x_farming', minetest.serialize(data))
        update_hive_infotext(pos)
    end,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        tick_hive(pos)
    end,
    on_rightclick = hive_on_rightclick,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local data = minetest.deserialize(oldmetadata.fields.x_farming)
        local positions = minetest.find_nodes_in_area_under_air(
            vector.add(pos, x_farming.beehive_distance),
            vector.subtract(pos, x_farming.beehive_distance),
            { 'group:flower', 'group:flora', 'group:bees_pollinate_crop' }
        )

        if positions and #positions > 0 and data.occupancy and data.occupancy > 0 then
            for i = 1, data.occupancy do
                local p = positions[i]

                if p then
                    local pos_bee = vector.new(p.x, p.y + 1, p.z)
                    minetest.swap_node(pos_bee, { name = 'x_farming:bee', param2 = rand:next(0, 3) })
                    tick_bee(pos_bee)
                    bee_particles(pos_bee)

                    if i == 1 then
                        minetest.sound_play('x_farming_bee', {
                            pos = pos_bee,
                        })
                    end
                end
            end
        end
    end,
})

local hive_after_dig_node = function(pos, oldnode, oldmetadata, digger)
    local data = minetest.deserialize(oldmetadata.fields.x_farming)
    local positions = minetest.find_nodes_in_area_under_air(
        vector.add(pos, x_farming.beehive_distance),
        vector.subtract(pos, x_farming.beehive_distance),
        { 'group:flower', 'group:flora', 'group:bees_pollinate_crop' }
    )

    if positions and #positions > 0 and data.occupancy and data.occupancy > 0 then
        for i = 1, data.occupancy do
            local p = positions[i]

            if p then
                local pos_bee = vector.new(p.x, p.y + 1, p.z)
                minetest.swap_node(pos_bee, { name = 'x_farming:bee', param2 = rand:next(0, 3) })
                tick_bee(pos_bee)
                bee_particles(pos_bee)

                if i == 1 then
                    minetest.sound_play('x_farming_bee', {
                        pos = pos,
                    })
                end
            end
        end
    end
end

-- Hive saturrated
minetest.register_node('x_farming:bee_hive_saturated', {
    description = S('Bee Hive'),
    short_description = S('Bee Hive'),
    tiles = {
        'x_farming_bee_hive_top.png',
        'x_farming_bee_hive_bottom.png',
        'x_farming_bee_hive_side.png^x_farming_bee_hive_saturated_overlay_1.png',
        'x_farming_bee_hive_side.png^x_farming_bee_hive_saturated_overlay_1.png',
        'x_farming_bee_hive_side.png^x_farming_bee_hive_saturated_overlay_1.png',
        'x_farming_bee_hive_front.png^x_farming_bee_hive_saturated_overlay_1.png',
    },
    paramtype2 = 'facedir',
    drop = 'x_farming:bee_hive',
    groups = {
        -- MTG
        choppy = 2,
        oddly_breakable_by_hand = 1,
        bee_hive = 1,
        no_silktouch = 1,
        not_in_creative_inventory = 1,
        -- MCL
        handy = 1,
        axey = 1,
        building_block = 1,
        material_wood = 1,
        fire_encouragement = 5,
        fire_flammability = 5,
        -- ALL
        tree = 1,
        flammable = 2,
    },
    _mcl_blast_resistance = 2,
    _mcl_hardness = 2,
    sounds = x_farming.node_sound_wood_defaults(),
    on_rightclick = hive_on_rightclick,
    after_dig_node = hive_after_dig_node,
    on_timer = hive_on_timer,
})

-- Hive saturrated 1
minetest.register_node('x_farming:bee_hive_saturated_1', {
    description = S('Bee Hive'),
    short_description = S('Bee Hive'),
    tiles = {
        'x_farming_bee_hive_top.png',
        'x_farming_bee_hive_bottom.png',
        'x_farming_bee_hive_side.png^x_farming_bee_hive_saturated_overlay_2.png',
        'x_farming_bee_hive_side.png^x_farming_bee_hive_saturated_overlay_2.png',
        'x_farming_bee_hive_side.png^x_farming_bee_hive_saturated_overlay_2.png',
        'x_farming_bee_hive_front.png^x_farming_bee_hive_saturated_overlay_2.png',
    },
    paramtype2 = 'facedir',
    drop = 'x_farming:bee_hive',
    groups = {
        -- MTG
        choppy = 2,
        oddly_breakable_by_hand = 1,
        bee_hive = 1,
        no_silktouch = 1,
        not_in_creative_inventory = 1,
        -- MCL
        handy = 1,
        axey = 1,
        building_block = 1,
        material_wood = 1,
        fire_encouragement = 5,
        fire_flammability = 5,
        -- ALL
        tree = 1,
        flammable = 2,
    },
    _mcl_blast_resistance = 2,
    _mcl_hardness = 2,
    sounds = x_farming.node_sound_wood_defaults(),
    on_rightclick = hive_on_rightclick,
    after_dig_node = hive_after_dig_node,
    on_timer = hive_on_timer,
})

-- Hive saturrated 2
minetest.register_node('x_farming:bee_hive_saturated_2', {
    description = S('Bee Hive'),
    short_description = S('Bee Hive'),
    tiles = {
        'x_farming_bee_hive_top.png',
        'x_farming_bee_hive_bottom.png',
        'x_farming_bee_hive_side.png^x_farming_bee_hive_saturated_overlay_3.png',
        'x_farming_bee_hive_side.png^x_farming_bee_hive_saturated_overlay_3.png',
        'x_farming_bee_hive_side.png^x_farming_bee_hive_saturated_overlay_3.png',
        'x_farming_bee_hive_front.png^x_farming_bee_hive_saturated_overlay_3.png',
    },
    paramtype2 = 'facedir',
    drop = 'x_farming:bee_hive',
    groups = {
        -- MTG
        choppy = 2,
        oddly_breakable_by_hand = 1,
        bee_hive = 1,
        no_silktouch = 1,
        not_in_creative_inventory = 1,
        -- MCL
        handy = 1,
        axey = 1,
        building_block = 1,
        material_wood = 1,
        fire_encouragement = 5,
        fire_flammability = 5,
        -- ALL
        tree = 1,
        flammable = 2,
    },
    _mcl_blast_resistance = 2,
    _mcl_hardness = 2,
    sounds = x_farming.node_sound_wood_defaults(),
    on_rightclick = hive_on_rightclick,
    after_dig_node = hive_after_dig_node,
})

-- Bee
minetest.register_node('x_farming:bee', {
    description = S('Bee'),
    short_description = S('Bee'),
    drawtype = 'mesh',
    mesh = 'x_farming_bee.obj',
    tiles = {
        {
            name = 'x_farming_bee_mesh_animated.png',
            animation = {
                type = 'vertical_frames',
                aspect_w = 34,
                aspect_h = 30,
                length = 0.3
            },
            backface_culling = false
        },
    },
    use_texture_alpha = 'clip',
    paramtype = 'light',
    sunlight_propagates = true,
    paramtype2 = 'facedir',
    walkable = false,
    selection_box = {
        type = 'fixed',
        fixed = { -4 / 16, -4 / 16, -4 / 16, 4 / 16, 4 / 16, 4 / 16 }
    },
    groups = {
        -- MTG
        snappy = 2,
        cracky = 2,
        crumbly = 2,
        choppy = 2,
        fleshy = 10,
        oddly_breakable_by_hand = 1,
        disable_jump = 1,
        bee = 1,
        no_silktouch = 1,
        not_in_creative_inventory = 1,
        -- MCL
        handy = 1,
    },
    damage_per_second = 2,
    move_resistance = 7,
    _mcl_blast_resistance = 1,
    _mcl_hardness = 1,
    sounds = x_farming.node_sound_wood_defaults(),
    drop = {
        max_items = 1,
        items = {
            {
                --  1/20 chance
                items = { 'x_farming:honeycomb' },
                rarity = 10,
            }
        }
    },
    on_timer = function(pos, elapsed)
        -- Bee data
        local meta_bee = minetest.get_meta(pos)
        local data_bee = minetest.deserialize(meta_bee:get_string('x_farming')) or {}
        local pos_hive = get_valid_hive_position(data_bee.pos_hive and vector.from_string(data_bee.pos_hive) or nil, pos)

        if not pos_hive then
            -- Bee data not found, remove bee
            minetest.remove_node(pos)

            minetest.sound_play('x_farming_bee', {
                pos = pos,
            })

            bee_particles(pos)

            return
        end

        local meta_hive = minetest.get_meta(pos_hive)
        local data_hive = minetest.deserialize(meta_hive:get_string('x_farming'))
        local node_hive = minetest.get_node(pos_hive)

        -- Bee go home
        data_hive.occupancy = data_hive.occupancy + 1

        local flower_node = minetest.get_node(vector.new(pos.x, pos.y - 1, pos.z))

        if flower_node then
            if minetest.get_item_group(flower_node.name, 'flower') > 0 and data_hive.saturation < 16 then
                data_hive.saturation = data_hive.saturation + 1
            end

            if minetest.get_item_group(flower_node.name, 'farmable') > 0 then
                if data_hive.saturation < 16 then
                    data_hive.saturation = data_hive.saturation + 1
                end
                local crop_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
                x_farming.grow_plant(crop_pos)
                x_farming.x_bonemeal.particle_effect(crop_pos)
            end

            if data_hive.saturation >= 5 then
                hive_node_swap(pos_hive, data_hive.saturation, node_hive.param2)
            end
        end

        meta_hive:set_string('x_farming', minetest.serialize(data_hive))
        minetest.remove_node(pos)
        update_hive_infotext(pos_hive)

        minetest.sound_play('x_farming_bee', {
            pos = pos,
        })

        bee_particles(pos)

        local pos_hive_front = vector.subtract(vector.new(pos_hive.x, pos_hive.y + 0.5, pos_hive.z), minetest.facedir_to_dir(node_hive.param2))

        bee_particles(pos)
        bee_particles(pos_hive_front)

        if not minetest.get_node_timer(pos_hive):is_started() then
            tick_hive(pos_hive)
        end
    end,
    on_punch = function(pos, node, puncher, pointed_thing)
        if not puncher then
            return
        end

        -- Hurt player when punching bee
        local armor_groups = puncher:get_armor_groups()
        local damage = 2

        if armor_groups.fleshy then
            damage = math.round((2 * 100) / armor_groups.fleshy)
        end

        puncher:punch(puncher, 1, {
            full_punch_interval = 1,
            damage_groups = { fleshy = damage },
        }, nil)

        minetest.sound_play('x_farming_bee', {
            pos = pos,
        })

        bee_particles(pos)
    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local stack_name = itemstack:get_name()

        if stack_name == 'x_farming:jar_empty' then
            itemstack:take_item()
            minetest.remove_node(pos)
            hive_give_item(clicker, vector.new(pos.x, pos.y + 0.3, pos.z), ItemStack({ name = 'x_farming:jar_with_bee' }))

            minetest.sound_play('x_farming_bee', {
                pos = pos,
            })

            bee_particles(pos)
        end

        return itemstack
    end
})

-- Spawn bees on flowers
minetest.register_globalstep(function(dtime)
    local abr = minetest.get_mapgen_setting('active_block_range') or 4
    local spawn_reduction = 0.5
    local spawn_rate = 0.5
    local spawnpos, liquidflag = x_farming.get_spawn_pos_abr(dtime, 3, abr * 16, spawn_rate, spawn_reduction)
    local tod = minetest.get_timeofday()
    local is_day = false

    if tod > 0.2 and tod < 0.710 then
        is_day = true
    end

    if spawnpos and not liquidflag and is_day then
        local bees = minetest.find_node_near(spawnpos, abr * 16 * 1.1, { 'group:bee' }) or {}

        if #bees > 1 then
            return
        end

        local flower_positions = minetest.find_nodes_in_area_under_air(
            vector.add(spawnpos, x_farming.beehive_distance),
            vector.subtract(spawnpos, x_farming.beehive_distance),
            { 'group:flower', 'group:bees_pollinate_crop' }
        )

        if flower_positions and #flower_positions > 1 then
            local rand_pos = flower_positions[rand:next(1, #flower_positions)]
            local bee_pos = vector.new(rand_pos.x, rand_pos.y + 1, rand_pos.z)
            local below_pos = vector.new(rand_pos.x, rand_pos.y - 1, rand_pos.z)
            local nname_below = minetest.get_node(below_pos).name
            local light_level = minetest.get_node_light(bee_pos)

            if rand_pos.y > 0 and light_level > 10 and minetest.get_item_group(nname_below, 'soil') > 0 then
                minetest.swap_node(bee_pos, { name = 'x_farming:bee', param2 = rand:next(0, 3) })
                tick_bee(bee_pos)

                minetest.log('action', '[x_farming] Added Bee at ' .. minetest.pos_to_string(bee_pos))
            end
        end
    end
end)
