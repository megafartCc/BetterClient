function script.draw_combo_runtime_switch()
    if not Render.ScreenSize then
        return
    end
    local screen = Render.ScreenSize()
    local w, h = C.HUD_COMBO_W, C.HUD_COMBO_H
    local x = screen.x * 0.5 - w * 0.5
    local y = screen.y - C.HUD_COMBO_Y_OFFSET
    local split_x = x + w * 0.5
    local hover_left = safe_call(Input.IsCursorInRect, x, y, w * 0.5, h) == true
    local hover_right = safe_call(Input.IsCursorInRect, split_x, y, w * 0.5, h) == true
    local mouse1 = get_mouse1_code()
    local click_once = mouse1 and safe_call(Input.IsKeyDownOnce, mouse1) == true
    local input_captured = safe_call(Input.IsInputCaptured) == true
    if click_once and not input_captured then
        if hover_left then
            combo_runtime_enabled = false
        elseif hover_right then
            combo_runtime_enabled = true
        end
    end
    local bg = Color(0, 0, 0, 170)
    local on_color = combo_runtime_enabled and Color(90, 190, 120, 235) or Color(55, 65, 55, 220)
    local off_color = combo_runtime_enabled and Color(70, 55, 55, 220) or Color(200, 90, 90, 235)
    if Render.FilledRect then
        Render.FilledRect(Vec2(x, y), Vec2(x + w, y + h), bg, 4, Enum.DrawFlags.RoundCornersAll)
        Render.FilledRect(Vec2(x, y), Vec2(split_x, y + h), off_color, 4, Enum.DrawFlags.RoundCornersLeft)
        Render.FilledRect(Vec2(split_x, y), Vec2(x + w, y + h), on_color, 4, Enum.DrawFlags.RoundCornersRight)
    end
    if Render.Rect then
        Render.Rect(Vec2(x, y), Vec2(x + w, y + h), Color(20, 20, 20, 255), 4, Enum.DrawFlags.RoundCornersAll, 1.0)
    end
    local title = C.HUD_COMBO_TITLE
    local title_size = Render.TextSize(font, tactical_font_size, title)
    Render.Text(font, tactical_font_size, title, Vec2(x + w * 0.5 - title_size.x * 0.5, y - title_size.y - 2), Color(220, 220, 220, 235))
    local off_size = Render.TextSize(font, tactical_font_size, C.HUD_COMBO_TEXT_OFF)
    local on_size = Render.TextSize(font, tactical_font_size, C.HUD_COMBO_TEXT_ON)
    Render.Text(font, tactical_font_size, C.HUD_COMBO_TEXT_OFF, Vec2(x + w * 0.25 - off_size.x * 0.5, y + h * 0.5 - off_size.y * 0.5), Color(255, 245, 245, 240))
    Render.Text(font, tactical_font_size, C.HUD_COMBO_TEXT_ON, Vec2(split_x + w * 0.25 - on_size.x * 0.5, y + h * 0.5 - on_size.y * 0.5), Color(245, 255, 245, 240))
end
local function get_combo_target_under_cursor(anchor_meepo)
    local cursor_x, cursor_y = get_cursor_position()
    local fov_radius = get_combo_target_fov_radius()
    if not anchor_meepo then
        return nil, cursor_x, cursor_y, fov_radius
    end
    local local_team = tonumber(safe_call(Entity.GetTeamNum, anchor_meepo) or -1) or -1
    if local_team < 0 or not cursor_x or not cursor_y then
        return nil, cursor_x, cursor_y, fov_radius
    end
    local heroes = Heroes.GetAll()
    if not heroes then
        return nil, cursor_x, cursor_y, fov_radius
    end
    local best_target = nil
    local best_dist_sq = nil
    local fov_sq = fov_radius * fov_radius
    for i = 1, #heroes do
        local enemy = heroes[i]
        if enemy and enemy ~= anchor_meepo and Entity.IsHero(enemy) and Entity.IsAlive(enemy) then
            local enemy_team = tonumber(safe_call(Entity.GetTeamNum, enemy) or -1) or -1
            if enemy_team >= 0 and enemy_team ~= local_team and safe_call(Entity.IsDormant, enemy) ~= true then
                local pos = safe_call(Entity.GetAbsOrigin, enemy)
                if pos then
                    pos = pos + Vector(0, 0, (safe_call(NPC.GetHealthBarOffset, enemy) or 0) + 8)
                    local screen_pos, visible = Render.WorldToScreen(pos)
                    if visible and screen_pos then
                        local dx = (screen_pos.x or 0) - cursor_x
                        local dy = (screen_pos.y or 0) - cursor_y
                        local dist_sq = dx * dx + dy * dy
                        if dist_sq <= fov_sq and (not best_dist_sq or dist_sq < best_dist_sq) then
                            best_dist_sq = dist_sq
                            best_target = enemy
                        end
                    end
                end
            end
        end
    end
    return best_target, cursor_x, cursor_y, fov_radius
end
function script.handle_poof_utilities(local_player, local_hero, meepos, now)
    local cursor_pressed = script.is_bind_just_pressed(ui.poof_to_cursor, "poof_to_cursor")
    local self_pressed = script.is_bind_just_pressed(ui.poof_on_self, "poof_on_self")
    if safe_call(Input.IsInputCaptured) == true then
        return false
    end
    local issued = false
    if cursor_pressed then
        issued = script.try_poof_to_cursor(local_player, local_hero, meepos, now) or issued
    end
    if self_pressed then
        issued = script.try_poof_on_self(local_player, local_hero, meepos, now) or issued
    end
    return issued
