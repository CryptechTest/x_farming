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

-- MELON
farming.register_plant('x_farming:melon', {
    description = S('Melon Seed') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Melon Seed'),
    inventory_image = 'x_farming_melon_seed.png',
    steps = 8,
    minlight = 13,
    maxlight = default.LIGHT_MAX,
    fertility = { 'grassland' },
    groups = { flammable = 4 },
    place_param2 = 3,
})

-- needed
minetest.override_item('x_farming:melon', {
    description = S('Melon') .. '\n' .. S('Compost chance') .. ': 50%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 2'),
    groups = { compost = 50, hunger_amount = 2 },
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then 
            return itemstack
        end
        minetest.item_eat(hunger_amount)
    end,
    wield_image = 'x_farming_melon.png^[transformR90',
})

-- MELON FRUIT - HARVEST
minetest.register_node('x_farming:melon_fruit', {
    description = S('Melon Fruit'),
    tiles = {
        'x_farming_melon_fruit_top.png',
        'x_farming_melon_fruit_top.png',
        'x_farming_melon_fruit_side.png',
        'x_farming_melon_fruit_side.png',
        'x_farming_melon_fruit_side.png',
        'x_farming_melon_fruit_side.png'
    },
    sounds = default.node_sound_wood_defaults(),
    is_ground_content = false,
    groups = { snappy = 3, flammable = 4, fall_damage_add_percent = -30, not_in_creative_inventory = 1 },
    drop = {
        max_items = 7, -- Maximum number of items to drop.
        items = { -- Choose max_items randomly from this list.
            {
                items = { 'x_farming:melon' }, -- Items to drop.
                rarity = 1, -- Probability of dropping is 1 / rarity.
            },
            {
                items = { 'x_farming:melon' }, -- Items to drop.
                rarity = 2, -- Probability of dropping is 1 / rarity.
            },
            {
                items = { 'x_farming:melon' }, -- Items to drop.
                rarity = 2, -- Probability of dropping is 1 / rarity.
            },
            {
                items = { 'x_farming:melon' }, -- Items to drop.
                rarity = 2, -- Probability of dropping is 1 / rarity.
            },
            {
                items = { 'x_farming:melon' }, -- Items to drop.
                rarity = 3, -- Probability of dropping is 1 / rarity.
            },
            {
                items = { 'x_farming:melon' }, -- Items to drop.
                rarity = 3, -- Probability of dropping is 1 / rarity.
            },
            {
                items = { 'x_farming:melon' }, -- Items to drop.
                rarity = 3, -- Probability of dropping is 1 / rarity.
            },
        },
    },
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local parent = oldmetadata.fields.parent
        local parent_pos_from_child = minetest.string_to_pos(parent)
        local parent_node = nil

        -- make sure we have position
        if parent_pos_from_child
            and parent_pos_from_child ~= nil then

            parent_node = minetest.get_node(parent_pos_from_child)
        end

        -- tick parent if parent stem still exists
        if parent_node
            and parent_node ~= nil
            and parent_node.name == 'x_farming:melon_8' then

            x_farming.tick(parent_pos_from_child)
        end
    end
})

-- MELON BLOCK - HARVEST from crops
minetest.register_node('x_farming:melon_block', {
    description = S('Melon Block') .. '\n' .. S('Compost chance') .. ': 65%',
    short_description = S('Melon Block'),
    tiles = {
        'x_farming_melon_fruit_top.png',
        'x_farming_melon_fruit_top.png',
        'x_farming_melon_fruit_side.png',
        'x_farming_melon_fruit_side.png',
        'x_farming_melon_fruit_side.png',
        'x_farming_melon_fruit_side.png'
    },
    sounds = default.node_sound_wood_defaults(),
    is_ground_content = false,
    groups = { snappy = 3, flammable = 4, fall_damage_add_percent = -30, compost = 65 }
})

-- take over the growth from minetest_game farming from here
minetest.override_item('x_farming:melon_8', {
    next_plant = 'x_farming:melon_fruit',
    on_timer = x_farming.grow_block
})

-- replacement LBM for pre-nodetimer plants
minetest.register_lbm({
    name = 'x_farming:start_nodetimer_melon',
    nodenames = { 'x_farming:melon_8' },
    action = function(pos, node)
        x_farming.tick_short(pos)
    end,
})

minetest.register_decoration({
    name = 'x_farming:melon_8',
    deco_type = 'simple',
    place_on = { 'default:dirt_with_grass' },
    sidelen = 16,
    noise_params = {
        offset = -0.1,
        scale = 0.1,
        spread = { x = 50, y = 50, z = 50 },
        seed = 4242,
        octaves = 3,
        persist = 0.7
    },
    biomes = { 'grassland' },
    y_max = 31000,
    y_min = 1,
    decoration = 'x_farming:melon_8',
})

---crate
x_farming.register_crate('crate_melon_3', {
    description = S('Melon Crate'),
    short_description = S('Melon Crate'),
    tiles = { 'x_farming_crate_melon_3.png' },
    _custom = {
        crate_item = 'x_farming:melon'
    }
})
