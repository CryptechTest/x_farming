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

stairs = stairs --[[@as MtgStairs]]

local S = minetest.get_translator(minetest.get_current_modname())

-- Donuts
minetest.register_node('x_farming:donut', {
    description = S('Donut') .. '\n' .. S('Compost chance') .. ': 85%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 3'),
    short_description = S('Donut'),
    drawtype = 'mesh',
    mesh = 'x_farming_donut.obj',
    tiles = { 'x_farming_donut_mesh.png' },
    inventory_image = 'x_farming_donut.png',
    wield_image = 'x_farming_donut.png',
    paramtype = 'light',
    is_ground_content = false,
    walkable = true,
    selection_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.25, 0.25, -0.35, 0.25 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.25, 0.25, -0.35, 0.25 }
    },
    groups = { dig_immediate = 3, attached_node = 1, compost = 85, hunger_amount = 3 },
    sounds = default.node_sound_leaves_defaults(),
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then 
            return itemstack
        end
        minetest.item_eat(hunger_amount)
    end,
    sunlight_propagates = true
})

minetest.register_node('x_farming:donut_chocolate', {
    description = S('Chocolate Donut') .. '\n' .. S('Compost chance') .. ': 85%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 4'),
    short_description = S('Chocolate Donut'),
    drawtype = 'mesh',
    mesh = 'x_farming_donut.obj',
    tiles = { 'x_farming_donut_chocolate_mesh.png' },
    inventory_image = 'x_farming_donut_chocolate.png',
    wield_image = 'x_farming_donut_chocolate.png',
    paramtype = 'light',
    is_ground_content = false,
    walkable = true,
    selection_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.25, 0.25, -0.35, 0.25 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.25, 0.25, -0.35, 0.25 }
    },
    groups = { dig_immediate = 3, attached_node = 1, compost = 85, hunger_amount = 4 },
    sounds = default.node_sound_leaves_defaults(),
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then 
            return itemstack
        end
        minetest.item_eat(hunger_amount)
    end,
    sunlight_propagates = true
})

-- Fries
minetest.register_node('x_farming:fries', {
    description = S('Fries') .. '\n' .. S('Compost chance') .. ': 85%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 6'),
    short_description = S('Fries'),
    drawtype = 'mesh',
    mesh = 'x_farming_fries.obj',
    tiles = { 'x_farming_fries_mesh.png' },
    inventory_image = 'x_farming_fries.png',
    wield_image = 'x_farming_fries.png',
    paramtype = 'light',
    paramtype2 = 'facedir',
    is_ground_content = false,
    walkable = true,
    selection_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.1, 0.25, 0.05, 0.1 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.1, 0.25, -0.2, 0.1 }
    },
    groups = { dig_immediate = 3, attached_node = 1, compost = 85, hunger_amount = 6 },
    sounds = default.node_sound_leaves_defaults(),
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then 
            return itemstack
        end
        minetest.item_eat(hunger_amount)
    end,
    sunlight_propagates = true
})

-- Pumpkin pie
minetest.register_node('x_farming:pumpkin_pie', {
    description = S('Pumpkin Pie') .. '\n' .. S('Compost chance') .. ': 100%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 6'),
    short_description = S('Pumpkin Pie'),
    drawtype = 'mesh',
    mesh = 'x_farming_pumpkin_pie.obj',
    tiles = { 'x_farming_pumpkin_pie_mesh.png' },
    inventory_image = 'x_farming_pumpkin_pie.png',
    wield_image = 'x_farming_pumpkin_pie.png',
    paramtype = 'light',
    paramtype2 = 'facedir',
    is_ground_content = false,
    walkable = true,
    selection_box = {
        type = 'fixed',
        fixed = { -0.3, -0.5, -0.3, 0.3, -0.2, 0.3 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.3, -0.5, -0.3, 0.3, -0.3, 0.3 }
    },
    groups = { dig_immediate = 3, attached_node = 1, compost = 100, hunger_amount = 6 },
    sounds = default.node_sound_leaves_defaults(),
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then 
            return itemstack
        end
        minetest.item_eat(hunger_amount)
    end,
    sunlight_propagates = true
})

-- Beetroot soup
minetest.register_node('x_farming:beetroot_soup', {
    description = S('Beetroot Soup') .. '\n' .. S('Compost chance') .. ': 100%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 6'),
    short_description = S('Beetroot Soup'),
    drawtype = 'mesh',
    mesh = 'x_farming_beetroot_soup.obj',
    tiles = { 'x_farming_beetroot_soup_mesh.png' },
    inventory_image = 'x_farming_beetroot_soup.png',
    wield_image = 'x_farming_beetroot_soup.png',
    paramtype = 'light',
    paramtype2 = 'facedir',
    is_ground_content = false,
    walkable = true,
    selection_box = {
        type = 'fixed',
        fixed = { -0.5, -0.5, -0.5, 0.5, 0.1, 0.5 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.5, -0.5, -0.5, 0.5, -0.1, 0.5 }
    },
    groups = { vessel = 1, dig_immediate = 3, attached_node = 1, compost = 100, hunger_amount = 6 },
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then 
            return itemstack
        end
        minetest.item_eat(hunger_amount, 'x_farming:bowl')
    end,
    sounds = default.node_sound_wood_defaults(),
    sunlight_propagates = true
})

