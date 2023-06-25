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

local tree_defs = {
    {
        -- apple tree
        name = 'default:sapling',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_soil(pos) then
                return false
            end

            default.grow_new_apple_tree(pos)

            return true
        end
    },
    {
        -- jungle tree
        name = 'default:junglesapling',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_soil(pos) then
                return false
            end

            default.grow_new_jungle_tree(pos)

            return true
        end
    },
    {
        -- emergent jungle tree
        name = 'default:emergent_jungle_sapling',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_soil(pos) then
                return false
            end

            default.grow_new_emergent_jungle_tree(pos)

            return true
        end
    },
    {
        -- acacia tree
        name = 'default:acacia_sapling',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_soil(pos) then
                return false
            end

            default.grow_new_acacia_tree(pos)

            return true
        end
    },
    {
        -- aspen tree
        name = 'default:aspen_sapling',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_soil(pos) then
                return false
            end

            default.grow_new_aspen_tree(pos)

            return true
        end
    },
    {
        -- pine tree
        name = 'default:pine_sapling',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_soil(pos) then
                return false
            end

            if minetest.find_node_near(pos, 1, { 'group:snowy' }) then
                default.grow_new_snowy_pine_tree(pos)
            else
                default.grow_new_pine_tree(pos)
            end

            return true
        end
    },
    {
        -- Bush
        name = 'default:bush_sapling',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_soil(pos) then
                return false
            end

            default.grow_bush(pos)

            return true
        end
    },
    {
        -- Acacia bush
        name = 'default:acacia_bush_sapling',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_soil(pos) then
                return false
            end

            default.grow_acacia_bush(pos)

            return true
        end
    },
    {
        -- Pine bush
        name = 'default:pine_bush_sapling',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_soil(pos) then
                return false
            end

            default.grow_pine_bush(pos)

            return true
        end
    },
    {
        -- Blueberry bush
        name = 'default:blueberry_bush_sapling',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_soil(pos) then
                return false
            end

            default.grow_blueberry_bush(pos)

            return true
        end
    },
     {
        -- Papyrus
        name = 'default:papyrus',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_soil(pos) then
                return false
            end

            local node = minetest.get_node(pos)

            default.grow_papyrus(pos, node)

            return true
        end
    },
    {
        -- Large Cactus
        name = 'default:large_cactus_seedling',
        chance = 2,
        grow_tree = function(pos)
            if not x_farming.x_bonemeal.is_on_sand(pos) then
                return false
            end

            default.grow_large_cactus(pos)

            return true
        end
    },
}

x_farming.x_bonemeal:register_tree_defs(tree_defs)
