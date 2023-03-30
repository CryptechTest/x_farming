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

---how often node timers for plants will tick, +/- some random value
function x_farming.tick(pos)
    minetest.get_node_timer(pos):start(math.random(498, 1287))
end

---how often a growth failure tick is retried (e.g. too dark)
function x_farming.tick_short(pos)
    minetest.get_node_timer(pos):start(math.random(332, 858))
end

---just shorthand for minetest metadata handling
function x_farming.meta_get_str(key, pos)
    local meta = minetest.get_meta(pos)
    return meta:get_string(key)
end

---just shorthand for minetest metadata handling
function x_farming.meta_set_str(key, value, pos)
    local meta = minetest.get_meta(pos)
    meta:set_string(key, value)
end

---merge two indexed tables
function x_farming.mergeTables(t1, t2)
    local _t1 = { unpack(t1) }
    local _t2 = { unpack(t2) }

    for k, v in ipairs(_t2) do
        table.insert(_t1, v)
    end

    return _t1
end

---Change an entire string to Title Case (i.e. capitalise the first letter of each word)
function x_farming.tchelper(first, rest)
    return first:upper() .. rest:lower()
end

---grow blocks next to the plant
function x_farming.grow_block(pos, elapsed)
    local node = minetest.get_node(pos)
    local random_pos = false
    local spawn_positions = {}
    local right_pos = { x = pos.x + 1, y = pos.y, z = pos.z }
    local front_pos = { x = pos.x, y = pos.y, z = pos.z + 1 }
    local left_pos = { x = pos.x - 1, y = pos.y, z = pos.z }
    local back_pos = { x = pos.x, y = pos.y, z = pos.z - 1 }
    local right = minetest.get_node(right_pos)
    local front = minetest.get_node(front_pos)
    local left = minetest.get_node(left_pos)
    local back = minetest.get_node(back_pos)
    local def = minetest.registered_nodes[node.name]

    local children = {}

    ---look for fruits around the stem
    if (right.name == def.next_plant) then
        children.right = right_pos
    end
    if (front.name == def.next_plant) then
        children.front = front_pos
    end
    if (left.name == def.next_plant) then
        children.left = left_pos
    end
    if (back.name == def.next_plant) then
        children.back = back_pos
    end

    ---check if the fruit belongs to this stem
    for side, child_pos in pairs(children) do

        local parent_pos_from_child = x_farming.meta_get_str('parent', child_pos)

        ---disable timer for fully grown plant - fruit for this stem already exists
        if minetest.pos_to_string(pos) == parent_pos_from_child then
            return
        end
    end

    ---make sure that at least one side of the plant has space to put fruit
    if right.name == 'air' then
        table.insert(spawn_positions, right_pos)
    end
    if front.name == 'air' then
        table.insert(spawn_positions, front_pos)
    end
    if left.name == 'air' then
        table.insert(spawn_positions, left_pos)
    end
    if back.name == 'air' then
        table.insert(spawn_positions, back_pos)
    end

    ---plant is closed from all sides
    if #spawn_positions < 1 then
        x_farming.tick_short(pos)
        return
    else
        ---pick random from the open sides
        local pick_random

        if #spawn_positions == 1 then
            pick_random = #spawn_positions
        else
            pick_random = math.random(1, #spawn_positions)
        end

        for k, v in pairs(spawn_positions) do
            if k == pick_random then
                random_pos = v
            end
        end
    end

    ---check light
    local light = minetest.get_node_light(pos)
    if not light or light < 13 or light > default.LIGHT_MAX then
        x_farming.tick_short(pos)
        return
    end

    ---spawn block
    if random_pos then
        minetest.set_node(random_pos, { name = def.next_plant })
        x_farming.meta_set_str('parent', minetest.pos_to_string(pos), random_pos)
    end
    return
end

function x_farming.grow_kiwi_tree(pos)
    local path = minetest.get_modpath('x_farming') ..
        '/schematics/x_farming_kiwi_tree_from_sapling.mts'
    minetest.place_schematic({ x = pos.x - 2, y = pos.y, z = pos.z - 2 },
        path, 'random', nil, false)
end

---Grow sapling

function x_farming.grow_sapling(pos)
    if not default.can_grow(pos) then
        ---try again 5 min later
        minetest.get_node_timer(pos):start(300)
        return
    end

    local node = minetest.get_node(pos)
    if node.name == 'x_farming:kiwi_sapling' then
        minetest.log('action', 'A sapling grows into a tree at ' ..
        minetest.pos_to_string(pos))
        x_farming.grow_kiwi_tree(pos)
    end
end

---Grow Large Cactus

function x_farming.grow_large_cactus(pos)
    minetest.set_node(pos, {name = "air"})
    local path = minetest.get_modpath('x_farming') ..
        '/schematics/x_farming_large_cactus_from_seedling.mts'
    if (math.random(1,2) == 1) then
        path = minetest.get_modpath('x_farming') ..
        '/schematics/x_farming_large_cactus.mts'
    end
    minetest.place_schematic({ x = pos.x, y = pos.y, z = pos.z },
        path, 'random', nil, false, 'place_center_x, place_center_z')
end

---Grow Jungle Tree

function x_farming.grow_jungle_tree(pos)
    local path = minetest.get_modpath('x_farming') ..
        '/schematics/x_farming_jungle_tree_with_cocoa_from_sapling.mts'
    minetest.place_schematic({ x = pos.x - 2, y = pos.y - 1, z = pos.z - 2 },
        path, nil, nil, false)
end

---Pine Nut Tree

function x_farming.grow_pine_nut_tree(pos)
    local path = minetest.get_modpath('x_farming') ..
        '/schematics/x_farming_pine_nut_tree_from_sapling.mts'
    minetest.place_schematic({ x = pos.x - 2, y = pos.y, z = pos.z - 2 },
        path, '0', nil, false)
end

---Christmas Tree

function x_farming.grow_christmas_tree(pos)
    local path
    if math.random() > 0.5 then
        path = minetest.get_modpath('x_farming')..'/schematics/x_farming_christmas_tree_large.mts'
        minetest.place_schematic({ x = pos.x - 2, y = pos.y, z = pos.z - 2 }, path, '0', nil, false)
    else
        path = minetest.get_modpath('x_farming')..'/schematics/x_farming_christmas_tree.mts'
        minetest.place_schematic({ x = pos.x - 1, y = pos.y, z = pos.z - 1 }, path, '0', nil, false)
    end
end

----
--- Crates and Bags
----

function x_farming.tick_crates(pos)
    minetest.get_node_timer(pos):start(math.random(332, 572))
end

function x_farming.tick_again_crates(pos)
    minetest.get_node_timer(pos):start(math.random(80, 160))
end

function x_farming.get_crate_or_bag_formspec(pos, label_copy)
    local spos = pos.x .. ',' .. pos.y .. ',' .. pos.z
    local formspec = {
        'size[8,9]',
        'list[nodemeta:', spos, ';main;0,0.3;8,4;]',
        'list[current_player;main;0,4.85;8,1;]',
        'list[current_player;main;0,6.08;8,3;8]',
        'listring[nodemeta:', spos, ';main]',
        'listring[current_player;main]',
        'label[2,0;' .. minetest.formspec_escape(label_copy) .. ']',
        default.get_hotbar_bg(0, 4.85)
    }

    formspec = table.concat(formspec, '')

    return formspec
end

---Crate
function x_farming.register_crate(name, def)
    local _def = table.copy(def) or {}

    _def._custom = _def._custom or {}

    _def.name = 'x_farming:' .. name
    _def.description = def.description or name
    _def.short_description = def.short_description or def.description
    _def.drawtype = 'mesh'
    _def.paramtype = 'light'
    _def.paramtype2 = 'facedir'
    _def.mesh = 'x_farming_crate.obj'
    _def.tiles = def.tiles
    _def.sounds = def.sounds or default.node_sound_wood_defaults()
    _def.is_ground_content = false
    _def.groups = def.groups or { choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1, flammable = 2 }
    _def.stack_max = def.stack_max or 1
    _def.mod_origin = 'x_farming'

    if _def._custom.crate_item then
        x_farming.allowed_crate_items[_def._custom.crate_item] = true
    end

    _def.on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        meta:set_string('infotext', _def.short_description)
        meta:set_string('owner', '')
        inv:set_size('main', 1)
    end

    _def.after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        local meta_st = itemstack:get_meta()
        local crate_inv = minetest.deserialize(meta_st:get_string('crate_inv'))
        local inv = meta:get_inventory()

        if crate_inv then
            inv:add_item('main', ItemStack(crate_inv))
        end

        local node = minetest.get_node(pos)

        meta:set_string('owner', placer:get_player_name() or '')

        if not inv:is_empty('main') then
            local inv_stack = inv:get_stack('main', 1)

            meta:set_string('infotext', _def.short_description
                .. ' (' .. S('owned by') .. ' ' .. meta:get_string('owner') .. ')\n'
                .. inv_stack:get_description() .. '\n' .. S('Quantity') .. ': ' .. inv_stack:get_count())
        else
            local swap_node = minetest.registered_nodes['x_farming:crate_empty']
            if swap_node and inv:is_empty('main') and node.name ~= swap_node.name then
                minetest.swap_node(pos, { name = swap_node.name, param2 = node.param2 })
                meta:set_string('infotext', swap_node.short_description
                    .. ' (' .. S('owned by') .. ' ' .. meta:get_string('owner') .. ')')
            end
        end
    end

    _def.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local p_name = clicker:get_player_name()
        if minetest.is_protected(pos, p_name) then
            return itemstack
        end

        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local inv_stack = inv:get_stack('main', 1)
        local label_copy = _def.short_description .. ' (' .. S('owned by') .. ' ' .. meta:get_string('owner')
            .. ')\n' .. inv_stack:get_description()
        minetest.show_formspec(p_name, _def.name, x_farming.get_crate_or_bag_formspec(pos, label_copy))
        minetest.sound_play('default_dig_choppy', { gain = 0.3, pos = pos, max_hear_distance = 10 }, true)
    end

    _def.on_blast = function(pos, intensity)
        if minetest.is_protected(pos, '') then
            return
        end

        local drops = {}
        local inv = minetest.get_meta(pos):get_inventory()
        local n = #drops

        for i = 1, inv:get_size('main') do
            local stack = inv:get_stack('main', i)
            if stack:get_count() > 0 then
                drops[n + 1] = stack:to_table()
                n = n + 1
            end
        end

        drops[#drops + 1] = name
        minetest.remove_node(pos)
        return drops
    end

    _def.can_dig = function(pos, player)
        return not minetest.is_protected(pos, player:get_player_name())
    end

    _def.preserve_metadata = function(pos, oldnode, oldmeta, drops)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local stack = drops[1]
        local meta_drop = stack:get_meta()

        if not inv:is_empty('main') then
            local inv_stack = inv:get_stack('main', 1)

            meta_drop:set_string('crate_inv', minetest.serialize(inv_stack:to_table()))
            meta_drop:set_string('description', stack:get_description() .. '\n' .. inv_stack:get_description()
                .. '\n' .. S('Quantity') .. ': ' .. inv_stack:get_count())

            return
        end
    end

    _def.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local st_name = stack:get_name()

        if minetest.is_protected(pos, player:get_player_name())
            or (
                not x_farming.allowed_crate_items[st_name]
                and minetest.get_item_group(st_name, 'fish') == 0
            )
        then
            return 0
        end

        return stack:get_count()
    end

    _def.allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        local st_name = stack:get_name()

        if minetest.is_protected(pos, player:get_player_name())
            or (
                not x_farming.allowed_crate_items[st_name]
                and minetest.get_item_group(st_name, 'fish') == 0
            )
        then
            return 0
        end

        return stack:get_count()
    end

    _def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
        local stack_name = stack:get_name()

        if not stack_name or stack_name == '' then
            return
        end

        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local node = minetest.get_node(pos)
        local inv_stack = inv:get_stack('main', 1)
        local split_name = stack_name:split(':')

        if minetest.get_item_group(stack_name, 'fish') ~= 0 then
            split_name = { 'x_farming', 'fish' }
        end

        local swap_node = minetest.registered_nodes['x_farming:crate_' .. split_name[2] .. '_3']

        if not swap_node then
            return
        end

        if not inv:is_empty(listname) and node.name ~= swap_node.name then
            local p_name = player:get_player_name()

            minetest.swap_node(pos, { name = swap_node.name, param2 = node.param2 })

            local label_copy = swap_node.short_description .. ' (' .. S('owned by') .. ' ' .. meta:get_string('owner') .. ')\n'
                .. inv_stack:get_description()

            minetest.show_formspec(p_name, _def.name, x_farming.get_crate_or_bag_formspec(pos, label_copy))
        end

        meta:set_string('infotext', swap_node.short_description .. ' (' .. S('owned by')
            .. ' ' .. meta:get_string('owner') .. ')\n'
            .. inv_stack:get_description() .. '\n' .. S('Quantity') .. ': ' .. inv_stack:get_count())
    end

    _def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local inv_stack = inv:get_stack('main', 1)
        local node = minetest.get_node(pos)

        if inv:is_empty(listname) then
            local p_name = player:get_player_name()
            local swap_node = minetest.registered_nodes['x_farming:crate_empty']

            if swap_node then
                minetest.swap_node(pos, { name = swap_node.name, param2 = node.param2 })
                meta:set_string('infotext', swap_node.short_description
                    .. ' (' .. S('owned by') .. ' ' .. meta:get_string('owner') .. ')')

                local label_copy = swap_node.short_description .. ' (' .. S('owned by') .. ' '
                    .. meta:get_string('owner') .. ')\n' .. inv_stack:get_description()

                minetest.show_formspec(p_name, _def.name, x_farming.get_crate_or_bag_formspec(pos, label_copy))
            end
        else
            local node_def = minetest.registered_nodes[node.name]

            if node_def then
                meta:set_string('infotext', node_def.short_description
                    .. ' (' .. S('owned by') .. ' ' .. meta:get_string('owner') .. ')\n'
                    .. inv_stack:get_description() .. '\n' .. S('Quantity') .. ': ' .. inv_stack:get_count())
            end
        end
    end

    _def.on_timer = function(pos, elapsed)
        local pos_above = { x = pos.x, y = pos.y + 1, z = pos.z }
        local node_above = minetest.get_node(pos_above)

        if not node_above then
            x_farming.tick_again_crates(pos)
            return
        end

        if node_above.name ~= 'air' then
            x_farming.tick_again_crates(pos)
            return
        end

        local rand1 = math.random(1, 2) / 10

        minetest.add_particlespawner({
            amount = 60,
            time = 15,
            minpos = { x = pos_above.x - 0.1, y = pos_above.y - 0.3, z = pos_above.z - 0.1 },
            maxpos = { x = pos_above.x + 0.1, y = pos_above.y + 0.4, z = pos_above.z + 0.1 },
            minvel = { x = rand1 * -1, y = rand1 * -1, z = rand1 * -1 },
            maxvel = { x = rand1, y = rand1, z = rand1 },
            minacc = { x = rand1 * -1, y = rand1 * -1, z = rand1 * -1 },
            maxacc = { x = rand1, y = rand1, z = rand1 },
            minexptime = 1,
            maxexptime = 1.5,
            minsize = 0.1,
            maxsize = 0.3,
            texture = 'x_farming_fly.png',
            collisiondetection = true,
            object_collision = true
        })

        x_farming.tick_crates(pos)
    end

    x_farming.registered_crates[_def.name] = _def

    if _def.name ~= 'x_farming:crate_empty' then
        table.insert(x_farming.lbm_nodenames_crates, _def.name)
    end

    minetest.register_node(_def.name, _def)
end

---Bag
function x_farming.register_bag(name, def)
    local _def = table.copy(def) or {}

    _def._custom = _def._custom or {}

    _def.name = 'x_farming:' .. name
    _def.description = def.description or name
    _def.short_description = def.short_description or def.description
    _def.drawtype = 'mesh'
    _def.paramtype = 'light'
    _def.paramtype2 = 'facedir'
    _def.mesh = 'x_farming_bag.obj'
    _def.tiles = def.tiles
    _def.sounds = def.sounds or default.node_sound_sand_defaults()
    _def.is_ground_content = false
    _def.groups = def.groups or { choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1, flammable = 2 }
    _def.stack_max = def.stack_max or 1
    _def.mod_origin = 'x_farming'

    if _def._custom.bag_item then
        x_farming.allowed_bag_items[_def._custom.bag_item] = true
    end

    _def.on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        meta:set_string('infotext', _def.short_description)
        meta:set_string('owner', '')
        inv:set_size('main', 1)
    end

    _def.after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        local meta_st = itemstack:get_meta()
        local bag_inv = minetest.deserialize(meta_st:get_string('bag_inv'))
        local inv = meta:get_inventory()

        if bag_inv then
            inv:add_item('main', ItemStack(bag_inv))
        end

        local node = minetest.get_node(pos)

        meta:set_string('owner', placer:get_player_name() or '')

        if not inv:is_empty('main') then
            local inv_stack = inv:get_stack('main', 1)

            meta:set_string('infotext', _def.short_description .. ' (' .. S('owned by') .. ' '
                .. meta:get_string('owner') .. ')\n' .. inv_stack:get_description()
                .. '\n' .. S('Quantity') .. ': ' .. inv_stack:get_count())
        else
            local swap_node = minetest.registered_nodes['x_farming:bag_empty']
            if swap_node and inv:is_empty('main') and node.name ~= swap_node.name then
                minetest.swap_node(pos, { name = swap_node.name, param2 = node.param2 })
                meta:set_string('infotext', swap_node.short_description
                    .. ' (' .. S('owned by') .. ' ' .. meta:get_string('owner') .. ')')
            end
        end
    end

    _def.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local p_name = clicker:get_player_name()

        if minetest.is_protected(pos, p_name) then
            return itemstack
        end

        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local inv_stack = inv:get_stack('main', 1)
        local label_copy = _def.short_description .. ' (' .. S('owned by') .. ' ' .. meta:get_string('owner') .. ')\n'
            .. inv_stack:get_description()
        minetest.show_formspec(p_name, _def.name, x_farming.get_crate_or_bag_formspec(pos, label_copy))
        minetest.sound_play('default_sand_footstep', { gain = 0.3, pos = pos, max_hear_distance = 10 }, true)
    end

    _def.on_blast = function(pos, intensity)
        if minetest.is_protected(pos, '') then
            return
        end

        local drops = {}
        local inv = minetest.get_meta(pos):get_inventory()
        local n = #drops

        for i = 1, inv:get_size('main') do
            local stack = inv:get_stack('main', i)
            if stack:get_count() > 0 then
                drops[n + 1] = stack:to_table()
                n = n + 1
            end
        end

        drops[#drops + 1] = name
        minetest.remove_node(pos)
        return drops
    end

    _def.can_dig = function(pos, player)
        return not minetest.is_protected(pos, player:get_player_name())
    end

    _def.preserve_metadata = function(pos, oldnode, oldmeta, drops)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local stack = drops[1]
        local meta_drop = stack:get_meta()

        if not inv:is_empty('main') then
            local inv_stack = inv:get_stack('main', 1)

            meta_drop:set_string('bag_inv', minetest.serialize(inv_stack:to_table()))
            meta_drop:set_string('description', stack:get_description() .. '\n'
                .. inv_stack:get_description() .. '\n' .. S('Quantity') .. ': ' .. inv_stack:get_count())

            return
        end
    end

    _def.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if minetest.is_protected(pos, player:get_player_name()) or not x_farming.allowed_bag_items[stack:get_name()] then
            return 0
        end

        return stack:get_count()
    end

    _def.allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if minetest.is_protected(pos, player:get_player_name()) or not x_farming.allowed_bag_items[stack:get_name()] then
            return 0
        end

        return stack:get_count()
    end

    _def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
        local stack_name = stack:get_name()

        if not stack_name or stack_name == '' then
            return
        end

        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local split_name = stack_name:split(':')
        local node = minetest.get_node(pos)
        local swap_node = minetest.registered_nodes['x_farming:bag_' .. split_name[2]]
        local inv_stack = inv:get_stack('main', 1)

        if not swap_node then
            return
        end

        if not inv:is_empty(listname) and node.name ~= swap_node.name then
            local p_name = player:get_player_name()

            minetest.swap_node(pos, { name = swap_node.name, param2 = node.param2 })

            local label_copy = swap_node.short_description .. ' (' .. S('owned by') .. ' ' .. meta:get_string('owner') .. ')\n'
                .. inv_stack:get_description()

            minetest.show_formspec(p_name, _def.name, x_farming.get_crate_or_bag_formspec(pos, label_copy))
        end

        meta:set_string('infotext', swap_node.short_description .. ' (' .. S('owned by')
            .. ' ' .. meta:get_string('owner') .. ')\n'
            .. inv_stack:get_description() .. '\n' .. S('Quantity') .. ': ' .. inv_stack:get_count())
    end

    _def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local inv_stack = inv:get_stack('main', 1)
        local node = minetest.get_node(pos)

        if inv:is_empty(listname) then
            local p_name = player:get_player_name()
            local swap_node = minetest.registered_nodes['x_farming:bag_empty']

            if swap_node then
                minetest.swap_node(pos, { name = swap_node.name, param2 = node.param2 })
                meta:set_string('infotext', swap_node.short_description
                    .. ' (' .. S('owned by') .. ' ' .. meta:get_string('owner') .. ')')

                local label_copy = swap_node.short_description
                    .. ' (' .. S('owned by') .. ' ' .. meta:get_string('owner') .. ')\n' .. inv_stack:get_description()

                minetest.show_formspec(p_name, _def.name, x_farming.get_crate_or_bag_formspec(pos, label_copy))
            end
        else
            local node_def = minetest.registered_nodes[node.name]

            if node_def then
                meta:set_string('infotext', node_def.short_description .. ' (' .. S('owned by') .. ' '
                    .. meta:get_string('owner') .. ')\n' .. inv_stack:get_description()
                    .. '\n' .. S('Quantity') .. ': ' .. inv_stack:get_count())
            end
        end
    end

    minetest.register_node(_def.name, _def)
end

--
---Bonemeal
--

------------
---Main API for x_bonemeal Mod
---@author Juraj Vajda
---@license GNU LGPL 2.1
----

---Get creative mode setting from minetest.conf
local creative_mod_cache = minetest.settings:get_bool('creative_mode')

---Check if creating mode is enabled or player has creative privs
---@param name string name
---@return boolean
function x_farming.x_bonemeal.is_creative(name)
    return creative_mod_cache or minetest.check_player_privs(name, { creative = true })
end

---Check if node has a soil below its self
---@param under Vector of position
---@return boolean
function x_farming.x_bonemeal.is_on_soil(under)
    local below = minetest.get_node_or_nil({ x = under.x, y = under.y - 1, z = under.z })

    if not below then
        return false
    end

    if minetest.get_item_group(below.name, 'soil') == 0 then
        return false
    end

    return true
end

---Check if node has a sand below its self
---@param under Vector of position
---@return boolean
function x_farming.x_bonemeal.is_on_sand(under)
    local below = minetest.get_node_or_nil({ x = under.x, y = under.y - 1, z = under.z })

    if not below then
        return false
    end

    if minetest.get_item_group(below.name, 'sand') == 0 then
        return false
    end

    return true
end

---Growth steps for farming plants, there is no way of getting them dynamically,
--- so they are defined in the local table variable
local farming_steps = {
    ['farming:wheat'] = 8,
    ['farming:cotton'] = 8,
    ['x_farming:coffee'] = 5,
    ['x_farming:corn'] = 10,
    ['x_farming:obsidian_wart'] = 6,
    ['x_farming:melon'] = 8,
    ['x_farming:pumpkin'] = 8,
    ['x_farming:carrot'] = 8,
    ['x_farming:potato'] = 8,
    ['x_farming:beetroot'] = 8,
    ['x_farming:strawberry'] = 4,
    ['x_farming:stevia'] = 8,
    ['x_farming:soybean'] = 7,
    ['x_farming:salt'] = 7,
}

---Particle and sound effect after the bone meal is successfully used
---@param pos Vector containing position
function x_farming.x_bonemeal.particle_effect(pos)
    minetest.sound_play('x_farming_x_bonemeal_grow', {
        pos = {x = pos.x, y = pos.y - 1, z = pos.z},
        gain = 0.1,
    })

    minetest.add_particlespawner({
        amount = 6,
        time = 3,
        minpos = { x = pos.x - 0.4, y = pos.y - 0.4, z = pos.z - 0.4 },
        maxpos = { x = pos.x + 0.4, y = pos.y, z = pos.z + 0.4 },
        minvel = { x = 0, y = 0, z = 0 },
        maxvel = { x = 0, y = 0.1, z = 0 },
        minacc = vector.new({ x = 0, y = 0, z = 0 }),
        maxacc = vector.new({ x = 0, y = 0.1, z = 0 }),
        minexptime = 2,
        maxexptime = 3,
        minsize = 1,
        maxsize = 3,
        texture = 'x_farming_x_bonemeal_particles.png',
        animation = {
            type = 'vertical_frames',
            aspect_w = 8,
            aspect_h = 8,
            length = 3,
        },
    })
end

function x_farming.x_bonemeal.tableContains(table, value)
    local found = false

    if not table or type(table) ~= 'table' then
        return found
    end

    for k, v in ipairs(table) do
        if v == value then
            found = true
            break
        end
    end

    return found
end

function x_farming.x_bonemeal.groupContains(groups, fertility, value)
    local found = false

    if not groups or type(groups) ~= 'table' then
        return found
    end

    if groups[fertility] and groups[fertility] == value then
        found = true
    end

    return found
end

---Handle growth of decorations based on biome
---@param itemstack ItemStack
---@param user ObjectRef | nil
---@param pointed_thing PointedThingDef
---@return { ['success']: boolean, ['itemstack']: ItemStack }
function x_farming.x_bonemeal.grow_grass_and_flowers(itemstack, user, pointed_thing)
    local result = {
        success = false,
        itemstack = itemstack
    }
    local node = minetest.get_node(pointed_thing.under)

    if not node then
        return result
    end

    local pos0 = vector.subtract(pointed_thing.under, 3)
    local pos1 = vector.add(pointed_thing.under, 3)
    local biome_data = minetest.get_biome_data(pointed_thing.under)

    if not biome_data then
        return result
    end

    local biome_name = minetest.get_biome_name(biome_data.biome)

    if not biome_name then
        return result
    end

    local random_number = math.random(2, 6)
    local registered_decorations_filtered = {}
    ---@type ItemStack | nil
    local returned_itemstack
    local node_def = minetest.registered_nodes[node.name]
    local below_water = false
    local floats_on_water = false
    local node_in_decor = false
    local positions_dirty
    local positions = {}
    local decor_place_on = {}
    -- print('biome_name', biome_name)

    ---check 1 node below pointed node (floats on water)
    local test_node = minetest.get_node({
        x = pointed_thing.under.x,
        y = pointed_thing.under.y - 1,
        z = pointed_thing.under.z
    })
    local test_node_def = minetest.registered_nodes[test_node.name]

    if test_node_def
        and test_node_def.liquidtype == 'source'
        and minetest.get_item_group(test_node_def.name, 'water') > 0
    then
        floats_on_water = true
    end

    ---check 2 nodes above pointed nodes (below water)
    local water_nodes_above = 0
    for i = 1, 2 do
        local test_node2 = minetest.get_node({
            x = pointed_thing.under.x,
            y = pointed_thing.under.y + i,
            z = pointed_thing.under.z
        })
        local test_node_def2 = minetest.registered_nodes[test_node2.name]

        if test_node_def2
            and test_node_def2.liquidtype == 'source'
            and minetest.get_item_group(test_node_def2.name, 'water') > 0
        then
            water_nodes_above = water_nodes_above + 1
        end
    end

    if water_nodes_above == 2 then
        below_water = true
    end

    if below_water then
        positions_dirty = minetest.find_nodes_in_area(pos0, pos1, node.name)
    elseif floats_on_water then
        positions_dirty = minetest.find_nodes_in_area(pos0, pos1, 'air')
    else
        positions_dirty = minetest.find_nodes_in_area_under_air(pos0, pos1, node.name)
    end

    ---find suitable decorations
    for _, v in pairs(minetest.registered_decorations) do
        ---only for 'simple' decoration types
        if v.deco_type == 'simple' then
            ---filter based on biome name in `biomes` table and node name in `place_on` table
            if x_farming.x_bonemeal.tableContains(v.biomes, biome_name) then
                table.insert(registered_decorations_filtered, v)
            end
        end

        ---clicked node is in decoration
        local _decoration = v.decoration

        if type(v.decoration) == 'string' then
            _decoration = { v.decoration }
        end

        if x_farming.x_bonemeal.tableContains(_decoration, node.name) then
            node_in_decor = true
        end

        ---all nodes on which decoration can be placed on
        ---indexed by name
        if not decor_place_on[v.place_on] then
            if type(v.place_on) == 'string' then
                decor_place_on[v.place_on] = true
            elseif type(v.place_on) == 'table' then
                for _, v2 in ipairs(v.place_on) do
                    decor_place_on[v2] = true
                end
            end
        end
    end

    ---find suitable positions
    for j, pos_value in ipairs(positions_dirty) do
        local node_at_pos = minetest.get_node(pos_value)

        if below_water then
            ---below water
            local water_nodes_above2 = 0

            ---check if 2 nodes above are water
            for i = 1, 2 do
                local test_node3 = minetest.get_node({ x = pos_value.x, y = pos_value.y + i, z = pos_value.z })
                local test_node_def3 = minetest.registered_nodes[test_node3.name]

                if test_node_def3
                    and test_node_def3.liquidtype == 'source'
                    and minetest.get_item_group(test_node_def3.name, 'water') > 0
                then
                    water_nodes_above2 = water_nodes_above2 + 1
                end
            end

            if water_nodes_above2 == 2 and decor_place_on[test_node.name] then
                table.insert(positions, pos_value)
            end
        else
            ---above water (not on water)
            if decor_place_on[node_at_pos.name] then
                table.insert(positions, pos_value)
            end
        end
    end

    ---find suitable positions (float on water)
    if floats_on_water then
        for _, pos_value in ipairs(positions_dirty) do
            local node_at_pos_below = minetest.get_node({ x = pos_value.x, y = pos_value.y - 1, z = pos_value.z })
            local test_node_def4 = minetest.registered_nodes[node_at_pos_below.name]

            if test_node_def4
                and test_node_def4.liquidtype == 'source'
                and minetest.get_item_group(test_node_def4.name, 'water') > 0
            then
                table.insert(positions, pos_value)
            end
        end
    end

    local returned_itemstack_success = 0

    ---place decorations on random positions
    if #positions > 0 and #registered_decorations_filtered > 0 then
        for i = 1, random_number do
            local idx = math.random(1, #positions)
            local random_pos = positions[idx]
            local random_decor = registered_decorations_filtered[math.random(1, #registered_decorations_filtered)]
            local random_decor_item = random_decor.decoration

            if floats_on_water and node_in_decor then
                random_decor_item = node.name
            elseif type(random_decor.decoration) == 'table' then
                random_decor_item = random_decor.decoration[math.random(1, #random_decor.decoration)]
            end

            local random_decor_item_def = minetest.registered_nodes[random_decor_item]

            if random_pos ~= nil then
                if random_decor_item_def.on_place ~= nil and node_def and not node_def.on_rightclick then
                    ---on_place
                    local pt = {
                        type = 'node',
                        above = {
                            x = random_pos.x,
                            y = random_pos.y + 1,
                            z = random_pos.z
                        },
                        under = {
                            x = random_pos.x,
                            y = random_pos.y,
                            z = random_pos.z
                        }
                    }

                    if floats_on_water then
                        pt.above.y = random_pos.y
                        pt.under.y = random_pos.y - 1
                    end

                    returned_itemstack = random_decor_item_def.on_place(ItemStack(random_decor_item), user, pt)

                    if returned_itemstack and returned_itemstack:is_empty() then
                        returned_itemstack_success = returned_itemstack_success + 1
                        x_farming.x_bonemeal.particle_effect(pt.above)
                    end
                elseif random_decor_item_def ~= nil then
                    ---everything else
                    local pos_y = 1

                    if random_decor.place_offset_y ~= nil then
                        pos_y = random_decor.place_offset_y
                    end

                    x_farming.x_bonemeal.particle_effect(random_pos)
                    minetest.set_node({
                        x = random_pos.x,
                        y = random_pos.y + pos_y,
                        z = random_pos.z
                    },
                    { name = random_decor_item })
                end

                table.remove(positions, idx)
            else
                return result
            end
        end
    else
        return result
    end

    ---take item
    if returned_itemstack_success > 0
        and not x_farming.x_bonemeal.is_creative(user:get_player_name())
    then
        itemstack:take_item()
    end

    result.success = true
    result.itemstack = itemstack
    return result
end

---Handle farming and farming addons plants.
---Needed to copy this function from minetest_game and modify it in order to ommit some checks (e.g. light..)
---@param itemstack ItemStack
---@param user ObjectRef | nil
---@param pointed_thing PointedThingDef
---@return { ['success']: boolean, ['itemstack']: ItemStack }
function x_farming.x_bonemeal.grow_farming(itemstack, user, pointed_thing)
    local result = {
        success = false,
        itemstack = itemstack
    }
    local pos_under = pointed_thing.under
    local replace_node_name = minetest.get_node(pos_under).name
    local ndef = minetest.registered_nodes[replace_node_name]
    local take_item = false

    if not ndef.next_plant
        or ndef.next_plant == 'x_farming:pumpkin_fruit'
        or ndef.next_plant == 'x_farming:melon_fruit'
    then
        return result
    end

    local pos0 = vector.subtract(pointed_thing.under, 3)
    local pos1 = vector.add(pointed_thing.under, 3)
    local positions = minetest.find_nodes_in_area(pos0, pos1, { 'group:plant', 'group:seed' })

    for i, pos in ipairs(positions) do
        local isFertile = false
        replace_node_name = minetest.get_node(pos).name

        ---check if on wet soil
        local below = minetest.get_node({ x = pos.x, y = pos.y - 1, z = pos.z })
        local below_def = minetest.registered_nodes[below.name]

        if minetest.get_item_group(below.name, 'soil') == 3 then
            local current_step = tonumber(string.reverse(string.reverse(replace_node_name):split('_')[1]))
            local max_step = farming_steps[replace_node_name:gsub('_%d+', '', 1)]

            ---check if seed
            ---farming:seed_wheat
            local mod_plant = replace_node_name:split(':')
            ---seed_wheat
            local seed_plant = mod_plant[2]:split('_')
            local seed_name = replace_node_name

            if seed_plant[1] == 'seed' then
                current_step = 0
                if replace_node_name == 'x_farming:seed_obsidian_wart' then
                    replace_node_name = mod_plant[1] .. ':' .. seed_plant[2] .. '_' .. seed_plant[3]
                else
                    replace_node_name = mod_plant[1] .. ':' .. seed_plant[2]
                end
                max_step = farming_steps[replace_node_name]
                replace_node_name = replace_node_name .. '_' .. current_step
            else
                if string.find(replace_node_name, 'obsidian_wart') then
                    seed_name = mod_plant[1] .. ':seed_' .. seed_plant[1] .. '_' .. seed_plant[2]
                else
                    seed_name = mod_plant[1] .. ':seed_' .. seed_plant[1]
                end
            end

            ---search for fertility (again after checking soil)
            local seed_def = minetest.registered_nodes[seed_name]

            if seed_def and below_def then
                if below_def.groups then
                    for _, v in ipairs(seed_def.fertility) do
                        if not isFertile then
                            isFertile = x_farming.x_bonemeal.groupContains(below_def.groups, v, 1)
                        end
                    end
                end
            end

            if current_step ~= nil and max_step ~= nil and current_step ~= max_step and isFertile then
                local available_steps = max_step - current_step
                local new_step = max_step - available_steps + math.random(available_steps)
                local new_plant = replace_node_name:gsub('_%d+', '_' .. new_step, 1)
                take_item = true

                local placenode_def = minetest.registered_nodes[new_plant]

                local placenode = { name = new_plant }
                if placenode_def and placenode_def.place_param2 then
                    placenode.param2 = placenode_def.place_param2
                end
                x_farming.x_bonemeal.particle_effect(pos)
                minetest.swap_node(pos, placenode)
            end
        end
    end

    ---take item if not in creative
    if not x_farming.x_bonemeal.is_creative(user:get_player_name()) and take_item then
        itemstack:take_item()
    end

    return {
        success = true,
        itemstack = itemstack
    }
end

---XBonemeal on_use
---@param self table x_farming.x_bonemeal
---@param itemstack ItemStack
---@param user ObjectRef | nil
---@param pointed_thing any
---@return { ['success']: boolean, ['itemstack']: ItemStack }
function x_farming.x_bonemeal.on_use(self, itemstack, user, pointed_thing)
    local result = {
        success = false,
        itemstack = itemstack
    }

    if not user then
        return result
    end

    local under = pointed_thing.under

    if not under then
        return result
    end
    if pointed_thing.type ~= 'node' then
        return result
    end
    if minetest.is_protected(under, user:get_player_name()) then
        return result
    end

    local node = minetest.get_node(under)

    if not node then
        return result
    end
    if node.name == 'ignore' then
        return result
    end

    local mod = node.name:split(':')[1]

    if (mod == 'farming' or mod == 'x_farming')
        and not string.find(node.name, '_sapling')
        and not string.find(node.name, '_seedling')
    then
        --
        -- Farming
        --
        return self.grow_farming(itemstack, user, pointed_thing)
    elseif self.tree_defs[node.name] then
        --
        -- Default (Trees, Bushes, Papyrus)
        --
        local def = self.tree_defs[node.name]
        local chance = math.random(1, def.chance)

        if chance == 1 then
            local success = def.grow_tree(under)

            if not success then
                return result
            end

            self.particle_effect({ x = under.x, y = under.y + 1, z = under.z })
        end

        -- take item if not in creative
        if not self.is_creative(user:get_player_name()) then
            itemstack:take_item()
        end

        return {
            success = true,
            itemstack = itemstack
        }
    else
        return self.grow_grass_and_flowers(itemstack, user, pointed_thing)
    end
end

--- API for registering tree growing from saplings using bonemeal
function x_farming.x_bonemeal.register_tree_defs(self, defs)
    if not defs or type(defs) ~= 'table' then
        minetest.log('warning', '[x_farming][x_bonemeal] Missing or incorrect definition: \n' .. dump(defs))
    end

    for _, value in ipairs(defs) do
        local def = table.copy(value)
        if not self.tree_defs[def.name] then
            self.tree_defs[def.name] = value
        end
    end
end