-- Fish Stew
minetest.register_node('x_farming:fish_stew', {
    description = S('Fish Stew') .. '\n' .. S('Compost chance') .. ': 100%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 8'),
    short_description = S('Fish Stew'),
    drawtype = 'mesh',
    mesh = 'x_farming_fish_stew.obj',
    tiles = { 'x_farming_fish_stew_mesh.png' },
    inventory_image = 'x_farming_fish_stew.png',
    wield_image = 'x_farming_fish_stew.png',
    paramtype = 'light',
    paramtype2 = 'facedir',
    is_ground_content = false,
    walkable = true,
    selection_box = {
        type = 'fixed',
        fixed = { -0.5, -0.5, -0.5, 0.5, 0.1, 0.5 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.5, -0.5, -0.5, 0.5, -0.1, 0.5 }
    },
    groups = { vessel = 1, dig_immediate = 3, attached_node = 1, compost = 100, hunger_amount = 8 },
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then 
            return itemstack
        end
        minetest.item_eat(hunger_amount, 'x_farming:bowl')
    end,
    sounds = default.node_sound_wood_defaults(),
    sunlight_propagates = true
})

-- Cactus brick
minetest.register_node('x_farming:cactus_brick', {
    description = S('Cactus Brick'),
    short_description = S('Cactus Brick'),
    paramtype2 = 'facedir',
    place_param2 = 0,
    tiles = {
        'x_farming_cactus_brick.png^[transformFX',
        'x_farming_cactus_brick.png',
    },
    is_ground_content = false,
    groups = { cracky = 3 },
    sounds = default.node_sound_stone_defaults()
})

if minetest.global_exists('stairs') and minetest.get_modpath('stairs') then
    stairs.register_stair_and_slab(
        'cactus_brick',
        'x_farming:cactus_brick',
        { cracky = 3 },
        { 'x_farming_cactus_brick.png' },
        S('Cactus Brick Stair'),
        S('Cactus Brick Slab'),
        default.node_sound_stone_defaults(),
        false
    )
end

local function tick_scarecrow(pos)
    -- minetest.get_node_timer(pos):start(math.random(1, 2))
    minetest.get_node_timer(pos):start(math.random(83, 143))
end

