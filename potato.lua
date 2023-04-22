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
local minlight = 13
local maxlight = default.LIGHT_MAX

-- POTATO
farming.register_plant('x_farming:potato', {
    description = S('Planting Potato') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Planting Potato'),
    paramtype2 = 'meshoptions',
    inventory_image = 'x_farming_potato_seed.png',
    steps = 8,
    minlight = minlight,
    maxlight = maxlight,
    fertility = { 'grassland' },
    groups = { flammable = 4, hunger_amount = 2 },
    place_param2 = 3,
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then
            return itemstack
        end
        return minetest.item_eat(hunger_amount)(itemstack, user, pointed_thing)
    end
})

-- needed
minetest.override_item('x_farming:potato', {
    description = S('Potato') .. '\n' .. S('Compost chance') .. ': 65%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 2'),
    short_description = S('Potato'),
    groups = { compost = 65, hunger_amount = 2 },
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then
            return itemstack
        end
        return minetest.item_eat(hunger_amount)(itemstack, user, pointed_thing)
    end,
})

-- add poisonous potato to drops
minetest.override_item('x_farming:potato_8', {
    drop = {
        items = {
            { items = { 'x_farming:potato' },          rarity = 1 },
            { items = { 'x_farming:potato' },          rarity = 2 },
            { items = { 'x_farming:poisonouspotato' }, rarity = 5 },
            { items = { 'x_farming:seed_potato' },     rarity = 1 },
            { items = { 'x_farming:seed_potato' },     rarity = 2 },
        }
    }
})

minetest.register_decoration({
    name = 'x_farming:potato_8',
    deco_type = 'simple',
    place_on = { 'default:silver_sand' },
    sidelen = 16,
    noise_params = {
        offset = -0.1,
        scale = 0.1,
        spread = { x = 50, y = 50, z = 50 },
        seed = 4242,
        octaves = 3,
        persist = 0.7
    },
    biomes = { 'cold_desert' },
    y_max = 31000,
    y_min = 1,
    decoration = 'x_farming:potato_8',
    param2 = 3,
})

---crate
x_farming.register_crate('crate_potato_3', {
    description = S('Potato Crate'),
    short_description = S('Potato Crate'),
    tiles = { 'x_farming_crate_potato_3.png' },
    _custom = {
        crate_item = 'x_farming:potato'
    }
})
