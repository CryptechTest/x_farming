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

mobs = minetest.global_exists('mobs') and mobs --[[@as table]]

local S = minetest.get_translator(minetest.get_current_modname())

mobs.npc_drops = {
  'default:mese_crystal',
  'default:pick_steel',
  'default:pick_bronze',
  'default:sword_steel',
  'default:sword_bronze',
  'default:shovel_steel',
  'default:shovel_bronze',
  'default:axe_steel',
  'default:axe_bronze',
  'farming:bread',
  'farming:hoe_steel',
  'default:diamond',
  'default:gold_lump',
  'default:coalblock'
}

local snow_golem_def = {
  type = 'npc',
  passive = false,
  pathfinding = true,
  docile_by_day = true,
  attack_type = 'dogshoot',
  attacks_monsters = true,
  group_attack = true,
  owner_loyal = true,
  shoot_interval = 0.9,
  dogshoot_switch = 1,
  dogshoot_count_max = 10,
  arrow = 'mobs_npc:snowball_arrow',
  shoot_offset = 1,
  reach = 2,
  damage = 3,
  hp_min = 35,
  hp_max = 70,
  armor = 100,
  collisionbox = { -0.35, -0.1, -0.35, 0.35, 1.89, 0.35 },
  visual_size = { x = 2.9, y = 2.9 },
  visual = 'mesh',
  mesh = 'x_farming_snowman.b3d',
  drawtype = 'front',
  textures = {
    { 'x_farming_snowman.png^x_farming_snowman_pumpkin.png' },
  },
  blood_texture = 'default_snowball.png',
  owner = '',
  order = 'follow',
  makes_footstep_sound = true,
  walk_velocity = 0.6,
  run_velocity = 2,
  view_range = 15,
  jump = true,
  floats = 1,
  drops = {
    { name = 'default:snow', chance = 1, min = 0, max = 15 },
    { name = 'mobs_npc:seed_pumpkin', chance = 5, min = 1, max = 3 }
  },
  follow = { 'farming:bread', 'default:diamond' },
  water_damage = 6,
  lava_damage = 10,
  light_damage = 0,
  fear_height = 4,
  animation = {
    speed_normal = 25,
    speed_run = 50,
    stand_start = 20,
    stand_end = 40,
    walk_start = 0,
    walk_end = 20,
    run_start = 0,
    run_end = 20,
    die_start = 40,
    die_end = 50,
    die_loop = false,
  },
  on_rightclick = function(self, clicker)
        -- feed to heal npc
        if mobs:feed_tame(self, clicker, 8, true, true) then
            return
        end

        -- capture npc with net or lasso
        if mobs:capture_mob(self, clicker, 0, 5, 80, false, nil) then
            return
        end

        -- protect npc with mobs:protector
        if mobs:protect(self, clicker) then
            return
        end

        local item = clicker:get_wielded_item()
        local name = clicker:get_player_name()

        -- right clicking with gold lump drops random item from mobs.npc_drops
        if item:get_name() == 'default:gold_lump' then

            if not mobs.is_creative(name) then
                item:take_item()
                clicker:set_wielded_item(item)
            end

            local pos = self.object:get_pos()

            pos.y = pos.y + 0.5

            -- add item if it exists
            local obj = minetest.add_item(pos, {
                name = mobs.npc_drops[math.random(1, #mobs.npc_drops)]
            })

            if obj and obj:get_luaentity() then
                obj:set_velocity({
                    x = math.random(-10, 10) / 9,
                    y = 6,
                    z = math.random(-10, 10) / 9,
                })
            elseif obj then
                obj:remove() -- item does not exist
            end

            minetest.chat_send_player(name, S('Snow Golem dropped you an item for gold!'))

            return
        end

        -- by right-clicking owner can switch npc between follow and stand
        if self.owner and self.owner == name then

            if self.order == 'follow' then
                self.order = 'stand'

                minetest.chat_send_player(name, S('NPC stands still.'))
            else
                self.order = 'follow'

                minetest.chat_send_player(name, S('NPC will follow you.'))
            end
        end
    end,
}

mobs:register_mob(':mobs_npc:snow_golem', snow_golem_def)

-- mobs:spawn({
--     name = 'mobs_npc:snow_golem',
--     nodes = {
--         'default:desert_sand',
--         'default:desert_stone',
--         'default:sand',
--         'default:sandstone',
--         'default:silver_sand',
--         'mobs_npc:deco_stone_eye',
--         'mobs_npc:deco_stone_men',
--         'mobs_npc:deco_stone_sun'
--     },
--     min_light = 0,
--     max_light = 20,
--     chance = 2000,
--     active_object_count = 2,
--     day_toggle = false,
-- })

mobs:register_egg(':mobs_npc:snow_golem', 'Snow Golem', 'default_snow.png', 1)

-- shooting
mobs:register_arrow(':mobs_npc:snowball_arrow', {
  visual = 'sprite',
  visual_size = { x = 1, y = 1 },
  textures = { 'default_snowball.png' },
  velocity = 14,
  tail = 0,
  tail_texture = 'default_snowball.png',
  glow = 5,
  -- tail_size = 10,

  -- direct hit, no fire... just plenty of pain
  hit_player = function(self, player)
        player:punch(self.object, 1.0, {
        full_punch_interval = 1.0,
        damage_groups = { fleshy = 8 },
        }, nil)
  end,

    hit_mob = function(self, player)
        player:punch(self.object, 1.0, {
            full_punch_interval = 1.0,
            damage_groups = { fleshy = 8 },
        }, nil)
    end,

    hit_node = function(self, pos, node)
    end
})
