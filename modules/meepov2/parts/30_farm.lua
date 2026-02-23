function script.run_autofarm_logic(local_player, local_hero, meepos, now)
    if script._autofarm_runtime_enabled ~= true then return false end
    if not local_player or not local_hero or not meepos or #meepos == 0 then return false end

    local raw_now_time = tonumber(now or get_game_time() or 0) or 0
    local now_time = get_neutral_clock_time(raw_now_time)
    local minute_index = math.floor(now_time / 60)
    local second_in_minute = now_time - (minute_index * 60)
    local last_game_time = tonumber(script._autofarm_last_game_time or now_time) or now_time
    if now_time + 1 < last_game_time then
        clear_autofarm_runtime_state()
    end
    script._autofarm_last_game_time = now_time
    if now_time < (tonumber(script._autofarm_next_tick or 0) or 0) then return false end
    script._autofarm_next_tick = now_time + AUTOFARM_LOGIC_TICK

    -- build camp list with shared camp status for all meepos
    local selected = script.get_autofarm_selected_locations and script.get_autofarm_selected_locations() or {}
    local observed = update_autofarm_camp_presence(selected, now_time)
    local observed_by_id = {}
    for i = 1, #observed do
        local entry = observed[i]
        if entry and entry.camp and entry.camp.id then
            observed_by_id[entry.camp.id] = entry
        end
    end
    local camps = {}
    local camp_by_id = {}
    local next_spawn_time = get_next_neutral_spawn_time(now_time)
    local next_spawn_eta = math.max(0, next_spawn_time - now_time)
    for i = 1, #selected do
        local c = selected[i]
        if c and c.id and c.world then
            local obs = observed_by_id[c.id]
            local pos = Vector(
                clamp_value(c.world.x or 0, AUTOFARM_WORLD_MIN, AUTOFARM_WORLD_MAX),
                clamp_value(c.world.y or 0, AUTOFARM_WORLD_MIN, AUTOFARM_WORLD_MAX),
                c.world.z or 0
            )
            local has_creeps = obs and (obs.has == true) or false
            local ready_at = tonumber(obs and (obs.ready_at or obs.next_spawn) or get_autofarm_camp_ready_at(c.id)) or now_time
            local status = obs and obs.status or "ready"
            if not has_creeps then
                if status == "unseen" or status == "ready" then
                    ready_at = now_time
                else
                    ready_at = next_spawn_time
                end
            end
            camps[#camps + 1] = {
                id = c.id,
                world = pos,
                data = c,
                has_creeps = has_creeps,
                creeps = obs and (obs.creeps or {}) or {},
                status = status,
                ready_at = ready_at,
            }
            camp_by_id[c.id] = camps[#camps]
        end
    end
    if #camps == 0 then
        clear_autofarm_runtime_state()
        return false
    end

    -- shared status and cooldown state
    script._autofarm_camp_cooldown_until = script._autofarm_camp_cooldown_until or {}
    script._autofarm_camp_status = script._autofarm_camp_status or {}

    local mana_reserve_pct = tonumber(ui.autofarm_mana_reserve:Get() or AUTOFARM_MANA_MIN_RESERVE) or AUTOFARM_MANA_MIN_RESERVE
    local use_poof_damage, use_poof_move = autofarm_use_poof_flags()
    local auto_stack_enabled = ui.autofarm_auto_stack and ui.autofarm_auto_stack.Get and ui.autofarm_auto_stack:Get() == true

    -- sticky assignment until camp empty for 0.6s
    script._autofarm_assignment_by_meepo = script._autofarm_assignment_by_meepo or {}
    script._autofarm_assignment_hold_until_by_meepo = script._autofarm_assignment_hold_until_by_meepo or {}
    script._autofarm_last_camp_by_meepo = script._autofarm_last_camp_by_meepo or {}
    script._autofarm_last_poof_move_by_meepo = script._autofarm_last_poof_move_by_meepo or {}
    script._autofarm_stack_state_by_meepo = script._autofarm_stack_state_by_meepo or {}
    script._autofarm_empty_since = script._autofarm_empty_since or {}
    local taken = {}

    local meepo_entries = {}
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) and not is_combo_cast_in_progress(meepo) then
            local key = get_entity_key(meepo)
            meepo_entries[#meepo_entries + 1] = {
                unit = meepo,
                key = key,
                pos = safe_call(Entity.GetAbsOrigin, meepo),
                priority_dist = 999999,
            }
        end
    end
    if #meepo_entries == 0 then
        return false
    end

    local camp_nearest_key = {}
    local camp_nearest_dist = {}
    for i = 1, #camps do
        local camp = camps[i]
        if camp then
            local best_key = nil
            local best_dist = nil
            for j = 1, #meepo_entries do
                local entry = meepo_entries[j]
                local d = entry.pos and vec_dist_2d(entry.pos, camp.world) or 999999
                if (not best_dist) or d < best_dist then
                    best_dist = d
                    best_key = entry.key
                end
            end
            camp_nearest_key[camp.id] = best_key
            camp_nearest_dist[camp.id] = best_dist or 999999
        end
    end

    local owners_by_camp = {}
    for i = 1, #meepo_entries do
        local entry = meepo_entries[i]
        local assigned = script._autofarm_assignment_by_meepo[entry.key]
        local camp_id = assigned and assigned.id or nil
        if camp_id and camp_by_id[camp_id] then
            owners_by_camp[camp_id] = owners_by_camp[camp_id] or {}
            owners_by_camp[camp_id][#owners_by_camp[camp_id] + 1] = entry
        end
    end
    for camp_id, owners in pairs(owners_by_camp) do
        if owners and #owners > 1 then
            local camp = camp_by_id[camp_id]
            local keeper_key = nil
            local keeper_score = nil
            local camp_has_creeps = camp and camp.has_creeps == true
            for i = 1, #owners do
                local entry = owners[i]
                local dist = (entry and entry.pos and camp) and vec_dist_2d(entry.pos, camp.world) or 999999
                local score = dist
                if camp_has_creeps and dist <= AUTOFARM_CAMP_REACH_RADIUS then
                    score = score - 100000
                end
                if (not keeper_score) or score < keeper_score then
                    keeper_score = score
                    keeper_key = entry and entry.key or nil
                end
            end
            for i = 1, #owners do
                local entry = owners[i]
                if entry and entry.key and entry.key ~= keeper_key then
                    script._autofarm_assignment_by_meepo[entry.key] = nil
                    script._autofarm_assignment_hold_until_by_meepo[entry.key] = nil
                    script._autofarm_empty_since[entry.key] = nil
                end
            end
        end
    end

    local camp_owner_by_id = {}
    for i = 1, #meepo_entries do
        local entry = meepo_entries[i]
        local assigned = script._autofarm_assignment_by_meepo[entry.key]
        local camp_id = assigned and assigned.id or nil
        if camp_id and camp_by_id[camp_id] and not camp_owner_by_id[camp_id] then
            camp_owner_by_id[camp_id] = entry.key
        end
    end

    for i = 1, #meepo_entries do
        local entry = meepo_entries[i]
        local best = 999999
        if entry and entry.pos then
            for j = 1, #camps do
                local camp = camps[j]
                if camp then
                    local ready_at = tonumber(camp.ready_at or get_autofarm_camp_ready_at(camp.id) or 0) or 0
                    local status = tostring(camp.status or "")
                    local is_active = (now_time >= ready_at) and (camp.has_creeps or status == "unseen" or status == "ready")
                    local d = vec_dist_2d(entry.pos, camp.world)
                    if is_active then
                        if d < best then
                            best = d
                        end
                    elseif best >= 999999 and d < best then
                        best = d
                    end
                end
            end
        end
        entry.priority_dist = best
    end
    table.sort(meepo_entries, function(a, b)
        local ad = tonumber(a and a.priority_dist or 999999) or 999999
        local bd = tonumber(b and b.priority_dist or 999999) or 999999
        if math.abs(ad - bd) > 0.01 then
            return ad < bd
        end
        return (tonumber(a and a.key or 0) or 0) < (tonumber(b and b.key or 0) or 0)
    end)

    local function choose_camp(meepo_pos, meepo_key)
        local last_camp_id = meepo_key and script._autofarm_last_camp_by_meepo[meepo_key] or nil
        local last_camp = last_camp_id and camp_by_id[last_camp_id] or nil
        local chain_origin = (last_camp and last_camp.world) or meepo_pos

        local best = nil
        local best_tier = nil
        local best_score = nil
        local best_ready_at = nil
        local nearest_by_tier = {}

        for i = 1, #camps do
            local camp = camps[i]
            local owner_key = camp and camp_owner_by_id[camp.id] or nil
            if camp and (not taken[camp.id]) and (not owner_key or owner_key == meepo_key) then
                local ready_at = tonumber(camp.ready_at or get_autofarm_camp_ready_at(camp.id) or 0) or 0
                local status = tostring(camp.status or "")
                local tier = 4
                if now_time >= ready_at and camp.has_creeps then
                    tier = 1
                elseif now_time >= ready_at and status == "unseen" then
                    tier = 2
                elseif now_time >= ready_at then
                    tier = 3
                end
                local dist_meepo = meepo_pos and vec_dist_2d(meepo_pos, camp.world) or 999999
                local prev_nearest = nearest_by_tier[tier]
                if (not prev_nearest) or dist_meepo < prev_nearest then
                    nearest_by_tier[tier] = dist_meepo
                end
            end
        end

        for i = 1, #camps do
            local camp = camps[i]
            local owner_key = camp and camp_owner_by_id[camp.id] or nil
            if camp and (not taken[camp.id]) and (not owner_key or owner_key == meepo_key) then
                local ready_at = tonumber(camp.ready_at or get_autofarm_camp_ready_at(camp.id) or 0) or 0
                local status = tostring(camp.status or "")
                local tier = 4
                if now_time >= ready_at and camp.has_creeps then
                    tier = 1
                elseif now_time >= ready_at and status == "unseen" then
                    tier = 2
                elseif now_time >= ready_at then
                    tier = 3
                end

                local dist_meepo = meepo_pos and vec_dist_2d(meepo_pos, camp.world) or 999999
                local dist_chain = chain_origin and vec_dist_2d(chain_origin, camp.world) or dist_meepo
                local score = 0
                if tier == 4 then
                    local wait = math.max(0, ready_at - now_time)
                    score = wait * 1200 + dist_meepo
                else
                    score = (dist_meepo * 0.55) + (dist_chain * 0.45)
                    local nearest = nearest_by_tier[tier]
                    if nearest and dist_meepo > (nearest + AUTOFARM_QUEUE_NEAR_BAND) then
                        score = score + 8000
                    end
                    local nearest_key = camp_nearest_key[camp.id]
                    local nearest_dist = tonumber(camp_nearest_dist[camp.id] or 999999) or 999999
                    if nearest_key and meepo_key and nearest_key ~= meepo_key and dist_meepo > (nearest_dist + AUTOFARM_POOF_MOVE_ADVANTAGE) then
                        score = score + 16000
                    end
                    if dist_meepo > AUTOFARM_QUEUE_MAX_TRAVEL and nearest and nearest <= AUTOFARM_QUEUE_MAX_TRAVEL then
                        score = score + 12000
                    end
                end

                local better = false
                if not best then
                    better = true
                elseif tier < best_tier then
                    better = true
                elseif tier == best_tier and score < best_score then
                    better = true
                elseif tier == best_tier and math.abs(score - best_score) <= 0.01 and ready_at < best_ready_at then
                    better = true
                end

                if better then
                    best = camp
                    best_tier = tier
                    best_score = score
                    best_ready_at = ready_at
                end
            end
        end

        if best then
            if best_tier and best_tier >= 2 then
                local spawn_eta = math.max(0, next_spawn_time - now_time)
                if spawn_eta <= AUTOFARM_RESPAWN_WAIT_WINDOW then
                    local best_dist = meepo_pos and vec_dist_2d(meepo_pos, best.world) or 999999
                    local travel_time = best_dist / math.max(1, AUTOFARM_TRAVEL_SPEED_ESTIMATE)
                    local move_budget = math.max(0, spawn_eta - AUTOFARM_RESPAWN_WAIT_BUFFER)
                    if travel_time > move_budget then
                        return nil
                    end
                end
            end
            return best
        end

        local fallback = nil
        local fallback_dist = nil
        for i = 1, #camps do
            local camp = camps[i]
            local owner_key = camp and camp_owner_by_id[camp.id] or nil
            if camp and (not owner_key or owner_key == meepo_key) then
                local d = meepo_pos and vec_dist_2d(meepo_pos, camp.world) or 999999
                if (not fallback) or d < fallback_dist then
                    fallback = camp
                    fallback_dist = d
                end
            end
        end
        return fallback
    end
    local function choose_wait_camp(meepo_pos, meepo_key)
        local best = nil
        local best_score = nil
        for i = 1, #camps do
            local camp = camps[i]
            local owner_key = camp and camp_owner_by_id[camp.id] or nil
            if camp and (not taken[camp.id]) and (not owner_key or owner_key == meepo_key) then
                local ready_at = tonumber(camp.ready_at or get_autofarm_camp_ready_at(camp.id) or next_spawn_time) or next_spawn_time
                local wait = math.max(0, ready_at - now_time)
                local d = meepo_pos and vec_dist_2d(meepo_pos, camp.world) or 999999
                local score = (wait * 900) + d
                if camp.has_creeps == true then
                    score = score - 3000
                elseif tostring(camp.status or "") == "unseen" then
                    score = score - 700
                end
                if (not best) or score < best_score then
                    best = camp
                    best_score = score
                end
            end
        end
        return best
    end
    local function handle_autostack_for_camp(meepo, key, meepo_pos, assigned, creeps)
        if auto_stack_enabled ~= true then
            return false, false
        end
        if not meepo or not key or not assigned or not assigned.data or not creeps or #creeps == 0 then
            return false, false
        end
        if second_in_minute < AUTOFARM_STACK_PREP_SECOND or second_in_minute >= 59.8 then
            return false, false
        end
        local center = get_camp_center(assigned.data)
        local dist_center = (center and meepo_pos) and vec_dist_2d(meepo_pos, center) or 999999
        if dist_center > AUTOFARM_STACK_TRIGGER_RADIUS then
            return false, false
        end
        local stack_state = script._autofarm_stack_state_by_meepo[key] or {}
        if stack_state.minute ~= minute_index or stack_state.camp_id ~= assigned.id then
            stack_state = { minute = minute_index, camp_id = assigned.id, phase = "prep", pull_time = 0, retreat_time = 0, last_retreat_order = 0 }
        end
        local issued_stack = false
        if second_in_minute < AUTOFARM_SPAWN_CLEAR_SECOND then
            stack_state.phase = "prep"
            -- keep meepo near camp before :55, but do not aggro too early
            local prep_dist = dist_center
            local prep_target = center or assigned.world
            if prep_target and prep_dist > (AUTOFARM_STACK_TRIGGER_RADIUS * 0.55) then
                local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                if autofarm_issue_order(local_player, meepo, order, nil, prep_target, "meepo_autofarm_stack_prep", now_time) then
                    issued_stack = true
                end
            end
        else
            local target = autofarm_pick_nearest(creeps, meepo_pos or assigned.world)
            if (tonumber(stack_state.pull_time or 0) or 0) <= 0 then
                if target then
                    local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET or nil
                    if autofarm_issue_order(local_player, meepo, order, target, nil, "meepo_autofarm_stack_pull", now_time) then
                        issued_stack = true
                        stack_state.phase = "pull"
                        stack_state.pull_time = now_time
                    end
                end
            else
                stack_state.phase = "pull"
                local pull_time = tonumber(stack_state.pull_time or 0) or 0
                local retreat_elapsed = now_time - pull_time
                if retreat_elapsed >= AUTOFARM_STACK_RETREAT_DELAY then
                    local retreat_distance = AUTOFARM_STACK_RETREAT_DISTANCE
                    if assigned.data and assigned.data.camp_box and assigned.data.camp_box.min and assigned.data.camp_box.max then
                        local box_dx = math.abs((assigned.data.camp_box.max.x or 0) - (assigned.data.camp_box.min.x or 0)) * 0.5
                        local box_dy = math.abs((assigned.data.camp_box.max.y or 0) - (assigned.data.camp_box.min.y or 0)) * 0.5
                        local min_clear = math.max(box_dx, box_dy) + 480
                        if retreat_distance < min_clear then
                            retreat_distance = min_clear
                        end
                    end
                    local retreat_pos = get_camp_offset_point(assigned.data, meepo_pos, retreat_distance)
                    if retreat_pos then
                        local should_reissue = (tonumber(stack_state.last_retreat_order or 0) or 0) <= 0
                            or (now_time - (tonumber(stack_state.last_retreat_order or 0) or 0)) >= 0.45
                        if should_reissue then
                            local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                            if autofarm_issue_order(local_player, meepo, order, nil, retreat_pos, "meepo_autofarm_stack_retreat", now_time) then
                                issued_stack = true
                                stack_state.phase = "retreat"
                                stack_state.retreat_time = now_time
                                stack_state.last_retreat_order = now_time
                            end
                        end
                    end
                end
            end
        end
        script._autofarm_stack_state_by_meepo[key] = stack_state
        return true, issued_stack
    end

    local function try_autofarm_poof_move(meepo, meepo_key, meepo_pos, assigned)
        if use_poof_move ~= true then
            return false
        end
        if not meepo or not meepo_key or not meepo_pos or not assigned or not assigned.world then
            return false
        end
        local dist_to_camp = vec_dist_2d(meepo_pos, assigned.world)
        if dist_to_camp < AUTOFARM_POOF_MOVE_MIN_DIST then
            return false
        end
        local last_poof = tonumber(script._autofarm_last_poof_move_by_meepo[meepo_key] or -9999) or -9999
        if (now_time - last_poof) < AUTOFARM_POOF_MOVE_RECAST then
            return false
        end
        local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
        if not poof or not can_cast_ability_for_npc(meepo, poof) then
            return false
        end
        if safe_call(Ability.IsInAbilityPhase, poof) == true or safe_call(Ability.IsChannelling, poof) == true then
            return false
        end

        local best_anchor = nil
        local best_anchor_dist = dist_to_camp
        for i = 1, #meepo_entries do
            local entry = meepo_entries[i]
            if entry and entry.key ~= meepo_key and entry.unit and entry.pos and Entity.IsAlive(entry.unit) then
                local anchor_dist = vec_dist_2d(entry.pos, assigned.world)
                if anchor_dist + AUTOFARM_POOF_MOVE_ADVANTAGE < dist_to_camp and anchor_dist < best_anchor_dist then
                    best_anchor = entry.unit
                    best_anchor_dist = anchor_dist
                end
            end
        end
        if not best_anchor then
            return false
        end
        if script.issue_group_poof_target_order(local_player, { meepo }, best_anchor, now_time, "meepo_autofarm_poof_move") then
            script._autofarm_last_poof_move_by_meepo[meepo_key] = now_time
            script._autofarm_last_order_by_meepo[meepo_key] = now_time
            return true
        end
        return false
    end

    local issued = false
    for i = 1, #meepo_entries do
        local entry = meepo_entries[i]
        local meepo = entry and entry.unit or nil
        local key = entry and entry.key or nil
        local meepo_pos = entry and entry.pos or nil
        if meepo and key and Entity.IsAlive(meepo) and not is_combo_cast_in_progress(meepo) then

            local assigned = script._autofarm_assignment_by_meepo[key]
            local hold_until = tonumber(script._autofarm_assignment_hold_until_by_meepo[key] or 0) or 0
            -- validate current assignment
            local valid = assigned and assigned.world and true or false
            if valid then
                local found = false
                for _, camp in ipairs(camps) do
                    if camp.id == assigned.id then
                        assigned = camp
                        found = true
                        break
                    end
                end
                if not found then
                    valid = false
                end
            end
            if valid and assigned then
                local owner_key = camp_owner_by_id[assigned.id]
                if owner_key and owner_key ~= key then
                    local dist_assigned = meepo_pos and vec_dist_2d(meepo_pos, assigned.world) or 999999
                    local engaged_here = assigned.has_creeps == true and dist_assigned <= AUTOFARM_CAMP_REACH_RADIUS
                    if engaged_here then
                        camp_owner_by_id[assigned.id] = key
                    else
                        valid = false
                    end
                elseif not owner_key then
                    camp_owner_by_id[assigned.id] = key
                end
            end
            if valid and assigned and taken[assigned.id] and camp_owner_by_id[assigned.id] ~= key then
                valid = false
            end
            if valid and assigned and assigned.has_creeps ~= true then
                local assigned_ready_at = tonumber(assigned.ready_at or get_autofarm_camp_ready_at(assigned.id) or 0) or 0
                if assigned_ready_at > now_time and hold_until <= now_time then
                    valid = false
                end
            end
            if not valid then
                assigned = choose_camp(meepo_pos, key)
                if not assigned then
                    assigned = choose_wait_camp(meepo_pos, key)
                end
                script._autofarm_assignment_by_meepo[key] = assigned
                script._autofarm_assignment_hold_until_by_meepo[key] = 0
                script._autofarm_empty_since[key] = nil
            end
            if assigned then
                camp_owner_by_id[assigned.id] = camp_owner_by_id[assigned.id] or key
                script._autofarm_last_camp_by_meepo[key] = assigned.id
                taken[assigned.id] = true
                local has, creeps = assigned.has_creeps, assigned.creeps
                if not has then
                    has, creeps = script.autofarm_camp_has_creeps(assigned.data)
                end
                if has and creeps and #creeps > 0 then
                    local dist_to_camp = meepo_pos and vec_dist_2d(meepo_pos, assigned.world) or 99999
                    if dist_to_camp <= (AUTOFARM_CAMP_REACH_RADIUS * 1.18) then
                        script._autofarm_assignment_hold_until_by_meepo[key] = now_time + AUTOFARM_ASSIGN_LOCK_SEC
                    end
                    if dist_to_camp > AUTOFARM_CAMP_REACH_RADIUS then
                        if try_autofarm_poof_move(meepo, key, meepo_pos, assigned) then
                            issued = true
                        else
                            local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                            if autofarm_issue_order(local_player, meepo, order, nil, assigned.world, "meepo_autofarm_move_to_camp", now_time) then
                                issued = true
                            end
                        end
                    else
                        local stack_active, stack_issued = handle_autostack_for_camp(meepo, key, meepo_pos, assigned, creeps)
                        if stack_active then
                            if stack_issued then
                                issued = true
                            end
                        else
                            local ready_state = mark_autofarm_camp_state(assigned.id, now_time, true, "ready", key)
                            local presence = script._autofarm_camp_presence or {}
                            local camp_presence = presence[assigned.id] or {}
                            camp_presence.has = true
                            camp_presence.last_seen_creeps = now_time
                            camp_presence.last_cleared = nil
                            camp_presence.status = "ready"
                            camp_presence.ready_at = tonumber(ready_state and ready_state.ready_at or now_time) or now_time
                            camp_presence.next_spawn = tonumber(ready_state and ready_state.next_spawn or get_next_neutral_spawn_time(now_time)) or get_next_neutral_spawn_time(now_time)
                            presence[assigned.id] = camp_presence
                            script._autofarm_camp_presence = presence
                            script._autofarm_empty_since[key] = nil
                            local target = autofarm_pick_nearest(creeps, meepo_pos or assigned.world)
                            if target then
                                local mana = tonumber(safe_call(NPC.GetMana, meepo) or 0) or 0
                                local max_mana = tonumber(safe_call(NPC.GetMaxMana, meepo) or 0) or 0
                                local mana_pct = (max_mana > 0) and ((mana / max_mana) * 100) or 0
                                local poof_action_taken = false
                                if use_poof_damage and mana_pct > mana_reserve_pct and #creeps >= AUTOFARM_POOF_DAMAGE_MIN_CREEPS then
                                    local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
                                    local meepo_origin = meepo_pos or assigned.world
                                    local target_pos = safe_call(Entity.GetAbsOrigin, target) or assigned.world
                                    local dist_target = vec_dist_2d(meepo_origin, target_pos)
                                    local camp_center = get_camp_center(assigned.data) or assigned.world
                                    local dist_center_now = vec_dist_2d(meepo_origin, camp_center)
                                    if poof and safe_call(Ability.IsReady, poof) == true then
                                        local poof_radius = get_poof_damage_radius(poof)
                                        if poof_radius <= 0 then
                                            poof_radius = AUTOFARM_POOF_DAMAGE_RANGE
                                        end
                                        local effective_radius = math.max(180, poof_radius - 70)
                                        local packed_count = 0
                                        for ci = 1, #creeps do
                                            local creep_pos = safe_call(Entity.GetAbsOrigin, creeps[ci])
                                            if creep_pos and vec_dist_2d(meepo_origin, creep_pos) <= effective_radius then
                                                packed_count = packed_count + 1
                                            end
                                        end
                                        local close_to_center = dist_center_now <= (AUTOFARM_CAMP_REACH_RADIUS * 0.58)
                                        local can_poof_now = dist_target <= AUTOFARM_POOF_DAMAGE_RANGE
                                            and packed_count >= AUTOFARM_POOF_DAMAGE_MIN_CREEPS
                                            and close_to_center
                                        if can_poof_now then
                                            if script.issue_group_poof_target_order(local_player, { meepo }, meepo, now_time, "meepo_autofarm_poof_damage") then
                                                poof_action_taken = true
                                                issued = true
                                                script._autofarm_last_order_by_meepo[key] = now_time
                                            end
                                        else
                                            if camp_center and dist_center_now > (AUTOFARM_POINT_REACH_RADIUS * 0.62) then
                                                local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                                                if autofarm_issue_order(local_player, meepo, order, nil, camp_center, "meepo_autofarm_poof_setup", now_time) then
                                                    poof_action_taken = true
                                                    issued = true
                                                end
                                            end
                                        end
                                    end
                                end
                                if not poof_action_taken then
                                    local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET or nil
                                    if autofarm_issue_order(local_player, meepo, order, target, nil, "meepo_autofarm_attack", now_time) then
                                        issued = true
                                    end
                                end
                            end
                        end
                    end
                else
                    local dist = meepo_pos and vec_dist_2d(meepo_pos, assigned.world) or 99999
                    local camp_center = get_camp_center(assigned.data)
                    local dist_center = (camp_center and meepo_pos) and vec_dist_2d(meepo_pos, camp_center) or dist
                    local in_spawn_box = assigned.data and assigned.data.camp_box and is_pos_in_box(meepo_pos, assigned.data.camp_box) or false
                    local spawn_clear_window = second_in_minute >= AUTOFARM_SPAWN_CLEAR_SECOND and next_spawn_eta <= AUTOFARM_SPAWN_CLEAR_WINDOW
                    if spawn_clear_window then
                        local wait_pos = get_camp_offset_point(assigned.data, meepo_pos, AUTOFARM_SPAWN_CLEAR_DISTANCE)
                        local target_pos = wait_pos or assigned.world
                        local target_dist = (target_pos and meepo_pos) and vec_dist_2d(meepo_pos, target_pos) or 99999
                        if target_pos and (in_spawn_box or dist_center <= AUTOFARM_CAMP_REACH_RADIUS or target_dist > (AUTOFARM_POINT_REACH_RADIUS * 0.6)) then
                            local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                            if autofarm_issue_order(local_player, meepo, order, nil, target_pos, "meepo_autofarm_spawn_clear_wait", now_time) then
                                issued = true
                            end
                        end
                        script._autofarm_empty_since[key] = nil
                    elseif dist > AUTOFARM_POINT_REACH_RADIUS then
                        if try_autofarm_poof_move(meepo, key, meepo_pos, assigned) then
                            issued = true
                        else
                            local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                            if autofarm_issue_order(local_player, meepo, order, nil, assigned.world, "meepo_autofarm_move", now_time) then
                                issued = true
                            end
                        end
                    else
                        local empty_since = tonumber(script._autofarm_empty_since[key] or 0) or 0
                        local close_no_box = (not (assigned.data and assigned.data.camp_box)) and (dist_center <= (AUTOFARM_POINT_REACH_RADIUS * 0.55))
                        local can_confirm_farmed = in_spawn_box or close_no_box
                        if not can_confirm_farmed then
                            script._autofarm_empty_since[key] = nil
                        elseif empty_since == 0 then
                            script._autofarm_empty_since[key] = now_time
                        elseif (now_time - empty_since) >= 0.6 then
                            -- confirmed as recently farmed only when meepo is really inside camp area
                            local farmed_state = force_autofarm_camp_not_ready(assigned.id, now_time, "farmed", key)
                            local presence = script._autofarm_camp_presence or {}
                            local camp_presence = presence[assigned.id] or {}
                            camp_presence.has = false
                            camp_presence.last_cleared = now_time
                            camp_presence.status = "farmed"
                            camp_presence.ready_at = tonumber(farmed_state and farmed_state.ready_at or get_autofarm_camp_ready_at(assigned.id)) or now_time
                            camp_presence.next_spawn = camp_presence.ready_at
                            presence[assigned.id] = camp_presence
                            script._autofarm_camp_presence = presence
                            script._autofarm_assignment_by_meepo[key] = nil
                            script._autofarm_assignment_hold_until_by_meepo[key] = nil
                            script._autofarm_empty_since[key] = nil
                        end
                    end
                end
            end
        end
    end
    return issued
end



function script.draw_autofarm_map_panel(local_hero, meepos, now)
    if not ui.autofarm_show_map or not ui.autofarm_show_map.Get or ui.autofarm_show_map:Get() ~= true then
        return
    end
    if not Render or not Render.Text or not Render.FilledRect or not Render.TextSize then
        return
    end
    local scale = autofarm_get_ui_number(ui.autofarm_map_scale, 100) / 100.0
    if scale < 0.6 then
        scale = 0.6
    elseif scale > 2.2 then
        scale = 2.2
    end
    local points = get_all_autofarm_points()
    local selected_set = script._autofarm_selected_points or {}
    script._autofarm_selected_points = selected_set
    local anim = script._autofarm_point_anim or {}
    script._autofarm_point_anim = anim
    local selected_side = script._autofarm_settings_side or "r"
    local function quick_select_side(points_list, side)
        if not points_list or not side then return end
        for i = 1, #points_list do
            local p = points_list[i]
            if p and p.id and p.side then
                selected_set[p.id] = (p.side == side)
            end
        end
    end
    local slider_x = autofarm_get_ui_number(ui.autofarm_map_x, 28)
    local slider_y = autofarm_get_ui_number(ui.autofarm_map_y, 820)
    if script._autofarm_map_pos_x == nil then script._autofarm_map_pos_x = slider_x end
    if script._autofarm_map_pos_y == nil then script._autofarm_map_pos_y = slider_y end
    local px = tonumber(script._autofarm_map_pos_x) or slider_x
    local py = tonumber(script._autofarm_map_pos_y) or slider_y
    local panel_w = math.floor(360 * scale) -- slightly wider to fit map edge-to-edge feel
    local header_h = math.floor(34 * scale)
    local pad = math.max(2, math.floor(4 * scale))
    local footer_h = 0
    local map_size = panel_w - (pad * 2)
    local panel_h = header_h + pad + map_size + pad + footer_h
    local screen = Render.ScreenSize and Render.ScreenSize() or nil
    if screen then
        local max_x = math.max(0, (tonumber(screen.x) or 0) - panel_w - 2)
        local max_y = math.max(0, (tonumber(screen.y) or 0) - panel_h - 2)
        px = clamp_value(px, 0, max_x)
        py = clamp_value(py, 0, max_y)
        script._autofarm_map_pos_x = px
        script._autofarm_map_pos_y = py
    end
    local mouse1 = get_mouse1_code()
    local click_once_left = mouse1 and safe_call(Input.IsKeyDownOnce, mouse1) == true
    local mouse_down_left = mouse1 and safe_call(Input.IsKeyDown, mouse1) == true
    local input_captured = safe_call(Input.IsInputCaptured) == true
    local cursor_x, cursor_y = get_cursor_position()
    local drag_header_w = panel_w - math.floor(140 * scale)
    local hover_drag_header = cursor_x and cursor_y and safe_call(Input.IsCursorInRect, px, py, drag_header_w, header_h) == true
    if input_captured then
        script._autofarm_map_drag_active = false
    end
    if (not input_captured) and click_once_left and hover_drag_header and cursor_x and cursor_y then
        script._autofarm_map_drag_active = true
        script._autofarm_map_drag_offset_x = cursor_x - px
        script._autofarm_map_drag_offset_y = cursor_y - py
    end
    if script._autofarm_map_drag_active then
        if input_captured or (not mouse_down_left) or (not cursor_x) or (not cursor_y) then
            script._autofarm_map_drag_active = false
        else
            local nx = math.floor((cursor_x - (script._autofarm_map_drag_offset_x or 0)) + 0.5)
            local ny = math.floor((cursor_y - (script._autofarm_map_drag_offset_y or 0)) + 0.5)
            if screen then
                local max_x = math.max(0, (tonumber(screen.x) or 0) - panel_w - 2)
                local max_y = math.max(0, (tonumber(screen.y) or 0) - panel_h - 2)
                nx = clamp_value(nx, 0, max_x)
                ny = clamp_value(ny, 0, max_y)
            end
            px = nx
            py = ny
            script._autofarm_map_pos_x = nx
            script._autofarm_map_pos_y = ny
        end
    end
    -- helpers
    local function lerp(a, b, t)
        return a + (b - a) * t
    end
    local function blend_rgb(r1, g1, b1, r2, g2, b2, t)
        return math.floor(lerp(r1, r2, t) + 0.5), math.floor(lerp(g1, g2, t) + 0.5), math.floor(lerp(b1, b2, t) + 0.5)
    end
    -- panel shell
    local panel_bg = Color(14, 18, 26, 200)
    local header_bg = Color(26, 30, 40, 225)
    local border = Color(178, 208, 240, 128)
    Render.FilledRect(Vec2(px, py), Vec2(px + panel_w, py + panel_h), panel_bg, 6, Enum.DrawFlags.RoundCornersAll)
    Render.FilledRect(Vec2(px, py), Vec2(px + panel_w, py + header_h), header_bg, 6, Enum.DrawFlags.RoundCornersAll)
    if Render.Rect then
        Render.Rect(Vec2(px, py), Vec2(px + panel_w, py + panel_h), border, 6, Enum.DrawFlags.RoundCornersAll, 0.9)
    end
    -- title + side tabs
    local title = "Meepo Farm Settings"
    local title_size = Render.TextSize(font, tactical_font_size, title)
    Render.Text(font, tactical_font_size, title, Vec2(px + pad, py + math.floor((header_h - tactical_font_size) * 0.5)), Color(225, 235, 250, 245))
    local side_btn_w = math.max(72, math.floor(78 * scale))
    local side_btn_h = math.max(18, math.floor(20 * scale))
    local side_btn_y = py + math.floor((header_h - side_btn_h) * 0.5)
    local side_gap = math.max(4, math.floor(6 * scale))
    local side_btn_x = px + pad + title_size.x + math.floor(12 * scale)
    local rad_x = side_btn_x
    local dire_x = side_btn_x + side_btn_w + side_gap
    local hover_radiant = cursor_x and cursor_y and safe_call(Input.IsCursorInRect, rad_x, side_btn_y, side_btn_w, side_btn_h) == true
    local hover_dire = cursor_x and cursor_y and safe_call(Input.IsCursorInRect, dire_x, side_btn_y, side_btn_w, side_btn_h) == true
    local radiant_active = selected_side ~= "d"
    local dire_active = selected_side == "d"
    local function draw_side_btn(x, label, active, hover, active_col)
        local base = active and active_col or Color(40, 46, 58, 205)
        if hover then
            base = Color(base.r + 18, base.g + 18, base.b + 18, math.min(255, (base.a or 205) + 10))
        end
        Render.FilledRect(Vec2(x, side_btn_y), Vec2(x + side_btn_w, side_btn_y + side_btn_h), base, 4, Enum.DrawFlags.RoundCornersAll)
        if Render.Rect then
            Render.Rect(Vec2(x, side_btn_y), Vec2(x + side_btn_w, side_btn_y + side_btn_h), Color(190, 210, 240, 120), 4, Enum.DrawFlags.RoundCornersAll, 0.7)
        end
        local text_col = active and Color(245, 245, 245, 245) or Color(210, 220, 235, 235)
        local label_size = Render.TextSize(font, tactical_font_size, label)
        Render.Text(font, tactical_font_size, label, Vec2(x + math.floor((side_btn_w - label_size.x) * 0.5), side_btn_y + math.floor((side_btn_h - tactical_font_size) * 0.5)), text_col)
    end
    draw_side_btn(rad_x, "Radiant", radiant_active, hover_radiant, Color(196, 68, 68, 235))
    draw_side_btn(dire_x, "Dire", dire_active, hover_dire, Color(80, 106, 180, 235))
    if click_once_left and (not input_captured) then
        if hover_radiant then
            selected_side = "r"
            script._autofarm_settings_side = "r"
            quick_select_side(points, "r")
        elseif hover_dire then
            selected_side = "d"
            script._autofarm_settings_side = "d"
            quick_select_side(points, "d")
        end
    end
    -- map body
    local map_x = px + pad
    local map_y = py + header_h + pad
    local map_size_i = map_size
    local map_image = autofarm_get_map_image()
    if map_image and Render.Image then
        Render.Image(map_image, Vec2(map_x, map_y), Vec2(map_size_i, map_size_i), Color(255, 255, 255, 255), 0, Enum.DrawFlags.None, AUTOFARM_MAP_UV_MIN, AUTOFARM_MAP_UV_MAX)
    else
        Render.FilledRect(Vec2(map_x, map_y), Vec2(map_x + map_size_i, map_y + map_size_i), Color(42, 56, 78, 196), 4, Enum.DrawFlags.RoundCornersAll)
        if Render.Line then
            Render.Line(Vec2(map_x, map_y + map_size_i), Vec2(map_x + map_size_i, map_y), Color(146, 174, 220, 110), 1.1)
            Render.Line(Vec2(map_x, map_y), Vec2(map_x + map_size_i, map_y + map_size_i), Color(132, 162, 210, 84), 1.0)
        end
    end
    if (not map_image) and Render.Rect then
        Render.Rect(Vec2(map_x, map_y), Vec2(map_x + map_size_i, map_y + map_size_i), Color(170, 205, 244, 122), 4, Enum.DrawFlags.RoundCornersAll, 0.8)
    end
    if (not map_image) and Render.Line then
        for i = 1, 3 do
            local t = i / 4.0
            local gx = map_x + (map_size_i * t)
            local gy = map_y + (map_size_i * t)
            Render.Line(Vec2(gx, map_y), Vec2(gx, map_y + map_size_i), Color(122, 150, 194, 58), 1.0)
            Render.Line(Vec2(map_x, gy), Vec2(map_x + map_size_i, gy), Color(122, 150, 194, 58), 1.0)
        end
    end
    local hover_map = cursor_x and cursor_y and safe_call(Input.IsCursorInRect, map_x, map_y, map_size_i, map_size_i) == true
    local point_by_id = {}
    for i = 1, #points do
        local point = points[i]
        if point and point.id then
            point_by_id[tostring(point.id)] = point
        end
    end
    local marker_radius_base = math.max(7, math.floor(9 * scale))
    local hover_radius_sq = (marker_radius_base + 7) * (marker_radius_base + 7)
    local hovered_point_id = nil
    local hovered_dist = nil
    if hover_map and cursor_x and cursor_y then
        for i = 1, #points do
            local point = points[i]
            local sx, sy = autofarm_map_to_screen(point.nx, point.ny, map_x, map_y, map_size_i)
            local dx = (cursor_x - sx)
            local dy = (cursor_y - sy)
            local dist_sq = dx * dx + dy * dy
            if dist_sq <= hover_radius_sq then
                if (not hovered_dist) or dist_sq < hovered_dist then
                    hovered_dist = dist_sq
                    hovered_point_id = point.id
                end
            end
        end
    end
    -- creep-wave markers (visual only; no autofarm logic attached yet)
    local wave_selected = script._autofarm_wave_marker_selected or {}
    script._autofarm_wave_marker_selected = wave_selected
    local wave_markers = {}
    do
        local lane_units = {}
        local lane_flag = Enum and Enum.UnitTypeFlags and Enum.UnitTypeFlags.TYPE_LANE_CREEP or nil
        if NPCs and NPCs.GetAll then
            lane_units = lane_flag and (safe_call(NPCs.GetAll, lane_flag) or {}) or (safe_call(NPCs.GetAll) or {})
        end
        local clusters = {}
        local cluster_link_dist = 980
        for i = 1, #lane_units do
            local npc = lane_units[i]
            if npc and Entity.IsAlive(npc) and safe_call(NPC.IsWaitingToSpawn, npc) ~= true then
                local is_lane_creep = NPC.IsLaneCreep and safe_call(NPC.IsLaneCreep, npc) == true
                if lane_flag or is_lane_creep then
                    local pos = safe_call(Entity.GetAbsOrigin, npc)
                    local team = tonumber(safe_call(Entity.GetTeamNum, npc) or -1) or -1
                    if pos and team >= 0 then
                        local best_idx = nil
                        local best_dist = nil
                        for j = 1, #clusters do
                            local c = clusters[j]
                            if c and c.team == team and c.count and c.count > 0 then
                                local cx = c.sum_x / c.count
                                local cy = c.sum_y / c.count
                                local d = vec_dist_2d(pos, Vector(cx, cy, pos.z or 0))
                                if d <= cluster_link_dist and ((not best_dist) or d < best_dist) then
                                    best_dist = d
                                    best_idx = j
                                end
                            end
                        end
                        if best_idx then
                            local c = clusters[best_idx]
                            c.sum_x = c.sum_x + (pos.x or 0)
                            c.sum_y = c.sum_y + (pos.y or 0)
                            c.sum_z = c.sum_z + (pos.z or 0)
                            c.count = c.count + 1
                        else
                            clusters[#clusters + 1] = {
                                team = team,
                                sum_x = (pos.x or 0),
                                sum_y = (pos.y or 0),
                                sum_z = (pos.z or 0),
                                count = 1,
                            }
                        end
                    end
                end
            end
        end
        for i = 1, #clusters do
            local c = clusters[i]
            if c and c.count and c.count >= 2 then
                local center = Vector(c.sum_x / c.count, c.sum_y / c.count, c.sum_z / c.count)
                local nx, ny = script.autofarm_world_to_norm(center)
                if nx and ny then
                    local qx = math.floor((((center.x or 0) + 9200) / 520) + 0.5)
                    local qy = math.floor((((center.y or 0) + 9200) / 520) + 0.5)
                    local id = tostring(c.team) .. ":" .. tostring(qx) .. ":" .. tostring(qy)
                    wave_markers[#wave_markers + 1] = {
                        id = id,
                        team = c.team,
                        count = c.count,
                        nx = nx,
                        ny = ny,
                    }
                end
            end
        end
    end
    local hovered_wave_id = nil
    local hovered_wave_dist = nil
    local wave_radius_base = math.max(6, math.floor(7 * scale))
    local wave_hover_radius_sq = (wave_radius_base + 7) * (wave_radius_base + 7)
    if hover_map and cursor_x and cursor_y then
        for i = 1, #wave_markers do
            local wave = wave_markers[i]
            local sx, sy = autofarm_map_to_screen(wave.nx, wave.ny, map_x, map_y, map_size_i)
            local dx = cursor_x - sx
            local dy = cursor_y - sy
            local dist_sq = dx * dx + dy * dy
            if dist_sq <= wave_hover_radius_sq then
                if (not hovered_wave_dist) or dist_sq < hovered_wave_dist then
                    hovered_wave_dist = dist_sq
                    hovered_wave_id = wave.id
                end
            end
        end
    end
    -- lines from meepos to camps (kept)
    if Render.Line and meepos and #meepos > 0 then
        local assignments = script._autofarm_assignment_by_meepo or {}
        for i = 1, #meepos do
            local meepo = meepos[i]
            if meepo and Entity.IsAlive(meepo) then
                local meepo_key = get_entity_key(meepo)
                local assigned_ref = assignments[meepo_key]
                local assigned_id = (type(assigned_ref) == "table" and assigned_ref.id) or assigned_ref
                local camp_point = assigned_id and point_by_id[tostring(assigned_id)] or nil
                if camp_point and camp_point.nx ~= nil and camp_point.ny ~= nil then
                    local pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local nx, ny = script.autofarm_world_to_norm(pos)
                    if nx and ny then
                        local from_x, from_y = autofarm_map_to_screen(nx, ny, map_x, map_y, map_size_i)
                        local to_x, to_y = autofarm_map_to_screen(camp_point.nx, camp_point.ny, map_x, map_y, map_size_i)
                        Render.Line(Vec2(from_x, from_y), Vec2(to_x, to_y), Color(132, 206, 255, 198), 1.2)
                    end
                end
            end
        end
    end
    -- meepo dots (kept)
    if meepos and #meepos > 0 then
        local meepo_icon = autofarm_get_image_handle("panorama/images/heroes/icons/npc_dota_hero_meepo_png.vtex_c")
        local meepo_icon_size = math.max(10, math.floor(14 * scale))
        local meepo_icon_half = meepo_icon_size * 0.5
        for i = 1, #meepos do
            local meepo = meepos[i]
            if meepo and Entity.IsAlive(meepo) then
                local pos = safe_call(Entity.GetAbsOrigin, meepo)
                local nx, ny = script.autofarm_world_to_norm(pos)
                if nx and ny then
                    local sx, sy = autofarm_map_to_screen(nx, ny, map_x, map_y, map_size_i)
                    local is_main = (meepo == local_hero)
                    local col = is_main and Color(255, 210, 120, 245) or Color(125, 215, 255, 235)
                    if meepo_icon and Render.Image then
                        Render.Image(meepo_icon, Vec2(sx - meepo_icon_half, sy - meepo_icon_half), Vec2(meepo_icon_size, meepo_icon_size), col, 2)
                    else
                        if Render.Circle then
                            Render.Circle(Vec2(sx, sy), math.max(3, marker_radius_base - 4), col, 2.0)
                        end
                        Render.FilledRect(Vec2(sx - 1, sy - 1), Vec2(sx + 1, sy + 1), col, 1, Enum.DrawFlags.RoundCornersAll)
                    end
                end
            end
        end
    end
    -- ally/enemy hero icons on map (excluding meepo units, already drawn above)
    do
        local heroes = (Heroes and Heroes.GetAll and safe_call(Heroes.GetAll)) or {}
        local local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
        local hero_icon_size = math.max(9, math.floor(12 * scale))
        local hero_icon_half = hero_icon_size * 0.5
        for i = 1, #heroes do
            local hero = heroes[i]
            if hero and Entity.IsAlive(hero) and not is_meepo_instance(hero) and safe_call(NPC.IsIllusion, hero) ~= true then
                local pos = safe_call(Entity.GetAbsOrigin, hero)
                local nx, ny = script.autofarm_world_to_norm(pos)
                if nx and ny then
                    local sx, sy = autofarm_map_to_screen(nx, ny, map_x, map_y, map_size_i)
                    local team = tonumber(safe_call(Entity.GetTeamNum, hero) or -1) or -1
                    local is_ally = (local_team < 0) or (team == local_team)
                    local tint = is_ally and Color(115, 220, 255, 245) or Color(255, 118, 118, 245)
                    local unit_name = safe_call(NPC.GetUnitName, hero)
                    local icon_path = unit_name and ("panorama/images/heroes/icons/" .. tostring(unit_name) .. "_png.vtex_c") or nil
                    local hero_icon = icon_path and autofarm_get_image_handle(icon_path) or nil
                    if hero_icon and Render.Image then
                        Render.Image(hero_icon, Vec2(sx - hero_icon_half, sy - hero_icon_half), Vec2(hero_icon_size, hero_icon_size), tint, 2)
                    elseif Render.Circle then
                        Render.Circle(Vec2(sx, sy), math.max(3, hero_icon_half - 2), tint, 2.2)
                    end
                end
            end
        end
    end
    -- wave circles (clickable visual markers)
    for i = 1, #wave_markers do
        local wave = wave_markers[i]
        local sx, sy = autofarm_map_to_screen(wave.nx, wave.ny, map_x, map_y, map_size_i)
        local selected = wave_selected[wave.id] == true
        local hovered = hovered_wave_id == wave.id
        local radius = wave_radius_base + (selected and 2 or 0) + (hovered and 2 or 0)
        local local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
        local is_ally_wave = (local_team < 0) or (wave.team == local_team)
        local ring = is_ally_wave and Color(105, 235, 190, hovered and 252 or 232) or Color(255, 128, 128, hovered and 252 or 232)
        local fill = is_ally_wave and Color(38, 72, 60, selected and 205 or 150) or Color(78, 38, 42, selected and 205 or 150)
        if Render.Circle then
            Render.Circle(Vec2(sx, sy), radius, ring, 2.8)
        end
        if Render.FilledRect then
            Render.FilledRect(Vec2(sx - (radius - 1), sy - (radius - 1)), Vec2(sx + (radius - 1), sy + (radius - 1)), fill, radius - 1, Enum.DrawFlags.RoundCornersAll)
        end
    end
    -- camp circles with smooth hover/select and color blend
    for i = 1, #points do
        local point = points[i]
        local sx, sy = autofarm_map_to_screen(point.nx, point.ny, map_x, map_y, map_size_i)
        local selected = selected_set[point.id] == true
        local state = anim[point.id] or { scale = 1.0, sel = selected and 1 or 0 }
        local target_sel = selected and 1 or 0
        state.sel = state.sel + (target_sel - state.sel) * 0.18
        local target_scale = 1.0 + (0.12 * state.sel)
        if hovered_point_id == point.id then
            target_scale = target_scale + 0.14
        end
        state.scale = state.scale + (target_scale - state.scale) * 0.18
        anim[point.id] = state

        local radius = marker_radius_base * state.scale
        local base_col = Color(6, 10, 14, 230)
        if point.side == "d" then base_col = Color(10, 14, 20, 230) end

        -- ring color blends smoothly from red -> high-contrast green as state.sel moves 0..1
        local ring_r, ring_g, ring_b = blend_rgb(196, 76, 76, 70, 230, 110, state.sel)
        if hovered_point_id == point.id then
            ring_r = math.min(255, ring_r + 18)
            ring_g = math.min(255, ring_g + 18)
            ring_b = math.min(255, ring_b + 18)
        end
        local ring_color = Color(ring_r, ring_g, ring_b, 250)

        -- keep fill/background constant for on/off; only ring/dot change
        local fill_col = Color(base_col.r + 6, base_col.g + 8, base_col.b + 10, 205)

        local center = Vec2(sx, sy)
        if Render.Circle then
            -- single outline
            Render.Circle(center, radius, ring_color, 4.0)
        end
        -- fill
        if Render.FilledRect then
            local fill_rad = math.max(2, radius - 1)
            Render.FilledRect(
                Vec2(sx - fill_rad, sy - fill_rad),
                Vec2(sx + fill_rad, sy + fill_rad),
                fill_col,
                fill_rad,
                Enum.DrawFlags.RoundCornersAll
            )
        end
        -- mini dot appears only on green/selected state
        if Render.FilledRect and state.sel > 0.55 then
            -- keep hover/selection scaling perfectly in sync with outer ring
            local mini_rad = math.max(4, radius * 0.55)
            local mini_alpha = math.floor(245 * state.sel)
            local mini_col = Color(ring_r, ring_g, ring_b, mini_alpha)
            Render.FilledRect(
                Vec2(sx - mini_rad, sy - mini_rad),
                Vec2(sx + mini_rad, sy + mini_rad),
                mini_col,
                mini_rad,
                Enum.DrawFlags.RoundCornersAll
            )
        end
    end

    local can_click_map = (not input_captured) and (not script._autofarm_map_drag_active)
    if can_click_map and click_once_left and hover_map and cursor_x and cursor_y then
        if hovered_wave_id then
            wave_selected[hovered_wave_id] = not (wave_selected[hovered_wave_id] == true)
        elseif hovered_point_id then
            selected_set[hovered_point_id] = not (selected_set[hovered_point_id] == true)
        end
    end
end

function script.draw_autofarm_world_status(local_hero, meepos, now)
    if not Render or not Render.WorldToScreen or not Render.Text then
        return
    end
    local selected = script.get_autofarm_selected_locations and script.get_autofarm_selected_locations() or {}
    if #selected == 0 then
        return
    end
    local presence = script._autofarm_camp_presence or {}
    local camp_status = script._autofarm_camp_status or {}
    local raw_now_time = tonumber(now or get_game_time() or 0) or 0
    local now_time = get_neutral_clock_time(raw_now_time)
    for i = 1, #selected do
        local camp = selected[i]
        if camp and camp.id then
            local state = presence[camp.id]
            local status_state = camp_status[camp.id]
            local center = (state and state.center) or get_camp_center(camp)
            if center then
                local pos = center + Vector(0, 0, AUTOFARM_CAMP_STATUS_TEXT_OFFSET)
                local screen, visible = Render.WorldToScreen(pos)
                if visible and screen then
                    local status_name = (status_state and status_state.state) or (state and state.status) or "ready"
                    local remembered_ready = status_state and status_state.remembered_ready == true
                    local has = state and state.has == true
                    if status_name == "unseen" and remembered_ready then
                        status_name = "ready"
                    end
                    local label = "Ready"
                    local col = Color(96, 230, 130, 245)
                    if status_name == "unseen" and not has then
                        label = "Ready | Unseen"
                        col = Color(120, 215, 255, 245)
                    elseif not (has or status_name == "ready") then
                        local eta = math.max(0, get_next_neutral_spawn_time(now_time) - now_time)
                        if status_name == "farmed" then
                            label = "Farmed (" .. format_time_short(eta) .. ")"
                            col = Color(255, 170, 95, 240)
                        else
                            label = "Empty (" .. format_time_short(eta) .. ")"
                            col = Color(240, 200, 90, 240)
                        end
                    end
                    Render.Text(font, tactical_font_size, label, Vec2(screen.x - 18, screen.y - tactical_font_size), col)
                end
            end
        end
    end
end
function script.has_meepo_clones()
    local heroes = Heroes.GetAll()
    if not heroes then
        return false
    end
    for _, h in ipairs(heroes) do
        if NPC.IsMeepoClone and NPC.IsMeepoClone(h) then
            return true
        end
    end
    return false
end