-- Scarecrow
minetest.register_node('x_farming:scarecrow', {
    description = S('Scarecrow'),
    short_description = S('Scarecrow'),
    drawtype = 'mesh',
    mesh = 'x_farming_scarecrow.obj',
    tiles = { 'x_farming_scarecrow_1.png' },
    inventory_image = 'x_farming_scarecrow_1_item.png',
    wield_image = 'x_farming_scarecrow_1_item.png',
    paramtype = 'light',
    sunlight_propagates = true,
    paramtype2 = 'facedir',
    is_ground_content = false,
    walkable = true,
    selection_box = {
        type = 'fixed',
        fixed = { -0.4, -0.5, -0.4, 0.4, 1.5, 0.4 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.4, -0.5, -0.4, 0.4, 1.5, 0.4 }
    },
    groups = { choppy = 1, oddly_breakable_by_hand = 1, flammable = 2 },
    sounds = default.node_sound_wood_defaults(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string('x_farming_scarecrow_state', 'inactive')
        meta:set_string('infotext', 'Scarecrow - Activate with bonemeal.')
        meta:set_string('owner', '')
    end,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        if not placer then
            return
        end

        local meta = minetest.get_meta(pos)

        meta:set_string('owner', placer:get_player_name() or '')
        meta:set_string('infotext', S('Scarecrow (owned by @1) - Activate with bonemeal.', meta:get_string('owner')))
    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local player_name = clicker:get_player_name()

        if minetest.is_protected(pos, player_name)
            and not minetest.check_player_privs(player_name, 'protection_bypass')
        then
            minetest.record_protection_violation(pos, player_name)
            return itemstack
        end

        if itemstack:get_name() ~= 'x_farming:bonemeal' then
            return itemstack
        end

        local meta = minetest.get_meta(pos)
        local state = meta:get_string('x_farming_scarecrow_state')

        if state == 'inactive' then
            meta:set_string('x_farming_scarecrow_state', 'active')
            meta:set_string('infotext', S('Scarecrow (owned by @1) - Active', meta:get_string('owner')))
            minetest.swap_node(pos, { name = 'x_farming:scarecrow_2', param2 = node.param2 })
            meta:set_int('x_farming_scarecrow_fails', 0)
            tick_scarecrow(pos)
            itemstack:take_item()
        end

        return itemstack
    end,
})

minetest.register_node('x_farming:scarecrow_2', {
    description = S('Scarecrow 2'),
    short_description = S('Scarecrow 2'),
    drawtype = 'mesh',
    mesh = 'x_farming_scarecrow_2.obj',
    tiles = { 'x_farming_scarecrow_2.png' },
    inventory_image = 'x_farming_scarecrow_1_item.png',
    wield_image = 'x_farming_scarecrow_1_item.png',
    paramtype = 'light',
    sunlight_propagates = true,
    paramtype2 = 'facedir',
    is_ground_content = false,
    walkable = true,
    drop = 'x_farming:scarecrow',
    selection_box = {
        type = 'fixed',
        fixed = { -0.4, -0.5, -0.4, 0.4, 1.5, 0.4 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.4, -0.5, -0.4, 0.4, 1.5, 0.4 }
    },
    groups = { choppy = 1, oddly_breakable_by_hand = 1, flammable = 2 },
    sounds = default.node_sound_wood_defaults(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string('x_farming_scarecrow_state', 'active')
    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local player_name = clicker:get_player_name()

        if minetest.is_protected(pos, player_name)
            and not minetest.check_player_privs(player_name, 'protection_bypass')
        then
            minetest.record_protection_violation(pos, player_name)
            return itemstack
        end

        local meta = minetest.get_meta(pos)
        local state = meta:get_string('x_farming_scarecrow_state')

        if state == 'active' then
            meta:set_string('x_farming_scarecrow_state', 'inactive')
            meta:set_string('infotext', S('Scarecrow (owned by @1) - Activate with bonemeal.', meta:get_string('owner')))
            minetest.swap_node(pos, { name = 'x_farming:scarecrow', param2 = node.param2 })
        end

        return itemstack
    end,
    on_timer = function(pos, elapsed)
        local meta = minetest.get_meta(pos)
        local state = meta:get_string('x_farming_scarecrow_state')
        local fails = meta:get_int('x_farming_scarecrow_fails')
        local player_name = meta:get_string('owner')
        local player = minetest.get_player_by_name(player_name)
        local node = minetest.get_node(pos)

        if not player then
            return true
        end

        if minetest.is_protected(pos, player_name)
            and not minetest.check_player_privs(player_name, 'protection_bypass')
        then
            return true
        end

        if state ~= 'active' then
            return false
        end

        -- bonemeal it
        local positions_raw = minetest.find_nodes_in_area(
            vector.subtract(vector.new(pos), 5),
            vector.add(vector.new(pos), 5),
            {
                'group:sand',
                'group:soil',
                'group:seed',
                'group:plant'
            }
        )

        local positions = {}

        for _, p in ipairs(positions_raw) do
            local n = minetest.get_node(p)
            if minetest.get_item_group(n.name, 'field') == 0 then
                local n_above = minetest.get_node(vector.new(p.x, p.y + 1, p.z))

                if minetest.get_item_group(n.name, 'seed') > 0 or minetest.get_item_group(n.name, 'plant') > 0 then
                    local ndef = minetest.registered_nodes[n.name]

                    if ndef.next_plant
                        and ndef.next_plant ~= 'x_farming:pumpkin_fruit'
                        and ndef.next_plant ~= 'x_farming:melon_fruit'
                    then
                        table.insert(positions, p)
                    end
                elseif n_above.name == 'air' then
                    table.insert(positions, p)
                end
            end
        end

        if #positions == 0 then
            meta:set_string('x_farming_scarecrow_state', 'inactive')
            meta:set_string('infotext', S('Scarecrow (owned by @1) - Activate with bonemeal.', meta:get_string('owner')))
            minetest.swap_node(pos, { name = 'x_farming:scarecrow', param2 = node.param2 })

            return false
        end

        local pos_rand = positions[math.random(1, #positions)]

        local pointed_thing = {
            type = 'node',
            under = pos_rand,
            above = vector.new(pos_rand.x, pos_rand.y + 1, pos_rand.z),
        }

        local result = x_farming.x_bonemeal:on_use(ItemStack({ name = 'x_farming:bonemeal' }), player, pointed_thing)

        if not result.success then
            fails = fails + 1
            meta:set_int('x_farming_scarecrow_fails', fails)
        end

        if fails < 7 then
            tick_scarecrow(pos)
        else
            meta:set_string('x_farming_scarecrow_state', 'inactive')
            meta:set_string('infotext', S('Scarecrow (owned by @1) - Activate with bonemeal.', meta:get_string('owner')))
            minetest.swap_node(pos, { name = 'x_farming:scarecrow', param2 = node.param2 })

            return false
        end
    end,
})
