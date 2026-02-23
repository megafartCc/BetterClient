function script.draw_meepo_status_world(meepo, status, color, tactical)
    local pos = Entity.GetAbsOrigin(meepo)
    if not pos then
        return
    end
    local z = NPC.GetHealthBarOffset(meepo) or 0
    pos = pos + Vector(0, 0, z + C.BAR_OFFSET_Z)
    local screen_pos, is_visible = pos:ToScreen()
    if not is_visible then
        return
    end
    local status_text = status or ""
    local tactical_text = (ui.show_tactical:Get() and tactical) and tactical or ""
    local status_size = Render.TextSize(font, font_size, status_text)
    local tactical_size = tactical_text ~= "" and Render.TextSize(font, tactical_font_size, tactical_text) or Vec2(0, 0)
    local text_w = math.max(status_size.x, tactical_size.x)
    local text_h = status_size.y + (tactical_text ~= "" and (tactical_size.y + 2) or 0)
    local padding_x, padding_y = 6, 3
    local bg_pos = Vec2(
        screen_pos.x - text_w / 2 - padding_x,
        screen_pos.y - text_h / 2 - padding_y
    )
    local bg_size = Vec2(
        text_w + padding_x * 2,
        text_h + padding_y * 2
    )
    if Render.FilledRect then
        Render.FilledRect(bg_pos, bg_pos + bg_size, COLORS.bg, 4, Enum.DrawFlags.RoundCornersAll)
    end
    local status_pos = Vec2(
        screen_pos.x - status_size.x / 2,
        screen_pos.y - text_h / 2
    )
    Render.Text(font, font_size, status_text, status_pos, color)
    if tactical_text ~= "" then
        local tactical_pos = Vec2(
            screen_pos.x - tactical_size.x / 2,
            status_pos.y + status_size.y + 2
        )
        Render.Text(font, tactical_font_size, tactical_text, tactical_pos, COLORS.tactical)
    end
