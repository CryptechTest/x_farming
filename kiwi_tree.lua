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

-- Required wrapper to allow customization of default.after_place_leaves
local function after_place_leaves(...)
    return default.after_place_leaves(...)
end

-- decoration
minetest.register_decoration({
    name = 'x_farming:kiwi_tree',
    deco_type = 'schematic',
    place_on = { 'default:dry_dirt_with_dry_grass' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.001,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'savanna' },
    y_max = 31000,
    y_min = 1,
    schematic = minetest.get_modpath('x_farming') .. '/schematics/x_farming_kiwi_tree.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

-- trunk
minetest.register_node('x_farming:kiwi_tree', {
    description = S('Kiwi Tree'),
    short_description = S('Kiwi Tree'),
    tiles = { 'x_farming_kiwi_tree_top.png', 'x_farming_kiwi_tree_top.png', 'x_farming_kiwi_tree.png' },
    paramtype2 = 'facedir',
    is_ground_content = false,
    groups = { tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2 },
    sounds = default.node_sound_wood_defaults(),

    on_place = minetest.rotate_node
})

-- leaves
minetest.register_node('x_farming:kiwi_leaves', {
    description = S('Kiwi Tree Leaves') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Kiwi Tree Leaves'),
    drawtype = 'allfaces_optional',
    waving = 1,
    tiles = { 'x_farming_kiwi_leaves.png' },
    special_tiles = { 'x_farming_kiwi_leaves.png' },
    paramtype = 'light',
    is_ground_content = false,
    groups = { snappy = 3, leafdecay = 3, flammable = 2, leaves = 1 },
    drop = {
        max_items = 1,
        items = {
            {
                -- player will get sapling with 1/20 chance
                items = { 'x_farming:kiwi_sapling' },
                rarity = 20,
            },
            {
                -- player will get leaves only if he get no saplings,
                -- this is because max_items is 1
                items = { 'x_farming:kiwi_leaves' },
            }
        }
    },
    sounds = default.node_sound_leaves_defaults(),

    after_place_node = after_place_leaves,
})

-- sapling
minetest.register_node('x_farming:kiwi_sapling', {
    description = S('Kiwi Tree Sapling') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Kiwi Tree Sapling'),
    drawtype = 'plantlike',
    tiles = { 'x_farming_kiwi_sapling.png' },
    inventory_image = 'x_farming_kiwi_sapling.png',
    wield_image = 'x_farming_kiwi_sapling.png',
    paramtype = 'light',
    sunlight_propagates = true,
    walkable = false,
    on_timer = x_farming.grow_sapling,
    selection_box = {
        type = 'fixed',
        fixed = { -4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16 }
    },
    groups = { snappy = 2, dig_immediate = 3, flammable = 2,
        attached_node = 1, sapling = 1 },
    sounds = default.node_sound_leaves_defaults(),

    on_construct = function(pos)
        minetest.get_node_timer(pos):start(math.random(300, 1500))
    end,

    on_place = function(itemstack, placer, pointed_thing)
        itemstack = default.sapling_on_place(itemstack, placer, pointed_thing,
            'x_farming:kiwi_sapling',
            -- minp, maxp to be checked, relative to sapling pos
            -- minp_relative.y = 1 because sapling pos has been checked
            { x = -2, y = 1, z = -2 },
            { x = 2, y = 4, z = 2 },
            -- maximum interval of interior volume check
            4)

        return itemstack
    end,
})

-- fruit
minetest.register_node('x_farming:kiwi', {
    description = S('Kiwi'),
    short_description = S('Kiwi'),
    drawtype = 'plantlike',
    visual_scale = 0.5,
    tiles = { 'x_farming_kiwi.png' },
    inventory_image = 'x_farming_kiwi.png',
    paramtype = 'light',
    sunlight_propagates = true,
    walkable = false,
    is_ground_content = false,
    drop = {
        max_items = 1, -- Maximum number of items to drop.
        items = { -- Choose max_items randomly from this list.
            {
                items = { 'x_farming:kiwi_fruit' }, -- Items to drop.
                rarity = 1, -- Probability of dropping is 1 / rarity.
            }
        },
    },
    selection_box = {
        type = 'fixed',
        fixed = { -3 / 16, -7 / 16, -3 / 16, 3 / 16, 4 / 16, 3 / 16 }
    },
    groups = { fleshy = 3, dig_immediate = 3, flammable = 2,
        leafdecay = 3, leafdecay_drop = 1, food_apple = 1, not_in_creative_inventory = 1 },
    sounds = default.node_sound_leaves_defaults(),

    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if oldnode.param2 == 0 then
            minetest.set_node(pos, { name = 'x_farming:kiwi_mark' })
            minetest.get_node_timer(pos):start(math.random(300, 1500))
        end
    end,
})

minetest.register_node('x_farming:kiwi_mark', {
    description = S('Kiwi Marker'),
    short_description = S('Kiwi Marker'),
    inventory_image = 'x_farming:kiwi_fruit.png^default_invisible_node_overlay.png',
    wield_image = 'x_farming:kiwi_fruit.png^default_invisible_node_overlay.png',
    drawtype = 'airlike',
    paramtype = 'light',
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    drop = '',
    groups = { not_in_creative_inventory = 1 },
    on_timer = function(pos, elapsed)
        if not minetest.find_node_near(pos, 1, 'x_farming:kiwi_leaves') then
            minetest.remove_node(pos)
        elseif minetest.get_node_light(pos) < 11 then
            minetest.get_node_timer(pos):start(200)
        else
            minetest.set_node(pos, { name = 'x_farming:kiwi' })
        end
    end
})

minetest.register_node('x_farming:kiwi_fruit', {
    description = S('Kiwi') .. '\n' .. S('Compost chance') .. ': 65%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 2'),
    short_description = S('Kiwi'),
    drawtype = 'mesh',
    mesh = 'x_farming_kiwi_fruit.obj',
    tiles = { 'x_farming_kiwi_fruit_mesh.png' },
    inventory_image = 'x_farming_kiwi_fruit.png',
    wield_image = 'x_farming_kiwi_fruit.png',
    paramtype = 'light',
    is_ground_content = false,
    walkable = true,
    selection_box = {
        type = 'fixed',
        fixed = { -0.2, -0.5, -0.2, 0.2, -0.2, 0.2 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.1, -0.5, -0.1, 0.1, -0.3, 0.1 }
    },
    groups = { dig_immediate = 3, attached_node = 1, compost = 65, hunger_amount = 2 },
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

-- leafdecay

default.register_leafdecay({
    trunks = { 'x_farming:kiwi_tree' },
    leaves = { 'x_farming:kiwi', 'x_farming:kiwi_leaves' },
    radius = 3,
})

-- planks
minetest.register_node('x_farming:kiwi_wood', {
    description = S('Kiwi Wood Planks'),
    short_description = S('Kiwi Wood Planks'),
    paramtype2 = 'facedir',
    place_param2 = 0,
    tiles = { 'x_farming_kiwi_wood.png' },
    is_ground_content = false,
    groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1 },
    sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
    output = 'x_farming:kiwi_wood 4',
    recipe = {
        { 'x_farming:kiwi_tree' },
    }
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'x_farming:kiwi_wood',
    burntime = 8,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'x_farming:kiwi_tree',
    burntime = 22,
})

if minetest.global_exists('stairs') and minetest.get_modpath('stairs') then
    stairs.register_stair_and_slab(
        'kiwi_wood',
        'x_farming:kiwi_wood',
        { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 },
        { 'x_farming_kiwi_wood.png' },
        S('Kiwi Wooden Stair'),
        S('Kiwi Wooden Slab'),
        default.node_sound_wood_defaults(),
        false
    )
end

---crate
x_farming.register_crate('crate_kiwi_fruit_3', {
    description = S('Kiwi Fruit Crate'),
    short_description = S('Kiwi Fruit Crate'),
    tiles = { 'x_farming_crate_kiwi_fruit_3.png' },
    _custom = {
        crate_item = 'x_farming:kiwi_fruit'
    }
})
