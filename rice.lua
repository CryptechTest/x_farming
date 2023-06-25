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

x_farming.register_plant('x_farming:rice', {
    description = S('Rice Seed') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Rice Seed'),
    tiles = { 'x_farming_silt_loam_soil.png' },
    inventory_image = 'x_farming_rice_seed_inv.png',
    steps = 8,
    minlight = 13,
    maxlight = 14,
    fertility = { 'grassland' },
    drawtype = 'plantlike_rooted',
    paramtype2 = 'none',
    visual_scale = 3.0,
    special_tiles = 'x_farming_rice_seed.png',
    node_dig_prediction = 'x_farming:silt_loam_soil',
    groups = { attached_node = 0 },
    node_placement_prediction = '',
    buildable_to = false,
    selection_box = {
        type = 'fixed',
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
            { -4 / 16, 0.5, -4 / 16, 4 / 16, 1.5, 4 / 16 },
        },
    },
    selection_box_1 = {
        type = 'fixed',
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
            { -4 / 16, 0.5, -4 / 16, 4 / 16, 1.5, 4 / 16 },
        },
    },
    selection_box_2 = {
        type = 'fixed',
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
            { -4 / 16, 0.5, -4 / 16, 4 / 16, 1.5, 4 / 16 },
        },
    },
    selection_box_3 = {
        type = 'fixed',
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
            { -4 / 16, 0.5, -4 / 16, 4 / 16, 2, 4 / 16 },
        },
    },
    selection_box_4 = {
        type = 'fixed',
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
            { -4 / 16, 0.5, -4 / 16, 4 / 16, 2.5, 4 / 16 },
        },
    },
    selection_box_5 = {
        type = 'fixed',
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
            { -4 / 16, 0.5, -4 / 16, 4 / 16, 2.5, 4 / 16 },
        },
    },
    selection_box_6 = {
        type = 'fixed',
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
            { -4 / 16, 0.5, -4 / 16, 4 / 16, 3, 4 / 16 },
        },
    },
    selection_box_7 = {
        type = 'fixed',
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
            { -4 / 16, 0.5, -4 / 16, 4 / 16, 3, 4 / 16 },
        },
    },
    selection_box_8 = {
        type = 'fixed',
        fixed = {
            { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
            { -4 / 16, 0.5, -4 / 16, 4 / 16, 3, 4 / 16 },
        },
    },
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= 'node' or not placer then
            return itemstack
        end

        local player_name = placer:get_player_name()
        local pos_under = pointed_thing.under
        local pos_above = pointed_thing.above
        local node_under = minetest.get_node(pos_under)
        local def_under = minetest.registered_nodes[node_under.name]

        if def_under and def_under.on_rightclick and not placer:get_player_control().sneak then
            return def_under.on_rightclick(pos_under, node_under, placer, itemstack, pointed_thing) or itemstack
        end

        local water_above = minetest.find_nodes_in_area(
            vector.new(pos_above),
            vector.new(pos_above.x, pos_above.y + 2, pos_above.z),
            { 'default:water_source' }
        )

        if node_under.name ~= 'x_farming:silt_loam_soil'
            or minetest.get_node(pos_above).name ~= 'default:water_source'
            or #water_above ~= 1
        then
            return itemstack
        end

        if minetest.is_protected(pos_under, player_name)
            or minetest.is_protected(pos_above, player_name)
        then
            minetest.record_protection_violation(pos_under, player_name)
            return itemstack
        end

        node_under.name = itemstack:get_name()
        minetest.set_node(pos_under, node_under)
        x_farming.tick(pos_under)

        if not minetest.is_creative_enabled(player_name) then
            itemstack:take_item()
        end

        return itemstack
    end,
    after_destruct = function(pos, oldnode)
        minetest.set_node(pos, { name = 'x_farming:silt_loam_soil' })
    end,
    on_timer = function(pos, elapsed)
        local node = minetest.get_node(pos)
        local name = node.name
        local def = minetest.registered_nodes[name]

        if not def.next_plant then
            -- disable timer for fully grown plant
            return
        end

        -- grow seed
        if minetest.get_item_group(node.name, 'seed') and def.fertility then
            local water_above = minetest.find_nodes_in_area(
                vector.new(pos),
                vector.new(pos.x, pos.y + 2, pos.z),
                { 'default:water_source' }
            )

            if #water_above ~= 1 then
                x_farming.tick_again(pos)
                return
            end
            -- omitted is a check for light, we assume seeds can germinate in the dark.
            local placenode = { name = def.next_plant }

            if def.place_param2 then
                placenode.param2 = def.place_param2
            end

            minetest.swap_node(pos, placenode)

            if minetest.registered_nodes[def.next_plant].next_plant then
                x_farming.tick(pos)
                return
            end

            return
        end

        -- check if emerged in water
        local water_above = minetest.find_nodes_in_area(
            vector.new(pos),
            vector.new(pos.x, pos.y + 2, pos.z),
            { 'default:water_source' }
        )

        local air_above = minetest.find_nodes_in_area(
            vector.new(pos),
            vector.new(pos.x, pos.y + 3, pos.z),
            { 'air' }
        )

        if #water_above ~= 1 or #air_above ~= 2 then
            x_farming.tick_again(pos)
            return
        end

        -- check light
        local light = minetest.get_node_light(pos)

        if not light or light < def.minlight or light > def.maxlight then
            x_farming.tick_again(pos)
            return
        end

        -- grow
        local placenode = { name = def.next_plant }

        if def.place_param2 then
            placenode.param2 = def.place_param2
        end

        minetest.swap_node(pos, placenode)

        -- new timer needed?
        if minetest.registered_nodes[def.next_plant].next_plant then
            x_farming.tick(pos)
        end
    end
})

