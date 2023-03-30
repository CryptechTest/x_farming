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

-- STEVIA
farming.register_plant('x_farming:stevia', {
    description = S('Stevia Seed') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Stevia Seed'),
    paramtype2 = 'meshoptions',
    inventory_image = 'x_farming_stevia_seed.png',
    steps = 8,
    minlight = 13,
    maxlight = default.LIGHT_MAX,
    fertility = { 'grassland' },
    groups = { flammable = 4 },
    place_param2 = 4,
})

-- needed
minetest.override_item('x_farming:stevia', {
    description = S('Stevia') .. '\n' .. S('Compost chance') .. ': 65%',
    short_description = S('Stevia'),
    groups = { compost = 65 }
})

minetest.register_craftitem('x_farming:sugar_substitute', {
    description = S('Sugar Substitute'),
    short_description = S('Sugar Substitute'),
    inventory_image = 'x_farming_sugar.png',
    groups = { flammable = 1, food_sugar = 1 },
})

minetest.register_craft({
    type = 'shapeless',
    output = 'x_farming:sugar_substitute',
    recipe = { 'x_farming:stevia', 'x_farming:stevia', 'x_farming:stevia', 'x_farming:stevia' }
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'x_farming:stevia',
    burntime = 1,
})

minetest.register_decoration({
    name = 'x_farming:stevia_8',
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
    decoration = 'x_farming:stevia_8',
    param2 = 4,
})

---crate
x_farming.register_crate('crate_stevia_3', {
    description = S('Stevia Crate'),
    short_description = S('Stevia Crate'),
    tiles = { 'x_farming_crate_stevia_3.png' },
    _custom = {
        crate_item = 'x_farming:stevia'
    }
})
