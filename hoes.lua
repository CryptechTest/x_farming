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

local hoe_wood_def = {
    description = S('Wooden Hoe'),
    inventory_image = 'x_farming_tool_woodhoe.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    max_uses = 30,
    material = 'group:wood',
    groups = { hoe = 1, flammable = 2 },
}

local hoe_stone_def = {
    description = S('Stone Hoe'),
    inventory_image = 'x_farming_tool_stonehoe.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    max_uses = 90,
    material = 'group:stone',
    groups = { hoe = 1 }
}

local hoe_steel_def = {
    description = S('Steel Hoe'),
    inventory_image = 'x_farming_tool_steelhoe.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    max_uses = 500,
    material = 'default:steel_ingot',
    groups = { hoe = 1 }
}

if minetest.get_modpath('farming') then
    minetest.override_item('farming:hoe_wood', hoe_wood_def)
    minetest.override_item('farming:hoe_stone', hoe_stone_def)
    minetest.override_item('farming:hoe_steel', hoe_steel_def)
else
    x_farming.register_hoe('x_farming:hoe_wood', hoe_wood_def)
    x_farming.register_hoe('x_farming:hoe_stone', hoe_stone_def)
    x_farming.register_hoe('x_farming:hoe_steel', hoe_steel_def)
end
