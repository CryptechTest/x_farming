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

farming = minetest.global_exists('farming') and farming --[[@as MtgFarming]]

local S = minetest.get_translator(minetest.get_current_modname())
local minlight = 13
local maxlight = default.LIGHT_MAX

---beetroot
farming.register_plant('x_farming:beetroot', {
    description = S('Beetroot Seed') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Beetroot Seed'),
    paramtype2 = 'meshoptions',
    inventory_image = 'x_farming_beetroot_seed.png',
    steps = 8,
    minlight = minlight,
    maxlight = maxlight,
    fertility = { 'grassland' },
    groups = { flammable = 4, compost = 65, hunger_amount = 3 },
    place_param2 = 3,
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then 
            return itemstack
        end
        minetest.item_eat(hunger_amount)
    end,
})

---needed
minetest.override_item('x_farming:beetroot', {
    description = S('Beetroot') .. '\n' .. S('Compost chance') .. ': 65%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 3'),
    short_description = S('Beetroot'),
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then 
            return itemstack
        end
        minetest.item_eat(hunger_amount)
    end,
})

minetest.register_decoration({
    name = 'x_farming:beetroot_8',
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
    decoration = 'x_farming:beetroot_8',
    param2 = 3,
})

---crate
x_farming.register_crate('crate_beetroot_3', {
    description = S('Beetroot Crate'),
    tiles = { 'x_farming_crate_beetroot_3.png' },
    _custom = {
        crate_item = 'x_farming:beetroot'
    }
})
