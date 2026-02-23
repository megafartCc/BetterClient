function script.OnDraw()
    if not Engine.IsInGame() then
        return
    end
    local local_hero = Heroes.GetLocal()
    if not local_hero or not is_meepo_hero(local_hero) then
        return
    end
    script.draw_combo_target_focus(local_hero)
    local meepos = collect_meepos()
    local now = get_game_time()
    script.draw_autofarm_map_panel(local_hero, meepos, now)
    script.draw_autofarm_world_status(local_hero, meepos, now)
    if not ui.enabled:Get() then
        return
    end
    script.draw_floating_meepo_panel(local_hero, meepos, now)
    local override_status, override_color = script.get_global_override_status()
    for idx, meepo in ipairs(meepos) do
        local is_clone = NPC.IsMeepoClone and NPC.IsMeepoClone(meepo) or false
        if (is_clone and ui.show_clones:Get()) or (not is_clone and ui.show_main:Get()) then
            local status, color, tactical = script.get_meepo_status(meepo)
            if override_status and override_color then
                status = override_status
                color = override_color
            end
            local should_show_status = true
            if should_show_status then
                if ui.draw_world:Get() then
                    script.draw_meepo_status_world(meepo, status, color, tactical)
                end
                if ui.draw_portraits:Get() and script.has_meepo_clones() then
                    script.draw_meepo_status_portrait(idx, status, color, tactical)
                end
            end
        end
    end
end
function script.OnFrame()
    if not Engine.IsInGame() then
        return
    end
    local local_hero = Heroes.GetLocal()
    if not local_hero or not is_meepo_hero(local_hero) then
        return
    end
    local now = get_game_time()
    local meepos = collect_meepos()
    local local_player = safe_call(Players.GetLocal)
    script.update_autofarm_runtime_toggle(now)
    script.run_autofarm_logic(local_player, local_hero, meepos, now)
    begin_item_frame_budget()
    if local_player then
        local utility_issued = script.handle_poof_utilities(local_player, local_hero, meepos, now)
        if utility_issued then
            script.process_poof_queue(now)
            return
        end
    end
    if script.try_net_on_teleport(local_hero, meepos, now) then
        return
    end
    local combo_tick = tonumber(C and C.COMBO_LOGIC_TICK_INTERVAL or 0.03) or 0.03
    if combo_tick < 0 then
        combo_tick = 0
    end
    if now >= (tonumber(script._combo_logic_next_tick or 0) or 0) then
        script._combo_logic_next_tick = now + combo_tick
        script.run_combo_logic(local_hero, meepos, now)
    end
    script.process_blink_queue(now)
    script.process_poof_queue(now)
end
function script.OnUpdate()
    if not Engine.IsInGame() then
        return
    end
    local local_hero = Heroes.GetLocal()
    if not local_hero or not is_meepo_hero(local_hero) then
        return
    end
    local now = get_game_time()
    local meepos = collect_meepos()
    local auto_safe_enabled = ui.auto_safe_enable:Get() and (ui.auto_safe_enemy_poof:Get() or ui.auto_safe_poof_hp_enable:Get())
    if not ui.enabled:Get() or (not ui.auto_dig:Get() and not ui.auto_mega:Get() and not auto_safe_enabled) then
        return
    end
    if now < auto_dig_next_tick then
        return
    end
    auto_dig_next_tick = now + C.AUTO_DIG_TICK_INTERVAL
    if auto_safe_enabled then
        local local_player = safe_call(Players.GetLocal)
        script.run_auto_safe_poof(local_hero, meepos, local_player, now)
    end
    if ui.auto_mega:Get() then
        script.try_auto_mega(meepos, now)
    end
    if ui.auto_dig:Get() then
        for i = 1, #meepos do
            script.try_auto_dig(meepos[i], now)
        end
    end
end
return script