-- Registered before the stairs so the stairs get fuel recipes.
minetest.register_craft({
    type = 'fuel',
    recipe = 'x_farming:rice_stack',
    burntime = 3,
})

if minetest.get_modpath('stairs') then
    do
        local recipe = 'x_farming:rice'
        local groups = { snappy = 3, flammable = 4 }
        local images = { 'x_farming_rice_stack_side.png' }
        local sounds = x_farming.node_sound_leaves_defaults()

        stairs.register_stair('rice_stack', recipe, groups, images, S('Rice Stack Stair'),
            sounds, true)
        stairs.register_stair_inner('rice_stack', recipe, groups, images, '',
            sounds, true, S('Inner Rice Stack Stair'))
        stairs.register_stair_outer('rice_stack', recipe, groups, images, '',
            sounds, true, S('Outer Rice Stack Stair'))
        stairs.register_slab('rice_stack', recipe, groups, images, S('Rice Stack Slab'),
            sounds, true)
    end
end

-- crate
x_farming.register_crate('crate_rice_3', {
    description = S('Rice Crate'),
    short_description = S('Rice Crate'),
    tiles = { 'x_farming_crate_rice_3.png' },
    _custom = {
        crate_item = 'x_farming:rice'
    }
})

-- bag
x_farming.register_bag('bag_rice_grains', {
    description = S('Rice Grain') .. ' Bag',
    short_description = S('Rice Grain') .. ' Bag',
    tiles = { 'x_farming_bag_rice_grains.png' },
    _custom = {
        bag_item = 'x_farming:rice_grains'
    }
})

minetest.register_on_mods_loaded(function()
    local deco_place_on = {}
    local deco_biomes = {}

    -- MTG
    if minetest.get_modpath('default') then
        table.insert(deco_place_on, 'default:dirt')
        table.insert(deco_place_on, 'default:dry_dirt')
        table.insert(deco_biomes, 'rainforest_swamp')
        table.insert(deco_biomes, 'savanna_shore')
    end

    -- MCL
    if minetest.get_modpath('mcl_core') then
        table.insert(deco_place_on, 'mcl_core:sand')
        table.insert(deco_biomes, 'Savanna_beach')
    end

    if next(deco_place_on) and next(deco_biomes) then
        minetest.register_decoration({
            name = 'x_farming:rice',
            deco_type = 'simple',
            place_on = deco_place_on,
            sidelen = 16,
            noise_params = {
                offset = -0.3,
                scale = 0.7,
                spread = { x = 200, y = 200, z = 200 },
                seed = 354,
                octaves = 3,
                persist = 0.7
            },
            biomes = deco_biomes,
            y_max = -1,
            y_min = -1,
            decoration = {
                'x_farming:rice_5',
                'x_farming:rice_6',
                'x_farming:rice_7',
                'x_farming:rice_8'
            },
            flags = 'force_placement'
        })
    end
end)
