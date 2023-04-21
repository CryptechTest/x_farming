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

-- COFFEE
farming.register_plant('x_farming:coffee', {
    description = S('Coffee Seed') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Coffee Seed'),
    paramtype2 = 'meshoptions',
    inventory_image = 'x_farming_coffee_seed.png',
    steps = 5,
    minlight = 13,
    maxlight = default.LIGHT_MAX,
    fertility = { 'grassland' },
    groups = { flammable = 4 },
    place_param2 = 0,
})

-- needed
minetest.override_item('x_farming:coffee', {
    description = S('Coffee bean') .. '\n' .. S('Compost chance') .. ': 50%',
    short_description = S('Coffee bean'),
    groups = { compost = 50 }
})

-- hot cup of coffee
local coffee_cup_hot_desc = S('Hot Cup of Coffee') .. '\n'
    .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 6')

if x_farming.hbhunger ~= nil then
    coffee_cup_hot_desc = coffee_cup_hot_desc .. '\n' .. minetest.colorize(x_farming.colors.red, S('Heal') .. ': 4')
end

minetest.register_node('x_farming:coffee_cup_hot', {
    description = coffee_cup_hot_desc,
    short_description = coffee_cup_hot_desc,
    drawtype = 'mesh',
    mesh = 'x_farming_coffee_cup_hot.obj',
    tiles = { 'x_farming_coffee_cup_hot_mesh.png' },
    inventory_image = 'x_farming_coffee_cup_hot.png',
    wield_image = 'x_farming_coffee_cup_hot.png',
    paramtype = 'light',
    paramtype2 = 'facedir',
    is_ground_content = false,
    walkable = true,
    selection_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.4, 0.25, 0.5, 0.25 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.4, 0.25, 0, 0.25 }
    },
    groups = { vessel = 1, dig_immediate = 3, attached_node = 1, hunger_amount = 6 },
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then 
            return itemstack
        end
        minetest.item_eat(hunger_amount)
    end,
    sounds = default.node_sound_glass_defaults(),
    sunlight_propagates = true
})

minetest.register_decoration({
    name = 'x_farming:coffee_5',
    deco_type = 'simple',
    place_on = { 'default:dry_dirt_with_dry_grass' },
    sidelen = 16,
    noise_params = {
        offset = -0.1,
        scale = 0.1,
        spread = { x = 50, y = 50, z = 50 },
        seed = 4242,
        octaves = 3,
        persist = 0.7
    },
    biomes = { 'savanna' },
    y_max = 31000,
    y_min = 1,
    decoration = 'x_farming:coffee_5',
    param2 = 3,
})

---crate
x_farming.register_crate('crate_coffee_3', {
    description = S('Coffee Crate'),
    short_description = S('Coffee Crate'),
    tiles = { 'x_farming_crate_coffee_3.png' },
    _custom = {
        crate_item = 'x_farming:coffee'
    }
})
