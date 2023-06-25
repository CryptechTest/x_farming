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

local function place_rope(pos, itemstack)
    local next_node = minetest.get_node(pos)
    local stack_name = itemstack:get_name()

    while next_node.name == 'air' and not itemstack:is_empty() do
        minetest.set_node(pos, { name = stack_name, param1 = 0 })
        itemstack:take_item()
        pos.y = pos.y - 1
        next_node = minetest.get_node(pos)
    end

    return itemstack
end

minetest.register_node('x_farming:rope', {
    description = S('Rope') .. '. ' .. S('Placing rope on rope will prelong the rope downwards.'),
    drawtype = 'plantlike',
    walkable = false,
    paramtype = 'light',
    sunlight_propagates = true,
    climbable = true,
    wield_scale = { x = 2, y = 2, z = 1 },
    groups = {
        -- MTG
        snappy = 3,
        flammable = 3,
        rope = 1,
    },
    tiles = { 'x_farming_rope.png' },
    inventory_image = 'x_farming_rope_item.png',
    wield_image = 'x_farming_rope_item.png',
    selection_box = {
        type = 'fixed',
        fixed = { -2 / 16, -0.5, -2 / 16, 2 / 16, 0.5, 2 / 16 }
    },
    sounds = x_farming.node_sound_rope_defaults(),
    on_place = function(itemstack, placer, pointed_thing)
        local control = placer:get_player_control()
        local pt_pos = minetest.get_pointed_thing_position(pointed_thing)

        if pt_pos and pointed_thing.type == 'node' then
            local pt_node = minetest.get_node(pt_pos)

            if minetest.is_protected(pt_pos, placer:get_player_name()) then
                return itemstack
            end

            local pt_node_def = minetest.registered_nodes[pt_node.name]

            -- check if we have to use default on_place first
            if pt_node_def.on_rightclick then
                return pt_node_def.on_rightclick(pt_pos, pt_node, placer, itemstack, pointed_thing)
            end
        end

        -- placing rope on rope
        if pt_pos and not control.sneak then
            local pt_node = minetest.get_node(pt_pos)

            if minetest.get_item_group(pt_node.name, 'rope') > 0 then
                -- add to rope
                local _pos = vector.new(pt_pos)
                local next_node = minetest.get_node(_pos)

                while minetest.get_item_group(next_node.name, 'rope') > 0 do
                    _pos.y = _pos.y - 1
                    next_node = minetest.get_node(_pos)
                end

                return place_rope(_pos, itemstack)
            end
        end

        if pointed_thing.type == 'node' then
            local pos = pointed_thing.above

            if minetest.is_protected(pos, placer:get_player_name()) then
                return itemstack
            end

            return place_rope(pos, itemstack)
        end

        return itemstack
    end,
    on_punch = function(pos, node, puncher, pointed_thing)
        if minetest.is_protected(pos, puncher:get_player_name()) then
            return
        end

        local count = 0
        local below = vector.new(pos)
        local node_below = minetest.get_node(below)

        while minetest.get_item_group(node_below.name, 'rope') > 0 do
            minetest.remove_node(below)
            below.y = below.y - 1
            count = count + 1
            node_below = minetest.get_node(below)
        end

        if count == 0 then
            return
        end

        local stacks = {}
        local node_stack = ItemStack({ name = node.name })
        local stack_max = node_stack:get_stack_max()
        local stack_count = count

        if stack_count > stack_max then
            while stack_count > 0 do
                if stack_count > stack_max then
                    stack_count = stack_count - stack_max
                    table.insert(stacks, ItemStack({ name = node.name, count = stack_max }))
                else
                    table.insert(stacks, ItemStack({ name = node.name, count = stack_count }))
                    stack_count = 0
                end
            end
        else
            table.insert(stacks, ItemStack({ name = node.name, count = count }))
        end

        local inv = puncher:get_inventory()

        for _, stack in ipairs(stacks) do
            if inv and inv:room_for_item('main', stack) then
                inv:add_item('main', stack)
            else
                -- drop on the ground
                minetest.add_item(puncher:get_pos(), stack)
            end
        end

        return true
    end,
})

minetest.register_node('x_farming:safety_net', {
    description = S('Safety Net. No fall damage when landing on this net.'),
    drawtype = 'nodebox',
    node_box = {
        type = 'fixed',
        fixed = { -8 / 16, -8 / 16, -8 / 16, 8 / 16, -7 / 16, 8 / 16 },
    },
    selection_box = {
        type = 'fixed',
        fixed = { -8 / 16, -8 / 16, -8 / 16, 8 / 16, -6 / 16, 8 / 16 }
    },
    tiles = {
        'x_farming_safety_net.png',
        'x_farming_safety_net.png',
        'x_farming_safety_net_side.png',
    },
    use_texture_alpha = 'clip',
    wield_image = 'x_farming_safety_net.png',
    inventory_image = 'x_farming_safety_net.png',
    paramtype = 'light',
    sunlight_propagates = true,
    wield_scale = { x = 2, y = 2, z = 1 },
    groups = {
        -- MTG
        snappy = 3,
        flammable = 3,
        bouncy = 33,
        fall_damage_add_percent = -100,
    },
    sounds = x_farming.node_sound_rope_defaults()
})

minetest.register_node('x_farming:rope_fence', {
    description = S('Rope') .. ' ' .. S('Fence'),
    drawtype = 'nodebox',
    paramtype = 'light',
    climbable = true,
    wield_scale = { x = 2, y = 2, z = 1 },
    node_box = {
        type = 'connected',
        fixed = { -1 / 16, -1 / 2, -1 / 16, 1 / 16, 1 / 2, 1 / 16 },
        -- connect_top =
        -- connect_bottom =
        connect_front = {
            { 0, -8 / 16, -8 / 16, 0, 7 / 16, -1 / 16 }
        },
        connect_left = {
            { -1 / 2, -1 / 2, 0, -1 / 16, 7 / 16, 0 }
        },
        connect_back = {
            { 0, -8 / 16, 1 / 16, 0, 7 / 16, 1 / 2 }
        },
        connect_right = {
            { 1 / 16, -1 / 2, 0, 1 / 2, 7 / 16, 0 }
        }
    },
    collision_box = {
        type = 'connected',
        fixed = { -1 / 8, -1 / 2, -1 / 8, 1 / 8, 1 / 2, 1 / 8 },
        -- connect_top =
        -- connect_bottom =
        connect_front = { -1 / 8, -1 / 2, -1 / 2, 1 / 8, 1 / 2, -1 / 8 },
        connect_left = { -1 / 2, -1 / 2, -1 / 8, -1 / 8, 1 / 2, 1 / 8 },
        connect_back = { -1 / 8, -1 / 2, 1 / 8, 1 / 8, 1 / 2, 1 / 2 },
        connect_right = { 1 / 8, -1 / 2, -1 / 8, 1 / 2, 1 / 2, 1 / 8 }
    },
    connects_to = {
        -- MTG
        'group:fence',
        'group:wood',
        'group:tree',
        'group:wall',
        'group:stone',
    },
    inventory_image = 'x_farming_rope_fence_item.png',
    wield_image = 'x_farming_rope_fence_item.png',
    tiles = { 'x_farming_rope_fence.png' },
    use_texture_alpha = 'clip',
    sunlight_propagates = true,
    is_ground_content = false,
    groups = {
        -- MTG
        fence = 1,
        snappy = 3,
        flammable = 2
    },
    sounds = x_farming.node_sound_rope_defaults()
})