end
function script.get_global_override_status()
    init_binds_once()
    if is_combo_active() then
        return "COMBO", COLORS.combo
    end
    if farm_bind and farm_bind.IsToggled then
        local success, is_toggled = pcall(function() return farm_bind:IsToggled() end)
        if success and is_toggled then
            return "FARM", COLORS.farm
        end
    end
    local heroes = Heroes.GetAll()
    if not heroes then
        return nil, nil
    end
    local meepos = {}
    for _, h in ipairs(heroes) do
        if is_meepo_instance(h) and Entity.IsAlive(h) then
            table.insert(meepos, h)
        end
    end
    if #meepos < 2 then
        return nil, nil
    end
    local attacking_count = 0
    local enemy_near_count = 0
    for _, meepo in ipairs(meepos) do
        if NPC.IsAttacking(meepo) then
            attacking_count = attacking_count + 1
        end
        local enemies = Entity.GetHeroesInRadius(meepo, C.ENEMY_RADIUS, Enum.TeamType.TEAM_ENEMY, false, true)
        if enemies and #enemies > 0 then
            enemy_near_count = enemy_near_count + 1
        end
    end
    if attacking_count >= math.ceil(#meepos * 0.8) and enemy_near_count >= math.ceil(#meepos * 0.6) then
        return "COMBO", COLORS.combo
    end
    if attacking_count >= math.ceil(#meepos * 0.8) and enemy_near_count < math.ceil(#meepos * 0.2) then
        return "FARM", COLORS.farm
    end
    return nil, nil
end
function script.draw_meepo_status_portrait(order_index, status, color, tactical)
    local screen_size = Render.ScreenSize()
    local base_x = screen_size.x * (C.PORTRAIT_X_PCT / 100.0)
    local base_y = screen_size.y * (C.PORTRAIT_Y_PCT / 100.0)
    local step_y = screen_size.y * (C.PORTRAIT_STEP_Y_PCT / 100.0)
    local center = Vec2(base_x, base_y + step_y * (order_index - 1))
    local status_text = status or ""
    local tactical_text = (ui.show_tactical:Get() and tactical) and tactical or ""
    local status_size = Render.TextSize(font, font_size, status_text)
    local tactical_size = tactical_text ~= "" and Render.TextSize(font, tactical_font_size, tactical_text) or Vec2(0, 0)
    local text_w = math.max(status_size.x, tactical_size.x)
    local text_h = status_size.y + (tactical_text ~= "" and (tactical_size.y + 2) or 0)
    local padding_x, padding_y = 6, 3
    local bg_pos = Vec2(
        center.x - text_w / 2 - padding_x,
        center.y - text_h / 2 - padding_y
    )
    local bg_size = Vec2(
        text_w + padding_x * 2,
        text_h + padding_y * 2
    )
    if Render.FilledRect then
        Render.FilledRect(bg_pos, bg_pos + bg_size, COLORS.bg, 4, Enum.DrawFlags.RoundCornersAll)
    end
    local status_pos = Vec2(
        center.x - status_size.x / 2,
        center.y - text_h / 2
    )
    Render.Text(font, font_size, status_text, status_pos, color)
    if tactical_text ~= "" then
        local tactical_pos = Vec2(
            center.x - tactical_size.x / 2,
            status_pos.y + status_size.y + 2
        )
        Render.Text(font, tactical_font_size, tactical_text, tactical_pos, COLORS.tactical)
    end
end
local function build_floating_panel_units(local_hero, meepos)
    local out = {}
    local seen = {}
    local main = get_main_meepo(local_hero)
    if main and is_meepo_instance(main) then
        local key = get_entity_key(main)
        seen[key] = true
        out[#out + 1] = main
    end
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and is_meepo_instance(meepo) then
            local key = get_entity_key(meepo)
            if not seen[key] then
                seen[key] = true
                out[#out + 1] = meepo
            end
        end
    end
    table.sort(out, function(a, b)
        local a_main = (a == main)
        local b_main = (b == main)
        if a_main ~= b_main then
            return a_main
        end
        local ai = tonumber(get_entity_key(a) or 0) or 0
        local bi = tonumber(get_entity_key(b) or 0) or 0
        return ai < bi
    end)
    return out
end
function script.draw_floating_meepo_panel(local_hero, meepos, now)
    if not ui.float_panel_enable:Get() then
        return
    end
    if not meepos or #meepos == 0 then
        return
    end
    if not Render or not Render.Text or not Render.FilledRect or not Render.TextSize then
        return
    end
    local panel_units = build_floating_panel_units(local_hero, meepos)
    if #panel_units == 0 then
        return
    end
    local function get_ui_number(widget, fallback)
        if widget and widget.Get then
            local ok, value = pcall(function()
                return widget:Get()
            end)
            if ok and value ~= nil then
                return tonumber(value) or fallback
            end
        end
        return fallback
    end
    local scale = get_ui_number(ui.float_panel_scale, 100) / 100.0
    if scale < 0.6 then
        scale = 0.6
    elseif scale > 2.2 then
        scale = 2.2
    end
    local slider_x = get_ui_number(ui.float_panel_x, 28)
    local slider_y = get_ui_number(ui.float_panel_y, 420)
    if script._float_panel_pos_x == nil then
        script._float_panel_pos_x = slider_x
    end
    if script._float_panel_pos_y == nil then
        script._float_panel_pos_y = slider_y
    end
    local px = tonumber(script._float_panel_pos_x) or slider_x
    local py = tonumber(script._float_panel_pos_y) or slider_y
    local panel_w = math.floor(310 * scale)
    local header_h = math.floor(28 * scale)
    local row_h = math.floor(34 * scale)
    local pad = math.max(4, math.floor(6 * scale))
    local panel_h = header_h + pad + (#panel_units * row_h) + pad
    local all_w = math.floor(40 * scale)
    local screen = Render.ScreenSize and Render.ScreenSize() or nil
    if screen then
        local max_x = math.max(0, (tonumber(screen.x) or 0) - panel_w - 2)
        local max_y = math.max(0, (tonumber(screen.y) or 0) - panel_h - 2)
        if px < 0 then
            px = 0
        elseif px > max_x then
            px = max_x
        end
        if py < 0 then
            py = 0
        elseif py > max_y then
            py = max_y
        end
        script._float_panel_pos_x = px
        script._float_panel_pos_y = py
    end
    local mouse1 = get_mouse1_code()
    local click_once_raw = mouse1 and safe_call(Input.IsKeyDownOnce, mouse1) == true
    local mouse_down = mouse1 and safe_call(Input.IsKeyDown, mouse1) == true
    local input_captured = safe_call(Input.IsInputCaptured) == true
    local cursor_x, cursor_y = get_cursor_position()
    local drag_header_w = math.max(20, panel_w - all_w - pad - math.floor(10 * scale))
    local hover_drag_header = cursor_x and cursor_y and safe_call(Input.IsCursorInRect, px, py, drag_header_w, header_h) == true
    if input_captured then
        script._float_panel_drag_active = false
    end
    if (not input_captured) and click_once_raw and hover_drag_header and cursor_x and cursor_y then
        script._float_panel_drag_active = true
        script._float_panel_drag_offset_x = cursor_x - px
        script._float_panel_drag_offset_y = cursor_y - py
    end
    if script._float_panel_drag_active then
        if input_captured or (not mouse_down) or (not cursor_x) or (not cursor_y) then
            script._float_panel_drag_active = false
        else
            local nx = math.floor((cursor_x - (script._float_panel_drag_offset_x or 0)) + 0.5)
            local ny = math.floor((cursor_y - (script._float_panel_drag_offset_y or 0)) + 0.5)
            if screen then
                local max_x = math.max(0, (tonumber(screen.x) or 0) - panel_w - 2)
                local max_y = math.max(0, (tonumber(screen.y) or 0) - panel_h - 2)
                if nx < 0 then
                    nx = 0
                elseif nx > max_x then
                    nx = max_x
                end
                if ny < 0 then
                    ny = 0
                elseif ny > max_y then
                    ny = max_y
                end
            end
            px = nx
            py = ny
            script._float_panel_pos_x = nx
            script._float_panel_pos_y = ny
        end
    end
    local base_bg = Color(10, 14, 22, 210)
    local border = Color(70, 120, 210, 220)
    local header_bg = Color(20, 28, 42, 235)
    local row_bg = Color(20, 26, 38, 180)
    local row_hover_bg = Color(34, 47, 68, 215)
    local row_sel_bg = Color(44, 66, 96, 225)
    local dead_row = Color(42, 26, 26, 200)
    local hp_col = Color(90, 215, 120, 255)
    local mp_col = Color(90, 150, 255, 255)
    local bar_bg = Color(30, 34, 44, 220)
    Render.FilledRect(Vec2(px, py), Vec2(px + panel_w, py + panel_h), base_bg, 6, Enum.DrawFlags.RoundCornersAll)
    if Render.Rect then
        Render.Rect(Vec2(px, py), Vec2(px + panel_w, py + panel_h), border, 6, Enum.DrawFlags.RoundCornersAll, 1.0)
    end
    Render.FilledRect(Vec2(px, py), Vec2(px + panel_w, py + header_h), header_bg, 6, Enum.DrawFlags.RoundCornersAll)
    local title = "MEEPO CONTROL"
    Render.Text(font, tactical_font_size, title, Vec2(px + pad, py + math.floor((header_h - tactical_font_size) * 0.5)), Color(220, 235, 255, 245))
    local local_player = safe_call(Players.GetLocal)
    local selected_set = {}
    local selected_count = 0
    if local_player and Player and Player.GetSelectedUnits then
        local selected_units = safe_call(Player.GetSelectedUnits, local_player) or {}
        for i = 1, #selected_units do
            local u = selected_units[i]
            if u and is_meepo_instance(u) and Entity.IsAlive(u) then
                selected_set[get_entity_key(u)] = true
                selected_count = selected_count + 1
            end
        end
    end
    local right_info = string.format("SEL %d/%d", selected_count, #panel_units)
    local right_size = Render.TextSize(font, tactical_font_size, right_info)
    Render.Text(font, tactical_font_size, right_info, Vec2(px + panel_w - right_size.x - pad - math.floor(44 * scale), py + math.floor((header_h - tactical_font_size) * 0.5)), Color(170, 200, 255, 230))
    local all_x1 = px + panel_w - all_w - pad
    local all_y1 = py + math.floor((header_h - math.floor(18 * scale)) * 0.5)
    local all_x2 = all_x1 + all_w
    local all_y2 = all_y1 + math.floor(18 * scale)
    local hover_all = safe_call(Input.IsCursorInRect, all_x1, all_y1, all_w, all_y2 - all_y1) == true
    local all_color = hover_all and Color(90, 160, 255, 240) or Color(64, 108, 176, 230)
    Render.FilledRect(Vec2(all_x1, all_y1), Vec2(all_x2, all_y2), all_color, 4, Enum.DrawFlags.RoundCornersAll)
    Render.Text(font, tactical_font_size, "ALL", Vec2(all_x1 + math.floor(8 * scale), all_y1 + math.floor(1 * scale)), Color(245, 252, 255, 245))
    local click_select_enabled = ui.float_panel_click_select:Get()
    local allow_click_actions = click_select_enabled and click_once_raw and (not input_captured) and (not script._float_panel_drag_active)
    if allow_click_actions and local_player and hover_all then
        local alive_units = {}
        for i = 1, #panel_units do
            if Entity.IsAlive(panel_units[i]) then
                alive_units[#alive_units + 1] = panel_units[i]
            end
        end
        if #alive_units > 0 then
            ensure_combo_units_selected(local_player, alive_units)
        end
    end
    local main_unit = get_main_meepo(local_hero)
    local clone_num = 0
    local start_y = py + header_h + pad
    local btn_w = math.floor(44 * scale)
    local btn_pad = math.floor(6 * scale)
    for i = 1, #panel_units do
        local meepo = panel_units[i]
        local is_alive = Entity.IsAlive(meepo)
        local is_main = (meepo == main_unit)
        local key = get_entity_key(meepo)
        local is_selected = selected_set[key] == true
        if not is_main then
            clone_num = clone_num + 1
        end
        local row_x1 = px + pad
        local row_y1 = start_y + ((i - 1) * row_h)
        local row_x2 = px + panel_w - pad
        local row_y2 = row_y1 + row_h - 1
        local hover_row = safe_call(Input.IsCursorInRect, row_x1, row_y1, row_x2 - row_x1, row_h - 1) == true
        local row_color = row_bg
        if not is_alive then
            row_color = dead_row
        elseif is_selected then
            row_color = row_sel_bg
        elseif hover_row then
            row_color = row_hover_bg
        end
        Render.FilledRect(Vec2(row_x1, row_y1), Vec2(row_x2, row_y2), row_color, 4, Enum.DrawFlags.RoundCornersAll)
        local badge = is_main and "M" or tostring(clone_num)
        local badge_color = is_main and Color(255, 210, 120, 245) or Color(150, 210, 255, 240)
        Render.Text(font, tactical_font_size, badge, Vec2(row_x1 + math.floor(8 * scale), row_y1 + math.floor(2 * scale)), badge_color)
        local hp_pct = get_health_pct(meepo)
        local mp_pct = get_mana_pct(meepo)
        local info = string.format("%s  HP %d%%  MP %d%%", is_main and "MAIN" or "CLONE", round_int(hp_pct), round_int(mp_pct))
        Render.Text(font, tactical_font_size, info, Vec2(row_x1 + math.floor(24 * scale), row_y1 + math.floor(2 * scale)), Color(230, 236, 245, is_alive and 240 or 170))
        local bar_x1 = row_x1 + math.floor(24 * scale)
        local bar_x2 = row_x2 - btn_w - btn_pad - math.floor(4 * scale)
        local bar_w = math.max(10, bar_x2 - bar_x1)
        local hp_w = math.floor(bar_w * math.max(0, math.min(100, hp_pct)) / 100.0)
        local mp_w = math.floor(bar_w * math.max(0, math.min(100, mp_pct)) / 100.0)
        local hp_y = row_y1 + math.floor(16 * scale)
        local mp_y = row_y1 + math.floor(23 * scale)
        local bar_h = math.max(2, math.floor(5 * scale))
        Render.FilledRect(Vec2(bar_x1, hp_y), Vec2(bar_x1 + bar_w, hp_y + bar_h), bar_bg, 2, Enum.DrawFlags.RoundCornersAll)
        if hp_w > 0 then
            Render.FilledRect(Vec2(bar_x1, hp_y), Vec2(bar_x1 + hp_w, hp_y + bar_h), hp_col, 2, Enum.DrawFlags.RoundCornersAll)
        end
        Render.FilledRect(Vec2(bar_x1, mp_y), Vec2(bar_x1 + bar_w, mp_y + bar_h), bar_bg, 2, Enum.DrawFlags.RoundCornersAll)
        if mp_w > 0 then
            Render.FilledRect(Vec2(bar_x1, mp_y), Vec2(bar_x1 + mp_w, mp_y + bar_h), mp_col, 2, Enum.DrawFlags.RoundCornersAll)
        end
        local btn_x1 = row_x2 - btn_w - btn_pad
        local btn_y1 = row_y1 + math.floor(6 * scale)
        local btn_h = math.floor(20 * scale)
        local btn_x2 = btn_x1 + btn_w
        local btn_y2 = btn_y1 + btn_h
        local hover_btn = safe_call(Input.IsCursorInRect, btn_x1, btn_y1, btn_w, btn_h) == true
        local btn_col = hover_btn and Color(86, 154, 255, 240) or Color(62, 110, 190, 230)
        Render.FilledRect(Vec2(btn_x1, btn_y1), Vec2(btn_x2, btn_y2), btn_col, 3, Enum.DrawFlags.RoundCornersAll)
        Render.Text(font, tactical_font_size, "SEL", Vec2(btn_x1 + math.floor(8 * scale), btn_y1 + math.floor(2 * scale)), Color(250, 252, 255, 245))
        if allow_click_actions and local_player and is_alive and (hover_row or hover_btn) then
            ensure_combo_units_selected(local_player, { meepo })
        end
    end
end
function clamp_value(v, min_v, max_v)
    if v < min_v then
        return min_v
    end
    if v > max_v then
        return max_v
    end
    return v
end
function clamp01(v)
    return clamp_value(v, 0, 1)
end
function autofarm_get_ui_number(widget, fallback)
    if widget and widget.Get then
        local ok, value = pcall(function()
            return widget:Get()
        end)
        if ok and value ~= nil then
            return tonumber(value) or fallback
        end
    end
    return fallback
end
function autofarm_get_image_handle(path)
    if not path or path == "" then
        return nil
    end
    local cache = script._autofarm_image_cache or {}
    script._autofarm_image_cache = cache
    local cached = cache[path]
    if cached ~= nil then
        if cached == false then
            return nil
        end
        return cached
    end
    local handle = nil
    if Render and Render.LoadImage then
        handle = safe_call(Render.LoadImage, path)
    end
    if handle then
        cache[path] = handle
    else
        cache[path] = false
    end
    return handle
end
function autofarm_get_map_image()
    for i = 1, #AUTOFARM_MAP_TEXTURES do
        local handle = autofarm_get_image_handle(AUTOFARM_MAP_TEXTURES[i])
        if handle then
            return handle
        end
    end
    return nil
end
function autofarm_map_to_screen(nx, ny, map_x, map_y, map_size)
    local px = map_x + (clamp01(nx or 0) * map_size)
    local py = map_y + ((1 - clamp01(ny or 0)) * map_size)
    return px, py
end
function autofarm_screen_to_map(cursor_x, cursor_y, map_x, map_y, map_size)
    if map_size <= 0 then
        return nil, nil
    end
    local nx = (cursor_x - map_x) / map_size
    local ny = 1 - ((cursor_y - map_y) / map_size)
    if nx < 0 or nx > 1 or ny < 0 or ny > 1 then
        return nil, nil
    end
    return clamp01(nx), clamp01(ny)
end
function script.autofarm_world_to_norm(pos)
    if not pos then
        return nil, nil
    end
    local span = AUTOFARM_WORLD_MAX - AUTOFARM_WORLD_MIN
    if span <= 0 then
        return nil, nil
    end
    local nx = ((pos.x or 0) - AUTOFARM_WORLD_MIN) / span
    local ny = ((pos.y or 0) - AUTOFARM_WORLD_MIN) / span
    return clamp01(nx), clamp01(ny)
end
function script.autofarm_norm_to_world(nx, ny, z)
    local span = AUTOFARM_WORLD_MAX - AUTOFARM_WORLD_MIN
    local wx = AUTOFARM_WORLD_MIN + (clamp01(nx or 0) * span)
    local wy = AUTOFARM_WORLD_MIN + (clamp01(ny or 0) * span)
    return Vector(wx, wy, z or 0)
end
function script.get_autofarm_camp_points(now)
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local cached = script._autofarm_camp_cache
    local cached_time = tonumber(script._autofarm_camp_cache_time or -9999) or -9999
    if cached and #cached > 0 and (now_time - cached_time) <= AUTOFARM_CAMP_CACHE_TTL then
        return cached
    end
    local points = {}
    local camps = (Camps and Camps.GetAll) and safe_call(Camps.GetAll) or nil
    if camps then
        for i = 1, #camps do
            local camp = camps[i]
            local pos = camp and safe_call(Entity.GetAbsOrigin, camp) or nil
            if pos then
                local nx, ny = script.autofarm_world_to_norm(pos)
                if nx and ny then
                    local idx = tonumber(safe_call(Entity.GetIndex, camp) or i) or i
                    local side = (((pos.x or 0) + (pos.y or 0)) < 0) and "r" or "d"
                    local camp_type = (Camp and Camp.GetType) and (tonumber(safe_call(Camp.GetType, camp) or -1) or -1) or -1
                    local camp_box_raw = (Camp and Camp.GetCampBox) and safe_call(Camp.GetCampBox, camp) or nil
                    local camp_box = nil
                    if camp_box_raw and camp_box_raw.min and camp_box_raw.max then
                        camp_box = {
                            min = Vector(
                                camp_box_raw.min.x or 0,
                                camp_box_raw.min.y or 0,
                                camp_box_raw.min.z or 0
                            ),
                            max = Vector(
                                camp_box_raw.max.x or 0,
                                camp_box_raw.max.y or 0,
                                camp_box_raw.max.z or 0
                            ),
                        }
                    end
                    points[#points + 1] = {
                        id = "camp_" .. tostring(idx),
                        label = "",
                        nx = nx,
                        ny = ny,
                        side = side,
                        world = Vector(pos.x or 0, pos.y or 0, pos.z or 0),
                        camp_index = idx,
                        camp_type = camp_type,
                        camp_box = camp_box,
                        preset = true,
                    }
                end
            end
        end
    end
    if #points > 0 then
        table.sort(points, function(a, b)
            local a_side = tostring(a.side or "")
            local b_side = tostring(b.side or "")
            if a_side ~= b_side then
                return a_side < b_side
            end
            local ai = tonumber(a.camp_index or 0) or 0
            local bi = tonumber(b.camp_index or 0) or 0
            return ai < bi
        end)
        local r_count = 0
        local d_count = 0
        for i = 1, #points do
            local point = points[i]
            if point.side == "r" then
                r_count = r_count + 1
                point.label = "R" .. tostring(r_count)
            else
                d_count = d_count + 1
                point.label = "D" .. tostring(d_count)
            end
        end
    else
        for i = 1, #AUTOFARM_FALLBACK_CAMPS do
            local fallback = AUTOFARM_FALLBACK_CAMPS[i]
            points[#points + 1] = {
                id = fallback.id,
                label = fallback.label,
                nx = fallback.nx,
                ny = fallback.ny,
                side = fallback.side,
                world = fallback.world or script.autofarm_norm_to_world(fallback.nx, fallback.ny, 0),
                preset = true,
            }
        end
    end
    script._autofarm_camp_cache = points
    script._autofarm_camp_cache_time = now_time
    return points
end
function get_all_autofarm_points()
    return script.get_autofarm_camp_points and script.get_autofarm_camp_points() or {}
end
function script.get_autofarm_selected_locations()
    local selected = script._autofarm_selected_points or {}
    local out = {}
    local camps = script.get_autofarm_camp_points and script.get_autofarm_camp_points() or {}
    -- If nothing selected after a reload, auto-select the stored side (defaults to Radiant)
    if next(selected) == nil and #camps > 0 then
        local side = script._autofarm_settings_side or "r"
        for i = 1, #camps do
            local point = camps[i]
            if point and point.id and point.side and point.side == side then
                selected[point.id] = true
            end
        end
        script._autofarm_selected_points = selected
    end
    for i = 1, #camps do
        local point = camps[i]
        if selected[point.id] == true then
            out[#out + 1] = {
                id = point.id,
                label = point.label,
                world = point.world or script.autofarm_norm_to_world(point.nx, point.ny, 0),
                nx = point.nx,
                ny = point.ny,
                side = point.side,
                camp_index = point.camp_index,
                camp_type = point.camp_type,
                camp_box = point.camp_box,
                preset = true,
            }
        end
    end
    return out
end
local function is_pos_in_box(pos, box)
    if not pos or not box or not box.min or not box.max then
        return false
    end
    return (pos.x or 0) >= (box.min.x or 0)
        and (pos.x or 0) <= (box.max.x or 0)
        and (pos.y or 0) >= (box.min.y or 0)
        and (pos.y or 0) <= (box.max.y or 0)
end
local function get_camp_center(camp)
    if not camp then
        return nil
    end
    if camp.camp_box and camp.camp_box.min and camp.camp_box.max then
        return Vector(
            ((camp.camp_box.min.x or 0) + (camp.camp_box.max.x or 0)) * 0.5,
            ((camp.camp_box.min.y or 0) + (camp.camp_box.max.y or 0)) * 0.5,
            ((camp.camp_box.min.z or 0) + (camp.camp_box.max.z or 0)) * 0.5
        )
    end
    return camp.world or script.autofarm_norm_to_world(camp.nx, camp.ny, 0)
end
local function get_camp_offset_point(camp, from_pos, distance)
    local center = get_camp_center(camp)
    if not center then
        return nil
    end
    local dir_x = 1
    local dir_y = 0
    if from_pos then
        local dx = (from_pos.x or 0) - (center.x or 0)
        local dy = (from_pos.y or 0) - (center.y or 0)
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0.001 then
            dir_x = dx / len
            dir_y = dy / len
        end
    end
    local dist = tonumber(distance or AUTOFARM_SPAWN_CLEAR_DISTANCE) or AUTOFARM_SPAWN_CLEAR_DISTANCE
    if camp and camp.camp_box and camp.camp_box.min and camp.camp_box.max then
        local half_x = math.abs((camp.camp_box.max.x or 0) - (camp.camp_box.min.x or 0)) * 0.5
        local half_y = math.abs((camp.camp_box.max.y or 0) - (camp.camp_box.min.y or 0)) * 0.5
        local min_clear = math.max(half_x, half_y) + 420
        if dist < min_clear then
            dist = min_clear
        end
    end
    local perp_x = -dir_y
    local perp_y = dir_x
    local function make_ground_pos(x, y, fallback_z)
        local px = clamp_value(tonumber(x or 0) or 0, AUTOFARM_WORLD_MIN, AUTOFARM_WORLD_MAX)
        local py = clamp_value(tonumber(y or 0) or 0, AUTOFARM_WORLD_MIN, AUTOFARM_WORLD_MAX)
        local pz = tonumber(fallback_z or 0) or 0
        if World and World.GetGroundZ then
            local gz = tonumber(safe_call(World.GetGroundZ, px, py))
            if gz then
                pz = gz
            end
        end
        return Vector(px, py, pz)
    end
    local function is_traversable_pos(pos)
        if not pos then
            return false
        end
        if GridNav and GridNav.IsTraversable then
            local traversable = safe_call(GridNav.IsTraversable, pos)
            if traversable ~= nil then
                return traversable == true
            end
        end
        return true
    end
    local function is_reachable_pos(from_pos_local, to_pos)
        if not to_pos then
            return false
        end
        if from_pos_local and GridNav and GridNav.IsTraversableFromTo then
            local reachable = safe_call(GridNav.IsTraversableFromTo, from_pos_local, to_pos, false)
            if reachable ~= nil then
                return reachable == true
            end
        end
        return is_traversable_pos(to_pos)
    end
    local lateral_scales = { 0, 0.25, -0.25, 0.45, -0.45, 0.70, -0.70, 1.0, -1.0 }
    local distance_scales = { 1.0, 1.15, 1.32 }
    local direction_scales = { 1.0, -1.0 }
    local origin = from_pos or center
    local fallback_traversable = nil
    for d_i = 1, #distance_scales do
        local base_dist = dist * distance_scales[d_i]
        for dir_i = 1, #direction_scales do
            local d_sign = direction_scales[dir_i]
            local base_x = dir_x * base_dist * d_sign
            local base_y = dir_y * base_dist * d_sign
            for l_i = 1, #lateral_scales do
                local lat = lateral_scales[l_i]
                local x = (center.x or 0) + base_x + (perp_x * base_dist * lat)
                local y = (center.y or 0) + base_y + (perp_y * base_dist * lat)
                local pos = make_ground_pos(x, y, center.z or 0)
                if pos and not (camp and camp.camp_box and is_pos_in_box(pos, camp.camp_box)) then
                    local traversable = is_traversable_pos(pos)
                    if traversable and not fallback_traversable then
                        fallback_traversable = pos
                    end
                    if traversable and is_reachable_pos(origin, pos) then
                        return pos
                    end
                end
            end
        end
    end
    if fallback_traversable then
        return fallback_traversable
    end
    return nil
end
local function format_time_short(seconds)
    if not seconds or seconds < 0 then
        return "0:00"
    end
    local s = math.floor(seconds + 0.5)
    local m = math.floor(s / 60)
    local r = s - (m * 60)
    return string.format("%d:%02d", m, r)
end
function script.autofarm_camp_has_creeps(camp)
    local center = get_camp_center(camp)
    if not center then
        return false, {}, nil
    end
    local detect_radius = AUTOFARM_CAMP_DETECT_RADIUS or 760
    local radius_sq = detect_radius * detect_radius
    local creep_flag = Enum and Enum.UnitTypeFlags and Enum.UnitTypeFlags.TYPE_CREEP or nil
    local candidates = {}
    if NPCs and NPCs.GetAll then
        candidates = creep_flag and (safe_call(NPCs.GetAll, creep_flag) or {}) or (safe_call(NPCs.GetAll) or {})
    end
    local found = {}
    for i = 1, #candidates do
        local npc = candidates[i]
        if npc and Entity.IsAlive(npc) and (NPC.IsNeutral and safe_call(NPC.IsNeutral, npc) == true) then
            if safe_call(Entity.IsDormant, npc) ~= true and safe_call(NPC.IsWaitingToSpawn, npc) ~= true then
                local pos = safe_call(Entity.GetAbsOrigin, npc)
                if pos then
                    local inside = false
                    if camp and camp.camp_box then
                        inside = is_pos_in_box(pos, camp.camp_box)
                    else
                        local dx = (pos.x or 0) - (center.x or 0)
                        local dy = (pos.y or 0) - (center.y or 0)
                        inside = (dx * dx + dy * dy) <= radius_sq
                    end
                    if inside then
                        found[#found + 1] = npc
                    end
                end
            end
        end
    end
    return #found > 0, found, center
end
function clear_autofarm_runtime_state()
    script._autofarm_assignment_by_meepo = {}
    script._autofarm_last_camp_by_meepo = {}
    script._autofarm_last_poof_move_by_meepo = {}
    script._autofarm_stack_state_by_meepo = {}
    script._autofarm_last_order_by_meepo = {}
    script._autofarm_camp_presence = {}
    script._autofarm_camp_status = {}
    script._autofarm_camp_cooldown_until = {}
    script._autofarm_empty_since = {}
    script._autofarm_last_game_time = nil
    script._autofarm_next_tick = 0
end
local function get_next_neutral_spawn_time(now_time)
    local t = tonumber(now_time or 0) or 0
    return (math.floor(t / 60) + 1) * 60
end
local function get_neutral_clock_time(fallback_time)
    local t = tonumber(fallback_time or 0) or 0
    if GameRules then
        if GameRules.GetDOTATime then
            local dt = tonumber(safe_call(GameRules.GetDOTATime, false, false))
            if dt and dt > -600 and dt < 20000 then
                return dt
            end
            dt = tonumber(safe_call(GameRules.GetDOTATime, false, true))
            if dt and dt > -600 and dt < 20000 then
                return dt
            end
        end
        if GameRules.GetGameTime then
            local gt = tonumber(safe_call(GameRules.GetGameTime))
            if gt then
                return gt
            end
        end
    end
    return t
end
local function get_autofarm_camp_ready_at(camp_id)
    if not camp_id then
        return 0
    end
    local cooldown_until = tonumber((script._autofarm_camp_cooldown_until and script._autofarm_camp_cooldown_until[camp_id]) or 0) or 0
    local status = script._autofarm_camp_status and script._autofarm_camp_status[camp_id] or nil
    local status_ready_at = tonumber(status and status.ready_at or 0) or 0
    local now_time = get_neutral_clock_time(get_game_time and get_game_time() or 0)
    local next_spawn = get_next_neutral_spawn_time(now_time)
    if cooldown_until > next_spawn then
        cooldown_until = next_spawn
    end
    if status_ready_at > next_spawn then
        status_ready_at = next_spawn
    end
    return math.max(cooldown_until, status_ready_at)
end
local function mark_autofarm_camp_state(camp_id, now_time, has_creeps, state_name, reported_by)
    if not camp_id then
        return nil
    end
    script._autofarm_camp_cooldown_until = script._autofarm_camp_cooldown_until or {}
    script._autofarm_camp_status = script._autofarm_camp_status or {}
    local cooldowns = script._autofarm_camp_cooldown_until
    local status_map = script._autofarm_camp_status
    local state = status_map[camp_id] or {}
    local next_spawn = get_next_neutral_spawn_time(now_time)
    local observed_once = state.observed_once == true
    if has_creeps then
        observed_once = true
    elseif reported_by and reported_by ~= "vision" then
        -- direct meepo report (assignment/clear/farm) is a confirmed observation
        observed_once = true
    end
    if has_creeps then
        state.state = "ready"
        state.ready_at = now_time
        state.next_spawn = next_spawn
        state.last_seen_creeps = now_time
        state.last_update = now_time
        if reported_by then
            state.reported_by = reported_by
        end
        cooldowns[camp_id] = 0
    else
        local desired = state_name or "empty"
        if desired == "unseen" and observed_once then
            -- once confirmed at least once, this camp should never go back to unseen
            if state.state == "farmed" then
                desired = "farmed"
            else
                desired = "empty"
            end
        end
        if desired == "ready" then
            state.state = "ready"
            local hold_ready = tonumber(state.ready_at or 0) or 0
            if hold_ready <= 0 then
                hold_ready = now_time
            end
            state.ready_at = hold_ready
            state.next_spawn = next_spawn
            state.last_update = now_time
            if reported_by then
                state.reported_by = reported_by
            end
            cooldowns[camp_id] = 0
        elseif desired == "unseen" then
            state.state = "unseen"
            state.ready_at = now_time
            state.next_spawn = next_spawn
            state.last_update = now_time
            if reported_by then
                state.reported_by = reported_by
            end
            cooldowns[camp_id] = 0
        else
            state.state = desired
            state.ready_at = next_spawn
            state.next_spawn = next_spawn
            state.last_update = now_time
            if reported_by then
                state.reported_by = reported_by
            end
            cooldowns[camp_id] = next_spawn
        end
    end
    state.observed_once = observed_once
    status_map[camp_id] = state
    return state
end
local function force_autofarm_camp_not_ready(camp_id, now_time, state_name, reported_by)
    if not camp_id then
        return nil
    end
    script._autofarm_camp_cooldown_until = script._autofarm_camp_cooldown_until or {}
    script._autofarm_camp_status = script._autofarm_camp_status or {}
    local next_spawn = get_next_neutral_spawn_time(now_time)
    local ready_at = next_spawn
    local state = script._autofarm_camp_status[camp_id] or {}
    state.state = state_name or "empty"
    state.ready_at = ready_at
    state.next_spawn = next_spawn
    state.last_update = now_time
    if reported_by then
        state.reported_by = reported_by
    end
    script._autofarm_camp_status[camp_id] = state
    script._autofarm_camp_cooldown_until[camp_id] = ready_at
    return state
end
local function update_autofarm_camp_presence(selected, now_time)
    script._autofarm_camp_status = script._autofarm_camp_status or {}
    script._autofarm_camp_cooldown_until = script._autofarm_camp_cooldown_until or {}
    local presence = script._autofarm_camp_presence or {}
    local status_map = script._autofarm_camp_status
    local cooldowns = script._autofarm_camp_cooldown_until
    local out = {}
    local active_ids = {}
    local next_spawn_base = get_next_neutral_spawn_time(now_time)
    local meepo_positions = {}
    local meepos = collect_meepos()
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            local pos = safe_call(Entity.GetAbsOrigin, meepo)
            if pos then
                meepo_positions[#meepo_positions + 1] = pos
            end
        end
    end
    for i = 1, #selected do
        local camp = selected[i]
        if camp and camp.id then
            active_ids[camp.id] = true
            local state = presence[camp.id] or {}
            local had_creeps = state.has == true
            local has, creeps, center = script.autofarm_camp_has_creeps(camp)
            local camp_center = center or get_camp_center(camp)
            local prev_status = status_map[camp.id]
            local prev_ready_at = tonumber(prev_status and prev_status.ready_at or 0) or 0
            local observed_once = prev_status and prev_status.observed_once == true
            local can_confirm_empty = false
            if not has and camp_center then
                for j = 1, #meepo_positions do
                    local m_pos = meepo_positions[j]
                    local in_box = camp.camp_box and is_pos_in_box(m_pos, camp.camp_box) or false
                    local close_no_box = (not camp.camp_box) and (vec_dist_2d(m_pos, camp_center) <= (AUTOFARM_POINT_REACH_RADIUS * 0.55))
                    if in_box or close_no_box then
                        can_confirm_empty = true
                        break
                    end
                end
            end
            local desired_state = has and "ready" or "empty"
            if not has then
                local prev_state_name = prev_status and tostring(prev_status.state or "") or ""
                if can_confirm_empty then
                    if prev_state_name == "farmed" or prev_state_name == "empty" then
                        desired_state = prev_state_name
                    else
                        desired_state = "empty"
                    end
                else
                    if prev_state_name == "ready" then
                        desired_state = "ready"
                    elseif prev_state_name == "farmed" or prev_state_name == "empty" then
                        desired_state = prev_state_name
                    elseif (not observed_once) and prev_ready_at > 0 and now_time >= prev_ready_at then
                        desired_state = "unseen"
                    else
                        desired_state = "empty"
                    end
                end
            end
            local camp_state = mark_autofarm_camp_state(camp.id, now_time, has == true, desired_state, "vision")
            state.center = camp_center
            state.last_check = now_time
            if has == true then
                state.has = true
                state.last_seen_creeps = now_time
                state.last_cleared = nil
            else
                state.has = false
                if had_creeps and can_confirm_empty then
                    state.last_cleared = now_time
                end
            end
            local ready_at = tonumber(camp_state and camp_state.ready_at or get_autofarm_camp_ready_at(camp.id)) or 0
            local status_next_spawn = tonumber(camp_state and camp_state.next_spawn or next_spawn_base) or next_spawn_base
            if ready_at <= 0 then
                ready_at = next_spawn_base
            end
            local status_name = camp_state and camp_state.state or (has and "ready" or "empty")
            state.next_spawn = status_next_spawn
            state.ready_at = ready_at
            state.status = status_name
            state.observed_once = camp_state and camp_state.observed_once == true
            presence[camp.id] = state
            out[#out + 1] = {
                camp = camp,
                center = camp_center,
                has = has == true,
                creeps = creeps or {},
                status = status_name,
                ready_at = ready_at,
                next_spawn = status_next_spawn,
                last_cleared = state.last_cleared,
            }
        end
    end
    for id in pairs(presence) do
        if not active_ids[id] then
            presence[id] = nil
        end
    end
    for id in pairs(status_map) do
        if not active_ids[id] then
            status_map[id] = nil
        end
    end
    for id in pairs(cooldowns) do
        if not active_ids[id] then
            cooldowns[id] = nil
        end
    end
    script._autofarm_camp_presence = presence
    script._autofarm_camp_status = status_map
    script._autofarm_camp_cooldown_until = cooldowns
    return out
end
function script.update_autofarm_runtime_toggle(now)
    local master_enabled = ui.autofarm_enable and ui.autofarm_enable.Get and ui.autofarm_enable:Get() == true
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local last_master_enabled = script._autofarm_master_last_enabled == true
    local toggled = false
    if not master_enabled then
        if script._autofarm_runtime_enabled ~= false then
            clear_autofarm_runtime_state()
        end
        script._autofarm_runtime_enabled = false
        script._autofarm_master_last_enabled = false
        return false
    end
    if not last_master_enabled or script._autofarm_runtime_enabled == nil then
        script._autofarm_runtime_enabled = true
    end
    local toggle_pressed = false
    if script.is_bind_just_pressed then
        toggle_pressed = script.is_bind_just_pressed(ui.autofarm_toggle_key, "autofarm_toggle") == true
    elseif script.is_bind_pressed then
        toggle_pressed = script.is_bind_pressed(ui.autofarm_toggle_key) == true
    end
    if toggle_pressed then
        local last_toggle = tonumber(script._autofarm_last_toggle_time or -9999) or -9999
        if (now_time - last_toggle) >= 0.10 then
            script._autofarm_runtime_enabled = not (script._autofarm_runtime_enabled == true)
            script._autofarm_last_toggle_time = now_time
            toggled = true
            if script._autofarm_runtime_enabled ~= true then
                clear_autofarm_runtime_state()
            end
        end
    end
    script._autofarm_master_last_enabled = true
    return toggled
end
local function autofarm_pick_nearest(targets, origin)
    if not targets or #targets == 0 or not origin then
        return nil, nil
    end
    local best = nil
    local best_dist = nil
    for i = 1, #targets do
        local npc = targets[i]
        local pos = npc and safe_call(Entity.GetAbsOrigin, npc) or nil
        local d = pos and vec_dist_2d(pos, origin) or nil
        if d and (not best_dist or d < best_dist) then
            best = npc
            best_dist = d
        end
    end
    return best, best_dist
end
local function autofarm_issue_order(player, meepo, order_type, target, position, label, now_time)
    if not player or not meepo or not Entity.IsAlive(meepo) or not order_type then
        return false
    end
    local meepo_key = get_entity_key(meepo)
    local last_order = tonumber(script._autofarm_last_order_by_meepo[meepo_key] or -9999) or -9999
    if now_time < last_order + AUTOFARM_ORDER_INTERVAL then
        return false
    end
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if not issuer_type or not Player or not Player.PrepareUnitOrders then
        return false
    end
    local issued = pcall(function()
        Player.PrepareUnitOrders(
            player,
            order_type,
            target,
            position,
            nil,
            issuer_type,
            meepo,
            false,
            true,
            true,
            false,
            label or "meepo_autofarm",
            false
        )
    end)
    if issued then
        script._autofarm_last_order_by_meepo[meepo_key] = now_time
        return true
    end
    -- fallback direct issue if PrepareUnitOrders failed
    if order_type == (Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET) and target then
        if NPC and NPC.AttackTarget then
            local ok = safe_call(NPC.AttackTarget, meepo, target, true)
            if ok then
                script._autofarm_last_order_by_meepo[meepo_key] = now_time
                return true
            end
        end
    elseif order_type == (Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION) and position then
        if NPC and NPC.MoveTo then
            local ok = safe_call(NPC.MoveTo, meepo, position)
            if ok then
                script._autofarm_last_order_by_meepo[meepo_key] = now_time
                return true
            end
        end
    end
    return false
end