end
function script.run_combo_logic(local_hero, meepos, now)
    local combo_active = is_combo_active()
    local local_player = safe_call(Players.GetLocal)
    local now = get_game_time()
    if not combo_active then
        local units_for_armlet = nil
        if script._combo_armlet_forced_on then
            units_for_armlet = collect_owned_meepo_units(local_hero, meepos)
            if #units_for_armlet > 0 then
                script.try_combo_armlet_control(units_for_armlet, false, now)
            end
        end
        if combo_was_active then
            local units_to_interrupt = units_for_armlet or collect_owned_meepo_units(local_hero, meepos)
            if #units_to_interrupt > 0 then
                interrupt_combo_casts(local_player, units_to_interrupt)
            end
        end
        combo_was_active = false
        combo_focus_target = nil
        combo_focus_source = nil
        script._combo_target_last_seen_time = -9999
        reset_combo_move_state()
        return
    end
    combo_was_active = true
    local source_meepo = get_combo_anchor_meepo(local_player, local_hero)
    combo_focus_source = source_meepo
    if not source_meepo then
        combo_focus_target = nil
        return
    end
    local units = collect_combo_move_units(local_player, local_hero, meepos)
    local net_units = collect_owned_meepo_units(local_hero, meepos)
    local function ensure_unit(list, unit)
        if not list or not unit then
            return
        end
        for i = 1, #list do
            if list[i] == unit then
                return
            end
        end
        list[#list + 1] = unit
    end
    if #units == 0 then
        return
    end
    if #net_units == 0 then
        net_units = units
    end
    if script.try_combo_armlet_control(net_units, true, now) then
        script.set_combo_debug_state("ARMLET", "armlet on", "")
        return
    end
    local hovered_target = select(1, get_combo_target_under_cursor(source_meepo))
    if hovered_target and Entity.IsAlive(hovered_target) then
        combo_focus_target = hovered_target
        script._combo_target_last_seen_time = now
    elseif combo_focus_target and Entity.IsAlive(combo_focus_target) then
        local keep_current = false
        if (script._combo_blink_scheduled_time or 0) > now then
            keep_current = true
        elseif (now - (script._combo_target_last_seen_time or -9999)) <= 0.30 then
            keep_current = true
        end
        if not keep_current then
            combo_focus_target = nil
        end
    else
        combo_focus_target = nil
    end
    if combo_focus_target and Entity.IsAlive(combo_focus_target) then
        local blink_anchor = get_main_meepo(local_hero)
        if blink_anchor and Entity.IsAlive(blink_anchor) then
            local blink = get_blink_item(blink_anchor)
            if script.can_cast_blink_now(blink_anchor, blink) then
                ensure_unit(units, blink_anchor)
            end
        end
    end
    local current_target_key = combo_focus_target and get_entity_key(combo_focus_target) or nil
    if current_target_key ~= combo_focus_target_key then
        script.clear_blink_schedule()
        script.clear_preblink_poof_state()
        if clear_poof_queue then
            clear_poof_queue()
        end
        script._combo_net_priority_until = 0
        script._combo_net_priority_target_key = nil
        combo_focus_target_key = current_target_key
    end
    if not combo_focus_target or not Entity.IsAlive(combo_focus_target) then
        script.set_combo_debug_state("SEARCHING", "no target", "")
        if now < (script._combo_search_next_move_time or 0) then
            return
        end
        local destination = safe_call(Input.GetWorldCursorPos)
        if destination then
            local last_search_pos = script._combo_search_last_position
            if last_search_pos then
                local search_delta = vec_dist_2d(last_search_pos, destination) or 0
                if search_delta < 24 then
                    return
                end
            end
            if issue_combo_move_order(local_player, units, destination, now) then
                script._combo_search_next_move_time = now + 0.22
                script._combo_search_last_position = Vector(destination.x or 0, destination.y or 0, destination.z or 0)
            end
        end
        return
    end
    script._combo_search_next_move_time = 0
    script._combo_search_last_position = nil
    if combo_focus_target and Entity.IsAlive(combo_focus_target)
        and not (has_pending_poof_queue and has_pending_poof_queue())
        and not script.should_combo_surprise_hold(local_hero, combo_focus_target, now) then
        local anchor = get_main_meepo(local_hero)
        if anchor and Entity.IsAlive(anchor) then
            local clones = collect_owned_meepo_units(local_hero, meepos)
            local moving = {}
            local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
            local move_anchor_for_blink = false
            local clone_frontliner_in_poof_range = false
            local anchor_should_walk_to_clone = false
            if target_pos then
                local blink = get_blink_item(anchor)
                if script.can_cast_blink_now(anchor, blink) then
                    local anchor_pos = safe_call(Entity.GetAbsOrigin, anchor)
                    if anchor_pos then
                        local blink_range = script.get_item_cast_range(blink, 1200)
                        local blink_bonus = tonumber(safe_call(NPC.GetCastRangeBonus, anchor) or 0) or 0
                        if blink_bonus > 0 then
                            blink_range = blink_range + blink_bonus
                        end
                        if blink_range <= 0 then
                            blink_range = 1200
                        end
                        local dist = vec_dist_2d(anchor_pos, target_pos) or 0
                        if dist > (blink_range + 80) then
                            move_anchor_for_blink = true
                        end
                    end
                end
                if not move_anchor_for_blink then
                    local poof_frontline_radius = get_allowed_poof_anchor_distance(C.COMBO_POOF_DAMAGE_RADIUS_FALLBACK)
                    local target_hull = tonumber(safe_call(NPC.GetHullRadius, combo_focus_target) or 0) or 0
                    local anchor_can_attack_now = can_meepo_attack_target_now(anchor, combo_focus_target, target_pos, target_hull)
                    local anchor_poof_ready = can_schedule_poof(anchor, now)
                    for i = 1, #clones do
                        local meepo = clones[i]
                        if meepo and meepo ~= anchor and Entity.IsAlive(meepo) then
                            local clone_pos = safe_call(Entity.GetAbsOrigin, meepo)
                            local clone_dist = vec_dist_2d(clone_pos, target_pos)
                            if clone_dist and clone_dist <= poof_frontline_radius then
                                clone_frontliner_in_poof_range = true
                                break
                            end
                        end
                    end
                    if clone_frontliner_in_poof_range
                        and not anchor_can_attack_now
                        and not anchor_poof_ready
                        and not is_combo_cast_in_progress(anchor) then
                        anchor_should_walk_to_clone = true
                    end
                end
            end
            if move_anchor_for_blink then
                ensure_unit(moving, anchor)
            else
                for i = 1, #clones do
                    local meepo = clones[i]
                    if meepo and meepo ~= anchor then
                        moving[#moving + 1] = meepo
                    end
                end
                if anchor_should_walk_to_clone then
                    ensure_unit(moving, anchor)
                end
            end
            if #moving > 0 and not is_poof_in_progress(moving) then
                if target_pos then
                    issue_combo_move_order(local_player, moving, target_pos, now)
                end
            end
        end
    end
    local main_preferred = script.is_combo_option_enabled(ui.combo_main_first) and get_main_meepo(local_hero) or nil
    local strict_control = script.is_combo_option_enabled(ui.combo_strict_control)
    local net_enabled = is_combo_spell_enabled("net", ui.combo_use_net)
    local has_abyssal_item = has_combo_item_equipped(net_units, script._combo_item_sets.abyssal)
    local hex_ready_anywhere = has_ready_hex_for_combo(net_units) and not script.get_control_break_reason(combo_focus_target, true)
    local abyssal_remaining = script.get_target_abyssal_remaining(combo_focus_target, now)
    local hex_remaining = script.get_target_hex_remaining(combo_focus_target, now)
    local abyssal_ready = has_abyssal_item
        and script.has_ready_abyssal_for_combo
        and script.has_ready_abyssal_for_combo(net_units, combo_focus_target, now)
    local hex_ready = script.can_cast_combo_hex_now and script.can_cast_combo_hex_now(net_units, combo_focus_target, now)
    local net_chain_now = net_enabled and script.can_cast_net_chain_now(net_units, combo_focus_target, now) or false
    local net_in_flight = net_enabled and is_net_projectile_in_flight(combo_focus_target, now) or false
    local combo_phase = script.resolve_combo_state_phase(
        current_target_key,
        has_abyssal_item,
        abyssal_ready,
        abyssal_remaining,
        hex_ready_anywhere,
        hex_remaining,
        net_enabled,
        net_chain_now or net_in_flight,
        now
    )
    local next_disable_delay, next_disable_source = script.get_next_disable_ready_delay(local_hero, net_units, now)
    local next_disable_text = ""
    if next_disable_delay then
        next_disable_text = string.format("%s %.2f", tostring(next_disable_source or "disable"), next_disable_delay)
    end
    script.set_combo_debug_state(combo_phase, "active", next_disable_text)
    if is_combo_action_locked(now) then
        return
    end
    local linken_break_reason = nil
    if script.is_target_linkens_protected(combo_focus_target) then
        local linken_broken, linken_reason = script.try_combo_linken_break(net_units, combo_focus_target, now)
        if linken_broken then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "break linken: " .. tostring(linken_reason or "item"), next_disable_text)
            return
        end
        linken_break_reason = linken_reason
        if linken_reason == "lotus" then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "linken hold: lotus", next_disable_text)
        elseif linken_reason == "no_enabled_breaker" then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "linken up: no breaker", next_disable_text)
        elseif linken_reason == "disabled_breaker" then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "linken hold: breaker disabled", next_disable_text)
        end
    end
    local single_target_break = script.get_control_break_reason(combo_focus_target, true)
    if single_target_break and (combo_phase == script.COMBO_PHASE_ABYSSAL or combo_phase == script.COMBO_PHASE_HEX) then
        script.set_combo_debug_state(combo_phase, "control break: " .. tostring(single_target_break), next_disable_text)
    end
    local allow_target_items = linken_break_reason ~= "no_enabled_breaker" and linken_break_reason ~= "disabled_breaker"
    local has_any_items_equipped = has_any_combo_items_equipped(local_hero, net_units)
    if has_any_items_equipped and (not single_target_break or single_target_break == "linkens") then
        local pre_item_casted, pre_item_name = false, nil
        if allow_target_items then
            pre_item_casted, pre_item_name = script.try_combo_diffusal_disperser(net_units, combo_focus_target, now)
            if pre_item_casted then
                script.set_combo_debug_state(combo_phase, "item-first: " .. tostring(pre_item_name or "diffusal"), next_disable_text)
                return
            end
            pre_item_casted, pre_item_name = script.try_combo_silence(net_units, combo_focus_target, now)
            if pre_item_casted then
                script.set_combo_debug_state(combo_phase, "item-first: " .. tostring(pre_item_name or "silence"), next_disable_text)
                return
            end
            pre_item_casted, pre_item_name = script.try_combo_atos(net_units, combo_focus_target, now)
            if pre_item_casted then
                script.set_combo_debug_state(combo_phase, "item-first: " .. tostring(pre_item_name or "atos"), next_disable_text)
                return
            end
            pre_item_casted, pre_item_name = script.try_combo_grenade(net_units, combo_focus_target, now)
            if pre_item_casted then
                script.set_combo_debug_state(combo_phase, "item-first: " .. tostring(pre_item_name or "grenade"), next_disable_text)
                return
            end
        end
    end
    if has_any_items_equipped and script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
        script.set_combo_debug_state(combo_phase, "blink engage (items first)", next_disable_text)
        return
    end
    if has_any_items_equipped and (not single_target_break or single_target_break == "linkens") then
        local pre_item_casted, pre_item_name = false, nil
        pre_item_casted, pre_item_name = script.try_combo_phase_shadow_engage(net_units, combo_focus_target, now)
        if pre_item_casted then
            script.set_combo_debug_state(combo_phase, "item-first: " .. tostring(pre_item_name or "phase/shadow"), next_disable_text)
            return
        end
        pre_item_casted, pre_item_name = script.try_combo_manta_after_net(net_units, combo_focus_target, now)
        if pre_item_casted then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "item-first: " .. tostring(pre_item_name or "manta"), next_disable_text)
            return
        end
        pre_item_casted, pre_item_name = script.try_combo_mjollnir_self(net_units, combo_focus_target, now)
        if pre_item_casted then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "item-first: " .. tostring(pre_item_name or "mjollnir"), next_disable_text)
            return
        end
        pre_item_casted, pre_item_name = script.try_combo_blademail_close(net_units, combo_focus_target, now)
        if pre_item_casted then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "item-first: " .. tostring(pre_item_name or "blademail"), next_disable_text)
            return
        end
    end
    if combo_phase == script.COMBO_PHASE_ABYSSAL and abyssal_ready then
        if script.try_combo_abyssal(net_units, combo_focus_target, now) then
            script.set_combo_debug_state(combo_phase, "cast abyssal", next_disable_text)
            return
        end
        if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
            script.set_combo_debug_state(combo_phase, "blink for abyssal", next_disable_text)
            return
        end
        script.set_combo_debug_state(combo_phase, "waiting abyssal", next_disable_text)
        if can_any_meepo_attack_target_now(net_units, combo_focus_target) then
            issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
        end
        return
    end
    if combo_phase == script.COMBO_PHASE_ABYSSAL and has_abyssal_item and abyssal_remaining > 0.08 then
        local main_net_ready = is_meepo_net_ready_for_combo(main_preferred, now)
        local any_net_ready = has_any_meepo_net_ready_for_combo(net_units, now)
        if hex_ready_anywhere then
            if abyssal_remaining > C.COMBO_HEX_CHAIN_FROM_ABYSSAL_WINDOW then
                script.set_combo_debug_state(combo_phase, "wait abyssal->hex window", next_disable_text)
                return
            end
            if hex_ready then
                if try_combo_hex(net_units, combo_focus_target, now) then
                    script.set_combo_debug_state(combo_phase, "chain hex", next_disable_text)
                    return
                end
                if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
                    script.set_combo_debug_state(combo_phase, "blink for hex", next_disable_text)
                    return
                end
                script.set_combo_debug_state(combo_phase, "hex failed", next_disable_text)
                local attacked = issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
                if not attacked then
                    local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
                    if target_pos then
                        issue_combo_move_order(local_player, units, target_pos, now)
                    end
                end
                return
            end
        end
        if net_enabled then
            if try_combo_earthbind_chain(net_units, combo_focus_target, now, main_preferred) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "chain net (main)", next_disable_text)
                return
            end
            if try_combo_earthbind_chain(net_units, combo_focus_target, now) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "chain net", next_disable_text)
                return
            end
            if main_net_ready or any_net_ready then
                if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
                    script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "blink for net", next_disable_text)
                    return
                end
            end
        end
        script.set_combo_debug_state(combo_phase, "wait control handoff", next_disable_text)
        if can_any_meepo_attack_target_now(net_units, combo_focus_target) then
            issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
        end
        return
    end
    if combo_phase == script.COMBO_PHASE_HEX and hex_ready then
        if try_combo_hex(net_units, combo_focus_target, now) then
            script.set_combo_debug_state(combo_phase, "cast hex", next_disable_text)
            return
        end
        if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
            script.set_combo_debug_state(combo_phase, "blink for hex", next_disable_text)
            return
        end
        script.set_combo_debug_state(combo_phase, "hex pending", next_disable_text)
        local attacked = issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
        if not attacked then
            local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
            if target_pos then
                issue_combo_move_order(local_player, units, target_pos, now)
            end
        end
        return
    end
    if combo_phase == script.COMBO_PHASE_HEX and hex_remaining > C.COMBO_HEX_TO_CONTROL_CHAIN_WINDOW then
        script.set_combo_debug_state(combo_phase, "wait hex chain window", next_disable_text)
        if can_any_meepo_attack_target_now(net_units, combo_focus_target) then
            issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
        end
        return
    end
    if hex_remaining > 0 and hex_remaining <= C.COMBO_HEX_TO_CONTROL_CHAIN_WINDOW then
        local main_net_ready = is_meepo_net_ready_for_combo(main_preferred, now)
        local any_net_ready = has_any_meepo_net_ready_for_combo(net_units, now)
        if net_enabled then
            local _, _, arrival = choose_earthbind_caster(net_units, combo_focus_target, now, main_preferred)
            if not arrival then
                local _, _, fallback_arrival = choose_earthbind_caster(net_units, combo_focus_target, now)
                arrival = fallback_arrival
            end
            if arrival then
                local time_to_land = math.max(0, arrival - now)
            end
            if try_combo_earthbind_chain(net_units, combo_focus_target, now, main_preferred) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "chain net after hex (main)", next_disable_text)
                return
            end
            if try_combo_earthbind_chain(net_units, combo_focus_target, now) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "chain net after hex", next_disable_text)
                return
            end
            if main_net_ready then
                if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
                    script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "blink for main net", next_disable_text)
                    return
                end
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "hold main net", next_disable_text)
                return
            end
        end
        if net_enabled and any_net_ready then
            if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "blink for net", next_disable_text)
                return
            end
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "wait net ready", next_disable_text)
            return
        end
        if strict_control then
            local can_chain_now = false
            if script.has_ready_abyssal_for_combo and script.has_ready_abyssal_for_combo(net_units, combo_focus_target, now) then
                can_chain_now = true
            end
            if script.can_cast_combo_hex_now and script.can_cast_combo_hex_now(net_units, combo_focus_target, now) then
                can_chain_now = true
            end
            if can_chain_now then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "hex-end poof blocked (strict)", next_disable_text)
                return
            end
            local hold_window = script.get_combo_hold_window_sec()
            local confirmed_control_now = get_confirmed_control_remaining(combo_focus_target, now)
            if next_disable_delay and next_disable_delay > 0 and next_disable_delay <= hold_window then
                if confirmed_control_now > C.COMBO_CONTROL_HOLD_MIN_REMAINING then
                    script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "hex-end hold for disable", next_disable_text)
                    if script.issue_combo_hold_order(local_player, units, now, "meepo_combo_hold_hex_end", combo_focus_target) then
                        return
                    end
                    return
                end
            end
        end
        if try_combo_poof_burst_hex_fallback(net_units, combo_focus_target, now) then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "poof fallback after hex", next_disable_text)
            return
        end
        script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "net skipped; no poof fallback", next_disable_text)
        return
    end
    if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
        script.set_combo_debug_state(combo_phase, "blink engage", next_disable_text)
        return
    end
    if script.try_combo_silence(net_units, combo_focus_target, now) then
        script.set_combo_debug_state(combo_phase, "cast silence", next_disable_text)
        return
    end
    if script.try_combo_atos(net_units, combo_focus_target, now) then
        script.set_combo_debug_state(combo_phase, "cast atos", next_disable_text)
        return
    end
    if try_combo_earthbind_chain(net_units, combo_focus_target, now, main_preferred) then
        script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "cast net", next_disable_text)
        return
    end
    local items_still_ready = false
    if script.has_ready_abyssal_for_combo and script.has_ready_abyssal_for_combo(net_units, combo_focus_target, now) then
        items_still_ready = true
    end
    if script.can_cast_combo_hex_now and script.can_cast_combo_hex_now(net_units, combo_focus_target, now) then
        items_still_ready = true
    end
    if items_still_ready then
        script.set_combo_debug_state(combo_phase, "wait ready item disable", next_disable_text)
        if can_any_meepo_attack_target_now(net_units, combo_focus_target) then
            issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
        end
        return
    end
    if strict_control then
        local break_reason = script.get_control_break_reason(combo_focus_target, false)
        if not break_reason then
            local can_chain_now = false
            if net_enabled and script.can_cast_net_chain_now(net_units, combo_focus_target, now) then
                can_chain_now = true
            end
            if script.can_cast_combo_hex_now and script.can_cast_combo_hex_now(net_units, combo_focus_target, now) then
                can_chain_now = true
            end
            if script.has_ready_abyssal_for_combo and script.has_ready_abyssal_for_combo(net_units, combo_focus_target, now) then
                can_chain_now = true
            end
            if can_chain_now then
                script.set_combo_debug_state(combo_phase, "poof blocked (strict control)", next_disable_text)
                return
            end
            local hold_window = script.get_combo_hold_window_sec()
            local confirmed_control_now = get_confirmed_control_remaining(combo_focus_target, now)
            if next_disable_delay and next_disable_delay > 0 and next_disable_delay <= hold_window then
                if confirmed_control_now > C.COMBO_CONTROL_HOLD_MIN_REMAINING then
                    script.set_combo_debug_state(combo_phase, "holding for next disable", next_disable_text)
                    if script.issue_combo_hold_order(local_player, units, now, "meepo_combo_hold_next_disable", combo_focus_target) then
                        return
                    end
                    return
                end
            end
        else
            script.set_combo_debug_state(combo_phase, "control break: " .. tostring(break_reason), next_disable_text)
        end
    end
    local net_chain_now = net_enabled and script.can_cast_net_chain_now(net_units, combo_focus_target, now) or false
    local any_net_ready_now = net_enabled and has_any_meepo_net_ready_for_combo(net_units, now) or false
    local next_net_delay = net_enabled and script.get_next_net_ready_delay(net_units, now) or nil
    local net_hold_window = script.get_combo_hold_window_sec()
    local control_break_for_net = script.get_control_break_reason(combo_focus_target, false)
    local hold_net_orders_allowed = true
    if linken_break_reason == "no_enabled_breaker" then
        hold_net_orders_allowed = false
    end
    if (script._combo_blink_scheduled_time or 0) > now then
        hold_net_orders_allowed = false
    end
    if is_poof_in_progress(net_units) then
        hold_net_orders_allowed = false
    end
    local prioritize_net_over_poof = false
    local net_priority_lock_active = false
    local net_priority_reason = nil
    if net_enabled and not control_break_for_net and current_target_key ~= nil then
        local lock_until = tonumber(script._combo_net_priority_until or 0) or 0
        if script._combo_net_priority_target_key == current_target_key and lock_until > now then
            net_priority_lock_active = true
            prioritize_net_over_poof = true
            net_priority_reason = "lock"
        end
    end
    if net_enabled and not control_break_for_net then
        if net_chain_now then
            prioritize_net_over_poof = true
            net_priority_reason = net_priority_reason or "chain_now"
        elseif any_net_ready_now then
            local remaining_control = get_effective_earthbind_remaining(combo_focus_target, now)
            local _, _, priority_arrival = choose_earthbind_caster(net_units, combo_focus_target, now, main_preferred)
            if not priority_arrival then
                local _, _, fallback_arrival = choose_earthbind_caster(net_units, combo_focus_target, now)
                priority_arrival = fallback_arrival
            end
            local handoff_window = (priority_arrival and math.max(0, priority_arrival - now) or 0) + C.COMBO_NET_CHAIN_BUFFER + C.COMBO_NET_HANDOFF_EXTRA
            if priority_arrival and remaining_control > 0 and remaining_control <= (handoff_window + C.COMBO_POOF_ROOT_MIN_REMAINING) then
                prioritize_net_over_poof = true
                net_priority_reason = net_priority_reason or "handoff"
                if hold_net_orders_allowed and remaining_control > 0 then
                    script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "hold net handoff", next_disable_text)
                    if script.issue_combo_hold_order(local_player, units, now, "meepo_combo_hold_net_handoff", combo_focus_target) then
                        return
                    end
                    return
                end
            end
        elseif hold_net_orders_allowed and next_net_delay and next_net_delay > 0 and next_net_delay <= net_hold_window then
            local confirmed_control_now = get_confirmed_control_remaining(combo_focus_target, now)
            if confirmed_control_now <= C.COMBO_CONTROL_HOLD_MIN_REMAINING then
                hold_net_orders_allowed = false
            end
        end
        if hold_net_orders_allowed and next_net_delay and next_net_delay > 0 and next_net_delay <= net_hold_window then
            prioritize_net_over_poof = true
            net_priority_reason = net_priority_reason or "delay_window"
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "hold net priority", next_disable_text)
            if script.issue_combo_hold_order(local_player, units, now, "meepo_combo_hold_net_priority", combo_focus_target) then
                return
            end
            return
        end
    end
    if net_enabled and not control_break_for_net and prioritize_net_over_poof then
        script._combo_net_priority_target_key = current_target_key
        local lock_until = now + 0.35
        if lock_until > (tonumber(script._combo_net_priority_until or 0) or 0) then
            script._combo_net_priority_until = lock_until
        end
    elseif (not net_enabled) or control_break_for_net or (script._combo_net_priority_target_key ~= current_target_key) then
        script._combo_net_priority_until = 0
        script._combo_net_priority_target_key = nil
    elseif not net_priority_lock_active and (tonumber(script._combo_net_priority_until or 0) or 0) <= now then
        script._combo_net_priority_until = 0
        script._combo_net_priority_target_key = nil
    end
    if not prioritize_net_over_poof then
        local no_net_available_now = (not net_enabled) or (not any_net_ready_now)
        if no_net_available_now and is_combo_spell_enabled("poof", ui.combo_use_poof) then
            local can_control_now = false
            if net_enabled and net_chain_now then
                can_control_now = true
            end
            if script.can_cast_combo_hex_now and script.can_cast_combo_hex_now(net_units, combo_focus_target, now) then
                can_control_now = true
            end
            if script.has_ready_abyssal_for_combo and script.has_ready_abyssal_for_combo(net_units, combo_focus_target, now) then
                can_control_now = true
            end
            if not can_control_now and try_combo_poof_burst_uncontrolled(net_units, combo_focus_target, now, "meepo_combo_poof_no_net") then
                script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "poof priority (no net)", next_disable_text)
                return
            end
        end
    else
        local priority_reason = "control priority net>poof"
        if net_priority_reason == "lock" or net_priority_lock_active then
            priority_reason = "control priority net>poof (lock)"
        elseif net_priority_reason == "chain_now" then
            priority_reason = "control priority net>poof (chain)"
        elseif net_priority_reason == "handoff" then
            priority_reason = "control priority net>poof (handoff)"
        elseif net_priority_reason == "delay_window" then
            priority_reason = "control priority net>poof (delay)"
        end
        script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, priority_reason, next_disable_text)
    end
    local combat_item_casted, combat_item_name = script.try_combo_manta_after_net(net_units, combo_focus_target, now)
    if combat_item_casted then
        script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "combat item: " .. tostring(combat_item_name or "manta"), next_disable_text)
        return
    end
    combat_item_casted, combat_item_name = script.try_combo_mjollnir_self(net_units, combo_focus_target, now)
    if combat_item_casted then
        script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "combat item: " .. tostring(combat_item_name or "mjollnir"), next_disable_text)
        return
    end
    combat_item_casted, combat_item_name = script.try_combo_blademail_close(net_units, combo_focus_target, now)
    if combat_item_casted then
        script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "combat item: " .. tostring(combat_item_name or "blademail"), next_disable_text)
        return
    end
    if not prioritize_net_over_poof then
        if try_combo_poof_burst(net_units, combo_focus_target, now) then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "poof allowed", next_disable_text)
            return
        end
    end
    if prioritize_net_over_poof then
        if net_chain_now then
            if try_combo_earthbind_chain(net_units, combo_focus_target, now, main_preferred) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "force chain net (main)", next_disable_text)
                return
            end
            if try_combo_earthbind_chain(net_units, combo_focus_target, now) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "force chain net", next_disable_text)
                return
            end
        end
        local remaining_control_now = get_effective_earthbind_remaining(combo_focus_target, now)
        if remaining_control_now > 0 and hold_net_orders_allowed then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "holding net priority", next_disable_text)
            if script.issue_combo_hold_order(local_player, units, now, "meepo_combo_hold_force_net", combo_focus_target) then
                return
            end
            return
        end
        script._combo_net_priority_until = 0
        script._combo_net_priority_target_key = nil
        local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
        if target_pos then
            issue_combo_move_order(local_player, units, target_pos, now)
        end
        script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "reposition for net", next_disable_text)
        if can_any_meepo_attack_target_now(net_units, combo_focus_target) then
            issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
            return
        end
        return
    end
    if has_pending_poof_queue and has_pending_poof_queue() then
        return
    end
    if is_poof_in_progress(net_units) then
        return
    end
    if combo_focus_target and Entity.IsAlive(combo_focus_target) then
        local net_enabled = is_combo_spell_enabled("net", ui.combo_use_net)
        local poof_enabled = is_combo_spell_enabled("poof", ui.combo_use_poof)
        local net_ready_now = net_enabled and script.can_cast_net_chain_now(net_units, combo_focus_target, now) or false
        local net_in_flight = net_enabled and is_net_projectile_in_flight(combo_focus_target, now) or false
        local no_net_available_now = (not net_enabled) or (not has_any_meepo_net_ready_for_combo(net_units, now))
        local poof_ready_now = false
        if poof_enabled then
            if no_net_available_now then
                poof_ready_now = can_cast_poof_burst_uncontrolled_now(net_units, combo_focus_target, now)
            else
                poof_ready_now = can_cast_poof_burst_now(net_units, combo_focus_target, now)
            end
        end
        local can_attack_now = can_any_meepo_attack_target_now(net_units, combo_focus_target)
        if (not prioritize_net_over_poof) and poof_ready_now then
            local poof_casted = false
            if no_net_available_now then
                poof_casted = try_combo_poof_burst_uncontrolled(net_units, combo_focus_target, now, "meepo_combo_poof_over_attack")
            else
                poof_casted = try_combo_poof_burst(net_units, combo_focus_target, now)
            end
            if poof_casted then
                script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "poof over attack", next_disable_text)
                return
            end
        end
        if net_in_flight then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "wait net impact", next_disable_text)
            if script.issue_combo_hold_order(local_player, units, now, "meepo_combo_hold_net_impact", combo_focus_target) then
                return
            end
            return
        end
        if (not prioritize_net_over_poof) and (not net_ready_now and not poof_ready_now) and can_attack_now then
            local mom_casted, mom_name = script.try_combo_mom_finish(net_units, combo_focus_target, now)
            if mom_casted then
                script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "finish item: " .. tostring(mom_name or "mom"), next_disable_text)
                return
            end
        end
        if can_attack_now or ((not prioritize_net_over_poof) and (not net_ready_now and not poof_ready_now)) then
            local fallback_reason = prioritize_net_over_poof and "attack pressure" or "attack fallback"
            local attacked = issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
            if attacked then
                script.set_combo_debug_state(combo_phase, fallback_reason, next_disable_text)
            end
            return
        end
    end
    if combo_focus_target and Entity.IsAlive(combo_focus_target)
        and script.should_combo_surprise_hold(local_hero, combo_focus_target, now) then
        script.set_combo_debug_state(combo_phase, "hold surprise", next_disable_text)
        if script.issue_combo_hold_order(local_player, units, now, "meepo_combo_surprise_hold") then
            return
        end
        return
    end
    if now < combo_move_next_order_time then
        return
    end
    local destination = nil
    if combo_focus_target and Entity.IsAlive(combo_focus_target) then
        destination = safe_call(Entity.GetAbsOrigin, combo_focus_target)
    end
    if not destination then
        destination = safe_call(Input.GetWorldCursorPos)
    end
    if not destination then
        return
    end
    local move_units = units
    if combo_focus_target and Entity.IsAlive(combo_focus_target) then
        local anchor = get_main_meepo(local_hero)
        if anchor and Entity.IsAlive(anchor) then
            local blink = get_blink_item(anchor)
            if script.can_cast_blink_now(anchor, blink) then
                local anchor_pos = safe_call(Entity.GetAbsOrigin, anchor)
                local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
                if anchor_pos and target_pos then
                    local blink_range = script.get_item_cast_range_for_npc(anchor, blink, 1200)
                    local dist = vec_dist_2d(anchor_pos, target_pos) or 0
                    if dist > (blink_range + 80) then
                        move_units = { anchor }
                    end
                end
            end
        end
    end
    issue_combo_move_order(local_player, move_units, destination, now)
