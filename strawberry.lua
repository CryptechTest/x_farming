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

-- STRAWBERRY
farming.register_plant('x_farming:strawberry', {
    description = S('Strawberry Seed') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Strawberry Seed'),
    paramtype2 = 'meshoptions',
    inventory_image = 'x_farming_strawberry_seed.png',
    steps = 4,
    minlight = 13,
    maxlight = default.LIGHT_MAX,
    fertility = { 'grassland' },
    groups = { flammable = 4 },
    place_param2 = 0
})

-- needed
minetest.override_item('x_farming:strawberry', {
    description = S('Strawberry') .. '\n' .. S('Compost chance') .. ': 30%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 2'),
    groups = { compost = 30, hunger_amount = 2 },
    short_description = S('Strawberry'),
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then 
            return itemstack
        end
        minetest.item_eat(hunger_amount)
    end
})

-- decorations
for length = 1, 4 do
    minetest.register_decoration({
        name = 'x_farming:strawberry_' .. length,
        deco_type = 'simple',
        place_on = { 'default:dirt_with_coniferous_litter' },
        sidelen = 16,
        noise_params = {
            offset = 0,
            scale = 0.01,
            spread = { x = 100, y = 100, z = 100 },
            seed = 2,
            octaves = 3,
            persist = 0.7
        },
        biomes = { 'coniferous_forest' },
        y_max = 30,
        y_min = 1,
        decoration = 'x_farming:strawberry_' .. length,
    })
end

---crate
x_farming.register_crate('crate_strawberry_3', {
    description = S('Strawberry Crate'),
    short_description = S('Strawberry Crate'),
    tiles = { 'x_farming_crate_strawberry_3.png' },
    _custom = {
        crate_item = 'x_farming:strawberry'
    }
})