end
function script.draw_combo_target_focus(local_hero)
    if not is_combo_active() then
        return
    end
    local local_player = safe_call(Players.GetLocal)
    local now = get_game_time()
    local source_meepo = combo_focus_source
    if not source_meepo or not Entity.IsAlive(source_meepo) or not is_meepo_instance(source_meepo) then
        source_meepo = get_combo_anchor_meepo(local_player, local_hero)
        combo_focus_source = source_meepo
    end
    local target = combo_focus_target
    local cursor_x, cursor_y = get_cursor_position()
    local fov_radius = get_combo_target_fov_radius()
    if source_meepo then
        local hovered_target = select(1, get_combo_target_under_cursor(source_meepo))
        if hovered_target and Entity.IsAlive(hovered_target) then
            target = hovered_target
            combo_focus_target = hovered_target
        else
            target = nil
            combo_focus_target = nil
        end
    elseif target and not Entity.IsAlive(target) then
        target = nil
        combo_focus_target = nil
    end
    if cursor_x and cursor_y and Render.Circle then
        local circle_color = target and Color(255, 110, 110, 230) or Color(255, 205, 120, 220)
        Render.Circle(Vec2(cursor_x, cursor_y), fov_radius, circle_color, 1.8)
    end
    if not target then
        if cursor_x and cursor_y then
            Render.Text(
                font,
                tactical_font_size,
                "SEARCHING",
                Vec2(cursor_x + fov_radius + 8, cursor_y - 8),
                Color(255, 220, 130, 245)
            )
        end
        return
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return
    end
    local target_pos_render = target_pos + Vector(0, 0, (safe_call(NPC.GetHealthBarOffset, target) or 0) + 8)
    local target_screen, visible = Render.WorldToScreen(target_pos_render)
    if not visible then
        return
    end
    if cursor_x and cursor_y and Render.Line then
        Render.Line(Vec2(cursor_x, cursor_y), target_screen, COLORS.combo, 2.0)
    end
    local source_pos = safe_call(Entity.GetAbsOrigin, source_meepo)
    if source_pos and Render.Line then
        source_pos = source_pos + Vector(0, 0, (safe_call(NPC.GetHealthBarOffset, source_meepo) or 0) + 8)
        local source_screen, source_visible = Render.WorldToScreen(source_pos)
        if source_visible then
            Render.Line(source_screen, target_screen, Color(255, 180, 180, 200), 1.4)
        end
    end
    if Render.Circle then
        Render.Circle(target_screen, 18, COLORS.combo, 2.0)
    end
    local meepos = collect_meepos()
    local net_units = collect_owned_meepo_units(local_hero, meepos)
    if #net_units == 0 and source_meepo then
        net_units = { source_meepo }
    end
    if #net_units > 0 and Render.WorldToScreen then
        local preferred_draw = script.is_combo_option_enabled(ui.combo_main_first) and get_main_meepo(local_hero) or nil
        local _, _, _, predicted_pos = choose_earthbind_caster(net_units, target, now, preferred_draw)
        if predicted_pos then
            local predicted_world = predicted_pos + Vector(0, 0, (safe_call(NPC.GetHealthBarOffset, target) or 0) + 8)
            local pred_screen, pred_visible = Render.WorldToScreen(predicted_world)
            if pred_visible and pred_screen then
                if Render.Line then
                    Render.Line(target_screen, pred_screen, Color(120, 220, 255, 180), 1.2)
                end
                if Render.Circle then
                    Render.Circle(pred_screen, 10, Color(120, 220, 255, 220), 2.0)
                end
            end
        end
    end
    local target_name = safe_call(NPC.GetUnitName, target) or "target"
    Render.Text(
        font,
        tactical_font_size,
        "TARGET: " .. tostring(target_name),
        Vec2(target_screen.x + 14, target_screen.y - 10),
        Color(255, 210, 210, 245)
    )
    if script.is_combo_option_enabled(ui.combo_debug) then
        local phase_line = "PHASE: " .. tostring(script._combo_debug_phase or "-")
        local reason_line = "WHY: " .. tostring(script._combo_debug_reason or "-")
        local next_line = "NEXT: " .. tostring(script._combo_debug_next_disable or "-")
        local preferred_debug = script.is_combo_option_enabled(ui.combo_main_first) and get_main_meepo(local_hero) or nil
        local remaining_root_debug = get_effective_earthbind_remaining(target, now)
        local confirmed_root_debug = get_confirmed_control_remaining(target, now)
        local in_flight_debug = is_net_projectile_in_flight(target, now)
        local _, _, arrival_debug = choose_earthbind_caster(net_units, target, now, preferred_debug)
        if not arrival_debug then
            local _, _, arrival_fallback_debug = choose_earthbind_caster(net_units, target, now)
            arrival_debug = arrival_fallback_debug
        end
        local net_line = "NET: no-caster rem " .. string.format("%.2f", remaining_root_debug)
        if arrival_debug then
            local time_to_land_debug = math.max(0, arrival_debug - now)
            local handoff_window_debug = time_to_land_debug + C.COMBO_NET_CHAIN_BUFFER + C.COMBO_NET_HANDOFF_EXTRA
            local net_state_debug = remaining_root_debug <= handoff_window_debug and "CAST" or "HOLD"
            net_line = string.format(
                "NET: %s rem %.2f land %.2f win %.2f",
                net_state_debug,
                remaining_root_debug,
                time_to_land_debug,
                handoff_window_debug
            )
        end
        local follow_poof_count = tonumber(script._combo_last_net_follow_poof_count or 0) or 0
        local follow_age = now - (tonumber(script._combo_last_net_follow_poof_time or -9999) or -9999)
        local follow_text = string.format("NET->POOF: %d", follow_poof_count)
        if follow_age >= 0 and follow_age < 2.5 then
            follow_text = string.format("NET->POOF: %d (%.2fs)", follow_poof_count, follow_age)
        end
        local queue_count = (poof_cast_queue and #poof_cast_queue) or 0
        local queue_line = string.format("POOF QUEUE: %d", queue_count)
        local control_line = string.format(
            "CTRL: confirmed %.2f inflight %s",
            confirmed_root_debug,
            in_flight_debug and "yes" or "no"
        )
        Render.Text(font, tactical_font_size, phase_line, Vec2(target_screen.x + 14, target_screen.y + 4), Color(190, 230, 255, 240))
        Render.Text(font, tactical_font_size, reason_line, Vec2(target_screen.x + 14, target_screen.y + 18), Color(255, 235, 180, 240))
        Render.Text(font, tactical_font_size, next_line, Vec2(target_screen.x + 14, target_screen.y + 32), Color(200, 255, 200, 240))
        Render.Text(font, tactical_font_size, net_line, Vec2(target_screen.x + 14, target_screen.y + 46), Color(150, 220, 255, 240))
        Render.Text(font, tactical_font_size, follow_text, Vec2(target_screen.x + 14, target_screen.y + 60), Color(255, 215, 150, 240))
        Render.Text(font, tactical_font_size, queue_line, Vec2(target_screen.x + 14, target_screen.y + 74), Color(190, 255, 190, 240))
        Render.Text(font, tactical_font_size, control_line, Vec2(target_screen.x + 14, target_screen.y + 88), Color(255, 200, 200, 240))
    end
end
function script.can_cast_auto_safe_poof(meepo, poof)
    if not meepo or not poof then
        return false
    end
    local level = tonumber(safe_call(Ability.GetLevel, poof) or 0) or 0
    if level < 1 then
        return false
    end
    if not can_cast_ability_for_npc(meepo, poof) then
        return false
    end
    if safe_call(Ability.IsInAbilityPhase, poof) == true or safe_call(Ability.IsChannelling, poof) == true then
        return false
    end
    if NPC.IsSilenced and safe_call(NPC.IsSilenced, meepo) == true then
        return false
    end
    if NPC.IsStunned and safe_call(NPC.IsStunned, meepo) == true then
        return false
    end
    local hexed_state = Enum and Enum.ModifierState and Enum.ModifierState.MODIFIER_STATE_HEXED or nil
    if hexed_state and NPC.HasState and safe_call(NPC.HasState, meepo, hexed_state) == true then
        return false
    end
    return true
end
function script.get_unit_distance_2d(a, b)
    if not a or not b then
        return nil
    end
    local a_pos = safe_call(Entity.GetAbsOrigin, a)
    local b_pos = safe_call(Entity.GetAbsOrigin, b)
    return vec_dist_2d(a_pos, b_pos)
end
function script.count_enemies_near_unit(unit, radius)
    if not unit or not Entity.IsAlive(unit) then
        return 0
    end
    local enemy_list = Entity.GetHeroesInRadius(unit, radius, Enum.TeamType.TEAM_ENEMY, false, true) or {}
    return #enemy_list
end
function script.issue_auto_safe_poof(local_player, meepo, destination, poof, reason)
    if not meepo or not destination or not poof then
        return false
    end
    local order_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if local_player and order_type and issuer_type and Player and Player.PrepareUnitOrders then
        local ordered = pcall(function()
            Player.PrepareUnitOrders(
                local_player,
                order_type,
                destination,
                Vector(0, 0, 0),
                poof,
                issuer_type,
                meepo,
                false,
                false,
                false,
                false,
                reason or "meepo_auto_safe_poof",
                false
            )
        end)
        if ordered then
            return true
        end
    end
    local casted = pcall(function()
        Ability.CastTarget(
            poof,
            destination,
            false,
            true,
            true,
            reason or "meepo_auto_safe_poof"
        )
    end)
    return casted == true
end
function script.find_auto_safe_enemy_destination(meepo, meepos)
    if not meepo or not meepos then
        return nil
    end
    local best_clone = nil
    local best_dist = 0
    for i = 1, #meepos do
        local other = meepos[i]
        if other and other ~= meepo and Entity.IsAlive(other) then
            if script.count_enemies_near_unit(other, 1200) <= 0 then
                local d = script.get_unit_distance_2d(meepo, other) or 0
                if d > best_dist then
                    best_dist = d
                    best_clone = other
                end
            end
        end
    end
    if best_clone then
        return best_clone
    end
    best_dist = 0
    for i = 1, #meepos do
        local other = meepos[i]
        if other and other ~= meepo and Entity.IsAlive(other) then
            local d = script.get_unit_distance_2d(meepo, other) or 0
            if d > 1500 and d > best_dist then
                best_dist = d
                best_clone = other
            end
        end
    end
    return best_clone
end
function script.find_auto_safe_hp_destination(meepo, meepos, main_meepo, mode)
    if not meepo or not meepos then
        return nil
    end
    local choice = tonumber(mode or 0) or 0
    if choice == 1 then
        if main_meepo and main_meepo ~= meepo and Entity.IsAlive(main_meepo) then
            return main_meepo
        end
        return nil
    end
    if choice == 2 then
        local healthiest = nil
        local best_hp = -1
        for i = 1, #meepos do
            local other = meepos[i]
            if other and other ~= meepo and Entity.IsAlive(other) then
                local hp = get_health_pct(other)
                if hp > best_hp then
                    best_hp = hp
                    healthiest = other
                end
            end
        end
        return healthiest
    end
    local farthest = nil
    local farthest_dist = 0
    for i = 1, #meepos do
        local other = meepos[i]
        if other and other ~= meepo and Entity.IsAlive(other) then
            local d = script.get_unit_distance_2d(meepo, other) or 0
            if d > farthest_dist then
                farthest_dist = d
                farthest = other
            end
        end
    end
    return farthest
end
function script.run_auto_safe_poof(local_hero, meepos, local_player, now)
    if not ui.auto_safe_enable:Get() then
        return false
    end
    if not local_hero or not Entity.IsAlive(local_hero) then
        return false
    end
    if not meepos or #meepos <= 0 then
        return false
    end
    local enemy_poof_enabled = ui.auto_safe_enemy_poof:Get()
    local hp_poof_enabled = ui.auto_safe_poof_hp_enable:Get()
    if not enemy_poof_enabled and not hp_poof_enabled then
        return false
    end
    local which_meepos = tonumber(ui.auto_safe_which_meepos:Get() or 1) or 1
    local enemy_radius = tonumber(ui.auto_safe_enemy_radius:Get() or 900) or 900
    local hp_threshold = tonumber(ui.auto_safe_poof_hp:Get() or 25) or 25
    local destination_mode = tonumber(ui.auto_safe_poof_dest:Get() or 0) or 0
    local cooldown = (tonumber(ui.auto_safe_cd_ms:Get() or 2000) or 2000) / 1000.0
    local triggered = false
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            local is_main = (meepo == local_hero)
            local allow_unit = true
            if which_meepos == 1 and is_main then
                allow_unit = false
            elseif which_meepos == 2 and not is_main then
                allow_unit = false
            end
            if allow_unit then
                local key = get_entity_key(meepo)
                local last_safe = script._auto_safe_last_cast_by_meepo[key] or -9999
                if now - last_safe >= cooldown then
                    local enemy_count = script.count_enemies_near_unit(meepo, enemy_radius)
                    local has_enemies = enemy_count > 0
                    local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
                    local can_poof = script.can_cast_auto_safe_poof(meepo, poof)
                    local casted_for_meepo = false
                    if can_poof and enemy_poof_enabled and has_enemies then
                        local last_enemy_poof = script._auto_safe_last_enemy_poof_by_meepo[key] or -9999
                        if now - last_enemy_poof >= cooldown then
                            local enemy_dest = script.find_auto_safe_enemy_destination(meepo, meepos)
                            if enemy_dest and script.issue_auto_safe_poof(local_player, meepo, enemy_dest, poof, "meepo_poof_safety") then
                                script._auto_safe_last_enemy_poof_by_meepo[key] = now
                                script._auto_safe_last_cast_by_meepo[key] = now
                                triggered = true
                                casted_for_meepo = true
                            end
                        end
                    end
                    if (not casted_for_meepo) and can_poof and hp_poof_enabled and has_enemies then
                        local hp_pct = get_health_pct(meepo)
                        if hp_pct <= hp_threshold then
                            local hp_dest = script.find_auto_safe_hp_destination(meepo, meepos, local_hero, destination_mode)
                            if hp_dest and script.issue_auto_safe_poof(local_player, meepo, hp_dest, poof, "meepo_safe_poof") then
                                script._auto_safe_last_cast_by_meepo[key] = now
                                triggered = true
                                casted_for_meepo = true
                            end
                        end
                    end
                end
            end
        end
    end
    return triggered
end
function script.try_auto_dig(meepo, now)
    if not ui.auto_dig:Get() then
        return false
    end
    if not meepo or not Entity.IsAlive(meepo) then
        return false
    end
    local hp_pct = get_health_pct(meepo)
    if hp_pct > (tonumber(ui.auto_dig_hp:Get()) or 28) then
        return false
    end
    if safe_call(NPC.HasModifier, meepo, C.MODIFIER_DIG) then
        return false
    end
    if not should_trigger_save_by_enemy(meepo) then
        return false
    end
    local ready, dig = can_cast_dig(meepo)
    if not ready or not dig then
        return false
    end
    local key = get_entity_key(meepo)
    local last_cast = auto_dig_last_cast[key] or -9999
    if now - last_cast < C.AUTO_DIG_RECAST_DELAY then
        return false
    end
    local ok = pcall(function()
        Ability.CastNoTarget(dig)
    end)
    if ok then
        auto_dig_last_cast[key] = now
        return true
    end
    return false
end
function script.try_auto_mega(meepos, now)
    if not ui.auto_mega:Get() then
        return false
    end
    if not meepos or #meepos <= 0 then
        return false
    end
    local target, hp_pct = get_lowest_hp_meepo(meepos)
    if not target then
        return false
    end
    if (hp_pct or 100) > (tonumber(ui.auto_mega_hp:Get()) or 35) then
        return false
    end
    if has_any_modifier(target, C.MODIFIER_MEGA_CANDIDATES) then
        return false
    end
    if not should_trigger_save_by_enemy(target) then
        return false
    end
    local caster = nil
    local mega = nil
    local local_hero = Heroes.GetLocal()
    if local_hero and is_meepo_instance(local_hero) and Entity.IsAlive(local_hero) then
        local ready_local, mega_local = can_cast_mega(local_hero)
        if ready_local and mega_local then
            caster = local_hero
            mega = mega_local
        end
    end
    if not mega then
        local ready_target, mega_target = can_cast_mega(target)
        if ready_target and mega_target then
            caster = target
            mega = mega_target
        end
    end
    if not mega then
        for i = 1, #meepos do
            local meepo = meepos[i]
            if meepo and Entity.IsAlive(meepo) then
                local ready_any, mega_any = can_cast_mega(meepo)
                if ready_any and mega_any then
                    caster = meepo
                    mega = mega_any
                    break
                end
            end
        end
    end
    if not mega or not caster then
        return false
    end
    local key = get_entity_key(caster)
    local last_cast = auto_mega_last_cast[key] or -9999
    if now - last_cast < C.AUTO_MEGA_RECAST_DELAY then
        return false
    end
    local ok = pcall(function()
        Ability.CastNoTarget(mega)
    end)
    if ok then
        auto_mega_last_cast[key] = now
        return true
    end
    return false
end
function script.get_meepo_status(meepo)
    if not Entity.IsAlive(meepo) then
        return "DEAD", COLORS.dead, "HP 0% | MP -- | P -- | N -- | E --"
    end
    local is_attacking = NPC.IsAttacking(meepo)
    local is_running = NPC.IsRunning(meepo)
    local enemy_count, nearest_dist = get_enemy_info(meepo, C.ENEMY_RADIUS)
    local enemy_near = enemy_count > 0
    local hp_pct = get_health_pct(meepo)
    local mana_pct = get_mana_pct(meepo)
    local poof_cd = get_ability_cd(meepo, C.ABILITY_POOF)
    local net_cd = get_ability_cd(meepo, C.ABILITY_NET)
    local poof_ready = is_ability_ready(meepo, C.ABILITY_POOF)
    local net_ready = is_ability_ready(meepo, C.ABILITY_NET)
    local tactical = build_tactical_line(hp_pct, mana_pct, poof_cd, net_cd, nearest_dist)
    local retreat = enemy_near and hp_pct <= C.RETREAT_HP_PCT and (is_running or not is_attacking)
    if retreat then
        return "RETREAT", COLORS.retreat, tactical
    end
    local engage_ready =
        enemy_near and
        nearest_dist and nearest_dist <= C.READY_RADIUS and
        hp_pct >= C.SAFE_ENGAGE_HP_PCT and
        poof_ready and net_ready
    if engage_ready then
        return "ENGAGE_READY", COLORS.engage_ready, tactical
    end
    if is_attacking and enemy_near then
        return "COMBO", COLORS.combo, tactical
    end
    if is_attacking then
        return "FARM", COLORS.farm, tactical
    end
    if is_running then
        return "MOVE", COLORS.move, tactical
    end
    return "IDLE", COLORS.idle, tactical
end
