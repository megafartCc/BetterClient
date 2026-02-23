local script = {}
script._last_net_cast_pos = script._last_net_cast_pos or nil
script._last_net_cast_time = script._last_net_cast_time or 0
script._combo_net_pending_target_key = script._combo_net_pending_target_key or nil
script._combo_net_pending_end_time = script._combo_net_pending_end_time or 0
script._combo_net_pending_arrival_time = script._combo_net_pending_arrival_time or 0
script._combo_item_sets = script._combo_item_sets or {
    silence = { "item_bloodthorn", "item_orchid" },
    atos = { "item_rod_of_atos", "item_gleipnir" },
    abyssal = { "item_abyssal_blade" },
    purge = { "item_diffusal_blade", "item_disperser" },
    grenade = { "item_grenade" },
    phase = { "item_phase_boots" },
    shadow = { "item_silver_edge", "item_invis_sword" },
    mjollnir = { "item_mjollnir" },
    mom = { "item_mask_of_madness" },
    armlet = { "item_armlet" },
    manta = { "item_manta" },
    blademail = { "item_blade_mail" },
}
script._combo_modifier_sets = script._combo_modifier_sets or {
    hex = { "modifier_sheepstick_debuff" },
    silence = { "modifier_orchid_malevolence_debuff", "modifier_bloodthorn_debuff" },
    atos = { "modifier_rod_of_atos_debuff", "modifier_gleipnir_root" },
}
script._combo_silence_last_global = script._combo_silence_last_global or -9999
script._combo_silence_last_attempt_global = script._combo_silence_last_attempt_global or -9999
script._combo_silence_last_attempt_frame = script._combo_silence_last_attempt_frame or -1
script._combo_silence_last_by_meepo = script._combo_silence_last_by_meepo or {}
script._combo_silence_last_frame_by_meepo = script._combo_silence_last_frame_by_meepo or {}
script._combo_atos_last_global = script._combo_atos_last_global or -9999
script._combo_atos_last_attempt_global = script._combo_atos_last_attempt_global or -9999
script._combo_atos_last_attempt_frame = script._combo_atos_last_attempt_frame or -1
script._combo_atos_last_by_meepo = script._combo_atos_last_by_meepo or {}
script._combo_atos_pending_target_key = script._combo_atos_pending_target_key or nil
script._combo_atos_pending_end_time = script._combo_atos_pending_end_time or 0
script._combo_abyssal_last_global = script._combo_abyssal_last_global or -9999
script._combo_abyssal_last_attempt_global = script._combo_abyssal_last_attempt_global or -9999
script._combo_abyssal_last_attempt_frame = script._combo_abyssal_last_attempt_frame or -1
script._combo_abyssal_last_by_meepo = script._combo_abyssal_last_by_meepo or {}
script._combo_atos_last_frame_by_meepo = script._combo_atos_last_frame_by_meepo or {}
script._combo_abyssal_last_frame_by_meepo = script._combo_abyssal_last_frame_by_meepo or {}
script._combo_abyssal_pending_target_key = script._combo_abyssal_pending_target_key or nil
script._combo_abyssal_pending_end_time = script._combo_abyssal_pending_end_time or 0
script._combo_abyssal_recent_blink_until = script._combo_abyssal_recent_blink_until or 0
script._combo_abyssal_recent_blink_target_key = script._combo_abyssal_recent_blink_target_key or nil
script._combo_abyssal_recent_blink_caster_key = script._combo_abyssal_recent_blink_caster_key or nil
script._combo_hex_last_attempt_global = script._combo_hex_last_attempt_global or -9999
script._combo_hex_last_attempt_frame = script._combo_hex_last_attempt_frame or -1
script._combo_hex_last_frame_by_meepo = script._combo_hex_last_frame_by_meepo or {}
script._combo_purge_last_global = script._combo_purge_last_global or -9999
script._combo_purge_last_target_key = script._combo_purge_last_target_key or nil
script._combo_purge_last_attempt_global = script._combo_purge_last_attempt_global or -9999
script._combo_purge_last_attempt_frame = script._combo_purge_last_attempt_frame or -1
script._combo_purge_last_by_meepo = script._combo_purge_last_by_meepo or {}
script._item_next_allowed_time = script._item_next_allowed_time or {}
script._item_last_frame_by_meepo = script._item_last_frame_by_meepo or {}
script._item_frame_budget_consumed = script._item_frame_budget_consumed or 0
script._cast_next_allowed_time = script._cast_next_allowed_time or {}
script._cast_last_frame_by_meepo = script._cast_last_frame_by_meepo or {}
script.COMBO_PHASE_ABYSSAL = script.COMBO_PHASE_ABYSSAL or "ABYSSAL"
script.COMBO_PHASE_HEX = script.COMBO_PHASE_HEX or "HEX"
script.COMBO_PHASE_NET_CHAIN = script.COMBO_PHASE_NET_CHAIN or "NET_CHAIN"
script.COMBO_PHASE_POOF_ATTACK = script.COMBO_PHASE_POOF_ATTACK or "POOF_ATTACK"
script._combo_state_phase = script._combo_state_phase or script.COMBO_PHASE_ABYSSAL
script._combo_state_target_key = script._combo_state_target_key or nil
script._combo_debug_phase = script._combo_debug_phase or script.COMBO_PHASE_ABYSSAL
script._combo_debug_reason = script._combo_debug_reason or "idle"
script._combo_debug_next_disable = script._combo_debug_next_disable or ""
script._combo_debug_last_emit = script._combo_debug_last_emit or ""
script._combo_last_net_follow_poof_count = script._combo_last_net_follow_poof_count or 0
script._combo_last_net_follow_poof_time = script._combo_last_net_follow_poof_time or -9999
script._combo_last_net_follow_poof_reason = script._combo_last_net_follow_poof_reason or ""
script._combo_net_priority_until = script._combo_net_priority_until or 0
script._combo_net_priority_target_key = script._combo_net_priority_target_key or nil
script._combo_hold_next_order_time = script._combo_hold_next_order_time or 0
script._combo_action_next_order_time = script._combo_action_next_order_time or 0
script._combo_search_next_move_time = script._combo_search_next_move_time or 0
script._combo_search_last_position = script._combo_search_last_position or nil
script._combo_blink_scheduled_time = script._combo_blink_scheduled_time or 0
script._combo_blink_target = script._combo_blink_target or nil
script._combo_blink_anchor = script._combo_blink_anchor or nil
script._combo_blink_target_key = script._combo_blink_target_key or nil
script._combo_blink_last_schedule = script._combo_blink_last_schedule or -9999
script._combo_blink_poof_units = script._combo_blink_poof_units or {}
script._combo_blink_post_poof_delay = script._combo_blink_post_poof_delay or 0
script._combo_blink_poof_prescheduled = script._combo_blink_poof_prescheduled or false
script._combo_blink_retry_deadline = script._combo_blink_retry_deadline or 0
script._combo_blink_next_attempt = script._combo_blink_next_attempt or 0
script._combo_preblink_phase = script._combo_preblink_phase or "idle"
script._combo_preblink_target_key = script._combo_preblink_target_key or nil
script._combo_preblink_anchor_key = script._combo_preblink_anchor_key or nil
script._combo_preblink_poof_sent_time = script._combo_preblink_poof_sent_time or 0
script._combo_preblink_wait_until = script._combo_preblink_wait_until or 0
script._combo_preblink_sent_set = script._combo_preblink_sent_set or {}
script._combo_target_last_seen_time = script._combo_target_last_seen_time or -9999
script._combo_logic_next_tick = script._combo_logic_next_tick or 0
script._combo_armlet_forced_on = script._combo_armlet_forced_on or false
script._tp_interrupt_last_target_key = script._tp_interrupt_last_target_key or nil
script._tp_interrupt_last_time = script._tp_interrupt_last_time or -9999
script._utility_bind_down_state = script._utility_bind_down_state or {}
script._tp_teleport_modifier_candidates = script._tp_teleport_modifier_candidates or {
    "modifier_teleporting",
    "modifier_teleporting_visual",
    "modifier_furion_teleport",
    "modifier_furion_teleporting",
}
script._auto_safe_last_cast_by_meepo = script._auto_safe_last_cast_by_meepo or {}
script._auto_safe_last_enemy_poof_by_meepo = script._auto_safe_last_enemy_poof_by_meepo or {}
script._float_panel_pos_x = script._float_panel_pos_x
script._float_panel_pos_y = script._float_panel_pos_y
script._float_panel_drag_active = script._float_panel_drag_active or false
script._float_panel_drag_offset_x = script._float_panel_drag_offset_x or 0
script._float_panel_drag_offset_y = script._float_panel_drag_offset_y or 0
if script._autofarm_runtime_enabled == nil then
    script._autofarm_runtime_enabled = true
end
script._autofarm_map_pos_x = script._autofarm_map_pos_x
script._autofarm_map_pos_y = script._autofarm_map_pos_y
script._autofarm_map_drag_active = script._autofarm_map_drag_active or false
script._autofarm_map_drag_offset_x = script._autofarm_map_drag_offset_x or 0
script._autofarm_map_drag_offset_y = script._autofarm_map_drag_offset_y or 0
script._autofarm_selected_points = script._autofarm_selected_points or {}
script._autofarm_last_toggle_time = script._autofarm_last_toggle_time or -9999
script._autofarm_image_cache = script._autofarm_image_cache or {}
script._autofarm_camp_cache = script._autofarm_camp_cache or nil
script._autofarm_camp_cache_time = script._autofarm_camp_cache_time or -9999
script._autofarm_assignment_by_meepo = script._autofarm_assignment_by_meepo or {}
script._autofarm_last_camp_by_meepo = script._autofarm_last_camp_by_meepo or {}
script._autofarm_last_poof_move_by_meepo = script._autofarm_last_poof_move_by_meepo or {}
script._autofarm_stack_state_by_meepo = script._autofarm_stack_state_by_meepo or {}
script._autofarm_last_order_by_meepo = script._autofarm_last_order_by_meepo or {}
script._autofarm_camp_presence = script._autofarm_camp_presence or {}
script._autofarm_camp_status = script._autofarm_camp_status or {}
script._autofarm_camp_cooldown_until = script._autofarm_camp_cooldown_until or {}
script._autofarm_last_game_time = script._autofarm_last_game_time
script._autofarm_next_tick = script._autofarm_next_tick or 0
script._autofarm_master_last_enabled = script._autofarm_master_last_enabled or false
script._autofarm_point_anim = script._autofarm_point_anim or {}
script._autofarm_settings_side = script._autofarm_settings_side or "r"
local get_game_time
local safe_call
local get_entity_key
local is_combo_cast_in_progress
local C
safe_call = function(fn, ...)
    if not fn then
        return nil
    end
    local ok, result = pcall(fn, ...)
    if ok then
        return result
    end
    return nil
end
local combo_group = nil
local display_group = nil
local items_group = nil
local abilities_group = nil
local utilities_group = nil
local autofarm_group = nil
local function create_menu_group_safe(parent, name, side)
    if not parent or not parent.Create then
        return nil
    end
    local ok_with_side, created_with_side = pcall(function()
        return parent:Create(name, side)
    end)
    if ok_with_side and created_with_side then
        return created_with_side
    end
    local ok_default, created_default = pcall(function()
        return parent:Create(name)
    end)
    if ok_default then
        return created_default
    end
    return nil
end
if Menu.Create then
    local tab = Menu.Create("Heroes", "Hero List", "Meepo")
    if tab and tab.Create then
        local section = tab:Create("Meepo Panel")
        if section and section.Create then
            combo_group = create_menu_group_safe(section, "\u{041d}\u{0430}\u{0441}\u{0442}\u{0440}\u{043e}\u{0439}\u{043a}\u{0438} \u{0433}\u{0435}\u{0440}\u{043e}\u{044f}", 1)
            utilities_group = create_menu_group_safe(section, "\u{0423}\u{0442}\u{0438}\u{043b}\u{0438}\u{0442}\u{044b}", 1)
            display_group = create_menu_group_safe(section, "Display", 1)
            autofarm_group = create_menu_group_safe(section, "\u{041d}\u{0430}\u{0441}\u{0442}\u{0440}\u{043e}\u{0439}\u{043a}\u{0438} \u{0410}\u{0432}\u{0442}\u{043e}\u{0424}\u{0430}\u{0440}\u{043c}\u{0430}", 1)
            items_group = create_menu_group_safe(section, "\u{041d}\u{0430}\u{0441}\u{0442}\u{0440}\u{043e}\u{0439}\u{043a}\u{0438} \u{043f}\u{0440}\u{0435}\u{0434}\u{043c}\u{0435}\u{0442}\u{043e}\u{0432}", 2)
            abilities_group = create_menu_group_safe(section, "\u{041d}\u{0430}\u{0441}\u{0442}\u{0440}\u{043e}\u{0439}\u{043a}\u{0438} \u{0410}\u{0432}\u{0442}\u{043e}-\u{0421}\u{0435}\u{0439}\u{0432}\u{0430}", 2)
        end
    end
end
local ui = {}
local ICON_DIG = "panorama/images/spellicons/meepo_petrify_png.vtex_c"
local ICON_MEGA = "panorama/images/spellicons/meepo_megameepo_png.vtex_c"
local ICON_POOF = "panorama/images/spellicons/meepo_poof_png.vtex_c"
local ICON_NET = "panorama/images/spellicons/meepo_earthbind_png.vtex_c"
local COMBO_MODE_SELECTED = 0
local COMBO_MODE_ALL = 1
local AUTOFARM_MAP_TEXTURES = {
    "panorama/images/textures/minimap_game_png.vtex_c",
    "panorama/images/textures/minimap_game_psd.vtex_c",
    "panorama/images/minimap/minimap_game_png.vtex_c",
    "panorama/images/minimap/dotamap_png.vtex_c",
    "panorama/images/minimap/dotamap_psd.vtex_c",
    "panorama/images/minimap/dotamap_psd_png.vtex_c",
}
local AUTOFARM_MAP_UV_MIN = Vec2(0.02, 0.02)
local AUTOFARM_MAP_UV_MAX = Vec2(0.98, 0.98)
local AUTOFARM_WORLD_MIN = -8800
local AUTOFARM_WORLD_MAX = 8800
local AUTOFARM_MAX_CUSTOM_POINTS = 24
local AUTOFARM_CAMP_CACHE_TTL = 1.5
local AUTOFARM_LOGIC_TICK = 0.08
local AUTOFARM_ORDER_INTERVAL = 0.20
local AUTOFARM_ASSIGN_LOCK_SEC = 1.35
local AUTOFARM_CAMP_DETECT_RADIUS = 760
local AUTOFARM_CAMP_REACH_RADIUS = 680
local AUTOFARM_POINT_REACH_RADIUS = 280
local AUTOFARM_CAMP_STATUS_TEXT_OFFSET = 64
local AUTOFARM_QUEUE_MAX_TRAVEL = 3600
local AUTOFARM_QUEUE_NEAR_BAND = 1400
local AUTOFARM_RESPAWN_WAIT_WINDOW = 8
local AUTOFARM_RESPAWN_WAIT_BUFFER = 2
local AUTOFARM_TRAVEL_SPEED_ESTIMATE = 360
local AUTOFARM_SPAWN_CLEAR_SECOND = 55
local AUTOFARM_SPAWN_CLEAR_WINDOW = 5.2
local AUTOFARM_SPAWN_CLEAR_DISTANCE = 760
local AUTOFARM_STACK_PREP_SECOND = 54
local AUTOFARM_POOF_MOVE_MIN_DIST = 1850
local AUTOFARM_POOF_MOVE_ADVANTAGE = 1500
local AUTOFARM_POOF_MOVE_RECAST = 3.8
local AUTOFARM_POOF_DAMAGE_RECAST = 3.3
local AUTOFARM_POOF_DAMAGE_MIN_CREEPS = 2
local AUTOFARM_POOF_DAMAGE_RANGE = 340
local AUTOFARM_MANA_MIN_RESERVE = 0
local function autofarm_use_poof_flags()
    local damage = true
    local move = true
    if ui.autofarm_poof_use_move and ui.autofarm_poof_use_move.Get then
        local ok_move, mv = pcall(function()
            return ui.autofarm_poof_use_move:Get()
        end)
        if ok_move and mv ~= nil then
            move = mv == true
        end
    end
    if ui.autofarm_poof_use_damage and ui.autofarm_poof_use_damage.Get then
        local ok_dmg, dm = pcall(function()
            return ui.autofarm_poof_use_damage:Get()
        end)
        if ok_dmg and dm ~= nil then
            damage = dm == true
        end
    end
    if ui.autofarm_poof_use and ui.autofarm_poof_use.Get then
        local ok_move, mv = pcall(function()
            return ui.autofarm_poof_use:Get("move")
        end)
        if ok_move and mv ~= nil then
            move = mv == true
        end
        local ok_dmg, dm = pcall(function()
            return ui.autofarm_poof_use:Get("damage")
        end)
        if ok_dmg and dm ~= nil then
            damage = dm == true
        end
    end
    if ui.autofarm_poof_use and ui.autofarm_poof_use.ListEnabled then
        local ok_list, enabled = pcall(function()
            return ui.autofarm_poof_use:ListEnabled()
        end)
        if ok_list and type(enabled) == "table" then
            local move_found = false
            local damage_found = false
            local recognized_any = false
            for i = 1, #enabled do
                local raw = tostring(enabled[i] or "")
                if raw ~= "" then
                    if raw:find("move", 1, true)
                        or raw:find("Move", 1, true)
                        or raw:find("\u{041f}\u{0435}\u{0440}\u{0435}\u{043c}", 1, true)
                        or raw:find("\u{043f}\u{0435}\u{0440}\u{0435}\u{043c}", 1, true)
                    then
                        move_found = true
                        recognized_any = true
                    end
                    if raw:find("damage", 1, true)
                        or raw:find("Damage", 1, true)
                        or raw:find("\u{0423}\u{0440}\u{043e}\u{043d}", 1, true)
                        or raw:find("\u{0443}\u{0440}\u{043e}\u{043d}", 1, true)
                    then
                        damage_found = true
                        recognized_any = true
                    end
                end
            end
            if recognized_any then
                move = move_found
                damage = damage_found
            end
        end
    end
    return damage, move
end
local AUTOFARM_STACK_TRIGGER_RADIUS = 900
local AUTOFARM_STACK_RETREAT_DELAY = 0.65
local AUTOFARM_STACK_RETREAT_DISTANCE = 1750
local AUTOFARM_STACK_WAIT_OFFSET = 2
local AUTOFARM_LOW_HP_RETREAT_PCT = 7
local AUTOFARM_HEAL_EXIT_PCT = 62
local AUTOFARM_FOUNTAIN_RADIUS = 950
local AUTOFARM_THOUGHT_MAX_AGE = 1.8
local AUTOFARM_FALLBACK_CAMPS = {
    { id = "r_easy_1", label = "R-E1", nx = 0.17, ny = 0.27, side = "r" },
    { id = "r_med_1", label = "R-M1", nx = 0.24, ny = 0.34, side = "r" },
    { id = "r_hard_1", label = "R-H1", nx = 0.30, ny = 0.41, side = "r" },
    { id = "r_med_2", label = "R-M2", nx = 0.18, ny = 0.44, side = "r" },
    { id = "r_hard_2", label = "R-H2", nx = 0.13, ny = 0.55, side = "r" },
    { id = "r_ancient", label = "R-A", nx = 0.22, ny = 0.66, side = "r" },
    { id = "r_top_1", label = "R-T1", nx = 0.07, ny = 0.66, side = "r" },
    { id = "r_top_2", label = "R-T2", nx = 0.28, ny = 0.58, side = "r" },
    { id = "d_easy_1", label = "D-E1", nx = 0.83, ny = 0.73, side = "d" },
    { id = "d_med_1", label = "D-M1", nx = 0.76, ny = 0.66, side = "d" },
    { id = "d_hard_1", label = "D-H1", nx = 0.70, ny = 0.59, side = "d" },
    { id = "d_med_2", label = "D-M2", nx = 0.82, ny = 0.56, side = "d" },
    { id = "d_hard_2", label = "D-H2", nx = 0.87, ny = 0.45, side = "d" },
    { id = "d_ancient", label = "D-A", nx = 0.78, ny = 0.34, side = "d" },
    { id = "d_top_1", label = "D-T1", nx = 0.93, ny = 0.34, side = "d" },
    { id = "d_top_2", label = "D-T2", nx = 0.72, ny = 0.42, side = "d" },
}
local CFG = {
    burger_icon = "\u{f0c9}",
    item_icon_prefix = "panorama/images/items/",
    item_icon_suffix = "_png.vtex_c",
    blink_lead = 0.10,
    blink_recast_delay = 0.30,
    blink_item_candidates = {
        "item_blink",
        "item_swift_blink",
        "item_overwhelming_blink",
        "item_arcane_blink",
    },
    important_items = {
        "item_blink",
        "item_swift_blink",
        "item_overwhelming_blink",
        "item_arcane_blink",
        "item_sheepstick",
        "item_orchid",
        "item_bloodthorn",
        "item_cyclone",
        "item_rod_of_atos",
        "item_gleipnir",
        "item_abyssal_blade",
        "item_diffusal_blade",
        "item_disperser",
        "item_mjollnir",
        "item_mask_of_madness",
        "item_armlet",
        "item_manta",
        "item_blade_mail",
        "item_silver_edge",
        "item_invis_sword",
        "item_phase_boots",
        "item_grenade",
    },
    linken_break_items = {
        "item_orchid",
        "item_bloodthorn",
        "item_sheepstick",
        "item_abyssal_blade",
        "item_rod_of_atos",
        "item_diffusal_blade",
        "item_disperser",
        "item_nullifier",
        "item_heavens_halberd",
        "item_force_staff",
        "item_hurricane_pike",
        "item_cyclone",
        "item_wind_waker",
        "item_ethereal_blade",
        "item_urn_of_shadows",
        "item_spirit_vessel",
        "item_medallion_of_courage",
        "item_solar_crest",
        "item_dagon",
        "item_dagon_2",
        "item_dagon_3",
        "item_dagon_4",
        "item_dagon_5",
    },
}
local item_utils = {}
function item_utils.build_item_icon(item_name)
    if not item_name or item_name == "" then
        return ""
    end
    local icon_name = item_name:gsub("^item_", "")
    return CFG.item_icon_prefix .. icon_name .. CFG.item_icon_suffix
end
function item_utils.build_item_multiselect(items, default_enabled)
    local result = {}
    if not items then
        return result
    end
    for i = 1, #items do
        local name = items[i]
        if name and name ~= "" then
            result[#result + 1] = { name, item_utils.build_item_icon(name), default_enabled == true }
        end
    end
    return result
end
local function try_set_widget_image(widget, image_path)
    if not widget or not widget.Image or not image_path or image_path == "" then
        return
    end
    pcall(function()
        widget:Image(image_path)
    end)
end
local function begin_item_frame_budget()
    script._item_frame_budget_consumed = 0
end
local function get_cast_lock_key(ability, fallback_prefix)
    local name = safe_call(Ability.GetName, ability) or ""
    if name ~= "" then
        return name
    end
    return (fallback_prefix or "cast") .. ":" .. tostring(ability)
end
local function set_combo_action_lock(now, duration)
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local lock_for = tonumber(duration or (C and C.COMBO_ACTION_MIN_INTERVAL) or 0.12) or 0.12
    if lock_for < 0 then
        lock_for = 0
    end
    local next_time = now_time + lock_for
    if next_time > (tonumber(script._combo_action_next_order_time or 0) or 0) then
        script._combo_action_next_order_time = next_time
    end
end
local function is_combo_action_locked(now)
    local now_time = tonumber(now or get_game_time() or 0) or 0
    return now_time < (tonumber(script._combo_action_next_order_time or 0) or 0)
end
function script.is_direct_cast_mode()
    if ui and ui.combo_direct_cast and ui.combo_direct_cast.Get then
        local ok, enabled = pcall(function()
            return ui.combo_direct_cast:Get()
        end)
        if ok then
            return enabled == true
        end
    end
    return true
end
local function cast_target_item_budgeted(meepo, item, target, tag, cast_pos_override)
    if not meepo or not item then
        return false
    end
    if not script.can_cast_target_item_now(meepo, item) then
        return false
    end
    local now = tonumber(get_game_time() or 0) or 0
    local frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    local name = safe_call(Ability.GetName, item) or ""
    local cast_lock_key = get_cast_lock_key(item, "target")
    local is_position_cast = (name == "item_gleipnir")
    local cast_pos = cast_pos_override
    if is_position_cast and not cast_pos and target then
        cast_pos = safe_call(Entity.GetAbsOrigin, target)
    end
    if (not is_position_cast and not target) or (is_position_cast and not cast_pos) then
        return false
    end
    if (not is_position_cast) and target and script.is_target_linkens_protected(target) then
        local caster_team = tonumber(safe_call(Entity.GetTeamNum, meepo) or -1) or -1
        local target_team = tonumber(safe_call(Entity.GetTeamNum, target) or -2) or -2
        local enemy_target = (caster_team < 0 or target_team < 0 or caster_team ~= target_team)
        if enemy_target and not script.is_linken_breaker_item_enabled(name) then
            return false
        end
    end
    if cast_lock_key ~= "" then
        local next_ok = script._cast_next_allowed_time[cast_lock_key] or -9999
        if now < next_ok then
            return false
        end
    end
    if script.is_direct_cast_mode() then
        local action_interval = math.max(
            tonumber(C.ITEM_MIN_INTERVAL_SEC or 0.15) or 0.15,
            tonumber(C.GENERIC_CAST_INTERVAL or 0.18) or 0.18
        )
        local ok = false
        if is_position_cast then
            ok = pcall(function()
                Ability.CastPosition(
                    item,
                    cast_pos,
                    false,
                    true,
                    true,
                    tag or name,
                    false
                )
            end)
        else
            ok = pcall(function()
                Ability.CastTarget(
                    item,
                    target,
                    false,
                    true,
                    true,
                    tag or name,
                    false
                )
            end)
        end
        if ok and cast_lock_key ~= "" then
            script._cast_next_allowed_time[cast_lock_key] = now + action_interval
            set_combo_action_lock(now, action_interval)
        end
        return ok == true
    end
    if frame >= 0 then
        local meepo_key = get_entity_key(meepo)
        local last_frame = script._cast_last_frame_by_meepo[meepo_key] or -1
        if frame == last_frame then
            return false
        end
        script._cast_last_frame_by_meepo[meepo_key] = frame
    end
    local ok = false
    if is_position_cast then
        ok = pcall(function()
            Ability.CastPosition(
                item,
                cast_pos,
                false,
                true,
                true,
                tag or name,
                false
            )
        end)
    else
        ok = pcall(function()
            Ability.CastTarget(
                item,
                target,
                false,
                true,
                true,
                tag or name,
                false
            )
        end)
    end
    if ok and cast_lock_key ~= "" then
        local interval = C.GENERIC_CAST_INTERVAL or 0.18
        script._cast_next_allowed_time[cast_lock_key] = now + interval
        set_combo_action_lock(now, interval)
    end
    return ok == true
end
function script.cast_no_target_item_budgeted(meepo, item, tag)
    if not meepo or not item then
        return false
    end
    local name = safe_call(Ability.GetName, item) or ""
    if name ~= "" and not is_item_enabled(name) then
        return false
    end
    if not can_cast_ability_for_npc(meepo, item) then
        return false
    end
    if safe_call(Ability.IsInAbilityPhase, item) == true then
        return false
    end
    local now = tonumber(get_game_time() or 0) or 0
    local frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    local cast_lock_key = get_cast_lock_key(item, "notarget")
    if cast_lock_key ~= "" then
        local next_ok = script._cast_next_allowed_time[cast_lock_key] or -9999
        if now < next_ok then
            return false
        end
    end
    if script.is_direct_cast_mode() then
        local action_interval = math.max(
            tonumber(C.ITEM_MIN_INTERVAL_SEC or 0.15) or 0.15,
            tonumber(C.GENERIC_CAST_INTERVAL or 0.18) or 0.18
        )
        local ok = pcall(function()
            Ability.CastNoTarget(
                item,
                false,
                true,
                true,
                tag or name
            )
        end)
        if not ok then
            ok = pcall(function()
                Ability.CastNoTarget(item)
            end)
        end
        if ok and cast_lock_key ~= "" then
            script._cast_next_allowed_time[cast_lock_key] = now + action_interval
            set_combo_action_lock(now, action_interval)
        end
        return ok == true
    end
    if frame >= 0 then
        local meepo_key = get_entity_key(meepo)
        local last_frame = script._cast_last_frame_by_meepo[meepo_key] or -1
        if frame == last_frame then
            return false
        end
        script._cast_last_frame_by_meepo[meepo_key] = frame
    end
    local ok = pcall(function()
        Ability.CastNoTarget(
            item,
            false,
            true,
            true,
            tag or name
        )
    end)
    if not ok then
        ok = pcall(function()
            Ability.CastNoTarget(item)
        end)
    end
    if ok and cast_lock_key ~= "" then
        local interval = C.GENERIC_CAST_INTERVAL or 0.18
        script._cast_next_allowed_time[cast_lock_key] = now + interval
        set_combo_action_lock(now, interval)
    end
    return ok == true
end
local function get_default_bind_code()
    if Enum and Enum.ButtonCode then
        if Enum.ButtonCode.BUTTON_CODE_INVALID ~= nil then
            return Enum.ButtonCode.BUTTON_CODE_INVALID
        end
        if Enum.ButtonCode.BUTTON_CODE_NONE ~= nil then
            return Enum.ButtonCode.BUTTON_CODE_NONE
        end
    end
    return nil
end
local function create_bind_safe(group, bind_name, icon)
    if not group or not group.Bind then
        return nil
    end
    local default_code = get_default_bind_code()
    if default_code ~= nil then
        local ok_with_code, bind_with_code = pcall(function()
            if icon ~= nil then
                return group:Bind(bind_name, default_code, icon)
            end
            return group:Bind(bind_name, default_code)
        end)
        if ok_with_code and bind_with_code then
            return bind_with_code
        end
    end
    local ok_default, bind_default = pcall(function()
        if icon ~= nil then
            return group:Bind(bind_name, nil, icon)
        end
        return group:Bind(bind_name)
    end)
    if ok_default and bind_default then
        return bind_default
    end
    return nil
end
local has_combo_group = combo_group and combo_group.Switch and combo_group.Bind and combo_group.Combo and combo_group.Slider
local has_display_group = display_group and display_group.Switch and display_group.Slider
local has_abilities_group = abilities_group and abilities_group.Switch and abilities_group.Slider
local has_utilities_group = utilities_group and utilities_group.Bind
local has_items_group = items_group and items_group.Label
local has_autofarm_group = autofarm_group and autofarm_group.Switch and autofarm_group.Bind and autofarm_group.Slider
if has_combo_group and has_display_group and has_abilities_group then
    ui.combo_enabled = { Get = function() return true end }
    ui.combo_key = create_bind_safe(combo_group, "\u{041a}\u{043b}\u{0430}\u{0432}\u{0438}\u{0448}\u{0430} \u{043a}\u{043e}\u{043c}\u{0431}\u{043e}") or { IsDown = function() return false end }
    if combo_group.MultiSelect then
        ui.combo_spells = combo_group:MultiSelect("\u{0421}\u{043f}\u{043e}\u{0441}\u{043e}\u{0431}\u{043d}\u{043e}\u{0441}\u{0442}\u{0438}", {
            { "net", ICON_NET, true },
            { "poof", ICON_POOF, true },
            { "mega", ICON_MEGA, false },
        }, true)
        if ui.combo_spells.DragAllowed then
            ui.combo_spells:DragAllowed(false)
        end
    else
        ui.combo_use_net = combo_group:Switch("Net", true, ICON_NET)
        ui.combo_use_poof = combo_group:Switch("Poof", true, ICON_POOF)
        ui.combo_use_mega = combo_group:Switch("MegaMeepo", false, ICON_MEGA)
    end
    ui.combo_type = combo_group:Combo("\u{0422}\u{0438}\u{043f} \u{041a}\u{043e}\u{043c}\u{0431}\u{043e}", {
        "\u{0412}\u{044b}\u{0431}\u{0440}\u{0430}\u{043d}\u{043d}\u{044b}\u{0439} \u{041c}\u{0438}\u{043f}\u{043e}",
        "\u{0412}\u{0441}\u{0435} \u{043c}\u{0438}\u{043f}\u{043e}",
    }, 1)
    ui.combo_target_fov = combo_group:Slider("Target FOV (px)", 40, 500, 140, "%d")
    ui.combo_state_machine = combo_group:Switch("State Machine", true)
    ui.combo_strict_control = combo_group:Switch("Strict Control", true)
    ui.combo_control_break_checks = combo_group:Switch("Control Break Checks", true)
    ui.combo_main_first = combo_group:Switch("Main Meepo First", true)
    ui.combo_hold_disable_ms = combo_group:Slider("Hold Disable Window (ms)", 100, 1400, 450, "%d")
    ui.combo_poof_before_blink = combo_group:Switch("Poof before Blink", true, ICON_POOF)
    ui.combo_blink_pre_poof_delay_ms = combo_group:Slider("Poof -> Blink Delay (ms)", 0, 700, 500, "%d")
    ui.combo_direct_cast = combo_group:Switch("Direct Cast Mode", true)
    ui.net_on_tp = combo_group:Switch("\u{0421}\u{0435}\u{0442}\u{043a}\u{0430} \u{0412} \u{0422}\u{0435}\u{043b}\u{0435}\u{043f}\u{043e}\u{0440}\u{0442}", false, ICON_NET)
    ui.net_on_tp_fog = combo_group:Switch("\u{0421}\u{0435}\u{0442}\u{043a}\u{0430} \u{0432} \u{0442}\u{0435}\u{043b}\u{0435}\u{043f}\u{043e}\u{0440}\u{0442} \u{0432} \u{0442}\u{0443}\u{043c}\u{0430}\u{043d}", true, ICON_NET)
    ui.combo_debug = combo_group:Switch("Combo Debug HUD", false)
    ui.enabled = display_group:Switch("Enable Meepo Panel", true)
    ui.show_main = display_group:Switch("Show main Meepo", true)
    ui.show_clones = display_group:Switch("Show clones", true)
    ui.draw_world = display_group:Switch("Draw above units", true)
    ui.draw_portraits = display_group:Switch("Draw near portraits", true)
    ui.show_tactical = display_group:Switch("Show tactical line", true)
    ui.float_panel_enable = display_group:Switch("Floating Control Box", true)
    ui.float_panel_click_select = display_group:Switch("Panel Click Select", true)
    ui.float_panel_x = display_group:Slider("Control Box X", 0, 3840, 28, "%d")
    ui.float_panel_y = display_group:Slider("Control Box Y", 0, 2160, 420, "%d")
    ui.float_panel_scale = display_group:Slider("Control Box Scale", 60, 180, 100, "%d%%")
    if has_autofarm_group then
        ui.autofarm_enable = autofarm_group:Switch("\u{0412}\u{043a}\u{043b}\u{044e}\u{0447}\u{0438}\u{0442}\u{044c} \u{0410}\u{0432}\u{0442}\u{043e}\u{0424}\u{0430}\u{0440}\u{043c}", false)
        ui.autofarm_toggle_key = create_bind_safe(autofarm_group, "\u{041a}\u{043b}\u{0430}\u{0432}\u{0438}\u{0448}\u{0430} \u{0410}\u{0432}\u{0442}\u{043e}\u{0424}\u{0430}\u{0440}\u{043c}")
            or { IsPressed = function() return false end, IsDown = function() return false end }
        ui.autofarm_show_map = autofarm_group:Switch("Floating AutoFarm Map", true)
        ui.autofarm_map_x = { Get = function() return 28 end }
        ui.autofarm_map_y = { Get = function() return 820 end }
        ui.autofarm_map_scale = { Get = function() return 100 end }
        ui.autofarm_mana_reserve = autofarm_group:Slider("\u{0421}\u{043e}\u{0445}\u{0440}\u{0430}\u{043d}\u{044f}\u{0442}\u{044c} \u{041c}\u{0430}\u{043d}\u{0443} (%)", 0, 80, 30, "%d%%")
        ui.autofarm_auto_stack = autofarm_group:Switch("Auto Stack", false)
        if autofarm_group.MultiCombo then
            ui.autofarm_poof_use = autofarm_group:MultiCombo("\u{0418}\u{0441}\u{043f}\u{043e}\u{043b}\u{043b}\u{044c}\u{0437}\u{043e}\u{0432}\u{0430}\u{043d}\u{0438}\u{0435} \u{041f}\u{0443}\u{0444}\u{0430}", {
                "\u{0414}\u{043b}\u{044f} \u{043f}\u{0435}\u{0440}\u{0435}\u{043c}\u{0435}\u{0449}\u{0435}\u{043d}\u{0438}\u{044f}",
                "\u{0414}\u{043b}\u{044f} \u{0443}\u{0440}\u{043e}\u{043d}\u{0430}",
            }, {
                "\u{0414}\u{043b}\u{044f} \u{043f}\u{0435}\u{0440}\u{0435}\u{043c}\u{0435}\u{0449}\u{0435}\u{043d}\u{0438}\u{044f}",
                "\u{0414}\u{043b}\u{044f} \u{0443}\u{0440}\u{043e}\u{043d}\u{0430}",
            })
            ui.autofarm_poof_use_move = {
                Get = function()
                    local enabled = (ui.autofarm_poof_use and ui.autofarm_poof_use.ListEnabled and ui.autofarm_poof_use:ListEnabled()) or {}
                    return list_has_string(enabled, "\u{0414}\u{043b}\u{044f} \u{043f}\u{0435}\u{0440}\u{0435}\u{043c}\u{0435}\u{0449}\u{0435}\u{043d}\u{0438}\u{044f}")
                end
            }
            ui.autofarm_poof_use_damage = {
                Get = function()
                    local enabled = (ui.autofarm_poof_use and ui.autofarm_poof_use.ListEnabled and ui.autofarm_poof_use:ListEnabled()) or {}
                    return list_has_string(enabled, "\u{0414}\u{043b}\u{044f} \u{0443}\u{0440}\u{043e}\u{043d}\u{0430}")
                end
            }
        elseif autofarm_group.MultiSelect then
            ui.autofarm_poof_use = autofarm_group:MultiSelect("\u{0418}\u{0441}\u{043f}\u{043e}\u{043b}\u{043b}\u{044c}\u{0437}\u{043e}\u{0432}\u{0430}\u{043d}\u{0438}\u{0435} \u{041f}\u{0443}\u{0444}\u{0430}", {
                { "move", ICON_POOF, true },
                { "damage", ICON_POOF, true },
            }, true)
            if ui.autofarm_poof_use and ui.autofarm_poof_use.DragAllowed then
                ui.autofarm_poof_use:DragAllowed(false)
            end
            ui.autofarm_poof_use_move = {
                Get = function()
                    return ui.autofarm_poof_use and ui.autofarm_poof_use.Get and ui.autofarm_poof_use:Get("move") == true
                end
            }
            ui.autofarm_poof_use_damage = {
                Get = function()
                    return ui.autofarm_poof_use and ui.autofarm_poof_use.Get and ui.autofarm_poof_use:Get("damage") == true
                end
            }
        else
            ui.autofarm_poof_use_move = autofarm_group:Switch("\u{041f}\u{0443}\u{0444} \u{0434}\u{043b}\u{044f} \u{041f}\u{0435}\u{0440}\u{0435}\u{043c}\u{0435}\u{0449}\u{0435}\u{043d}\u{0438}\u{044f}", true, ICON_POOF)
            ui.autofarm_poof_use_damage = autofarm_group:Switch("\u{041f}\u{0443}\u{0444} \u{0434}\u{043b}\u{044f} \u{0423}\u{0440}\u{043e}\u{043d}\u{0430}", true, ICON_POOF)
        end
    else
        ui.autofarm_enable = { Get = function() return false end }
        ui.autofarm_toggle_key = { IsPressed = function() return false end, IsDown = function() return false end }
        ui.autofarm_show_map = { Get = function() return true end }
        ui.autofarm_map_x = { Get = function() return 28 end }
        ui.autofarm_map_y = { Get = function() return 820 end }
        ui.autofarm_map_scale = { Get = function() return 100 end }
        ui.autofarm_mana_reserve = { Get = function() return 0 end }
        ui.autofarm_auto_stack = { Get = function() return false end }
        ui.autofarm_poof_use_move = { Get = function() return true end }
        ui.autofarm_poof_use_damage = { Get = function() return true end }
    end
    if abilities_group.MultiSelect then
        ui.auto_save_spells = abilities_group:MultiSelect("\u{0421}\u{043f}\u{043e}\u{0441}\u{043e}\u{0431}\u{043d}\u{043e}\u{0441}\u{0442}\u{0438}", {
            { "dig", ICON_DIG, false },
            { "mega", ICON_MEGA, false },
        }, true)
        if ui.auto_save_spells.DragAllowed then
            ui.auto_save_spells:DragAllowed(false)
        end
        ui.auto_dig = { Get = function() return ui.auto_save_spells:Get("dig") end }
        ui.auto_mega = { Get = function() return ui.auto_save_spells:Get("mega") end }
    else
        ui.auto_dig = abilities_group:Switch("Dig", false, ICON_DIG)
        ui.auto_mega = abilities_group:Switch("MegaMeepo", false, ICON_MEGA)
    end
    ui.auto_dig_hp = abilities_group:Slider("Auto Dig HP (%)", 5, 80, 28, "%d%%")
    ui.auto_mega_hp = abilities_group:Slider("Auto MegaMeepo HP (%)", 5, 80, 35, "%d%%")
    ui.auto_safe_enable = abilities_group:Switch("Enable Auto Safe", true, ICON_POOF)
    ui.auto_safe_which_meepos = abilities_group:Combo("Which Meepos to Save", {
        "All Meepos",
        "Only Clones",
        "Only Main",
    }, 1)
    ui.auto_safe_poof_hp_enable = abilities_group:Switch("Poof to Safety (HP)", true, ICON_POOF)
    ui.auto_safe_poof_hp = abilities_group:Slider("Poof Threshold (%)", 5, 60, 25, "%d%%")
    ui.auto_safe_poof_dest = abilities_group:Combo("Poof Destination", {
        "Farthest Clone",
        "Main Meepo",
        "Healthiest Clone",
    }, 0)
    ui.auto_safe_cd_ms = abilities_group:Slider("Auto Safe Cooldown (ms)", 500, 6000, 2000, "%dms")
    ui.auto_safe_enemy_poof = abilities_group:Switch("Poof Away from Enemies", true, ICON_POOF)
    ui.auto_safe_enemy_radius = abilities_group:Slider("Enemy Detection Radius", 400, 1500, 900, "%d")
    try_set_widget_image(ui.auto_dig_hp, ICON_DIG)
    try_set_widget_image(ui.auto_mega_hp, ICON_MEGA)
    try_set_widget_image(ui.auto_safe_poof_hp, ICON_POOF)
    if has_utilities_group then
        ui.poof_to_cursor = create_bind_safe(utilities_group, "\u{041f}\u{0443}\u{0444} \u{043a} \u{043a}\u{0443}\u{0440}\u{0441}\u{043e}\u{0440}\u{0443}", ICON_POOF) or { IsPressed = function() return false end }
        ui.poof_on_self = create_bind_safe(utilities_group, "\u{041f}\u{0443}\u{0444} \u{043d}\u{0430} \u{0441}\u{0435}\u{0431}\u{044f}", ICON_POOF) or { IsPressed = function() return false end }
    else
        ui.poof_to_cursor = { IsPressed = function() return false end }
        ui.poof_on_self = { IsPressed = function() return false end }
    end
    if has_items_group then
        ui.items_menu = items_group:Label("\u{0418}\u{0441}\u{043f}\u{043e}\u{043b}\u{044c}\u{0437}\u{043e}\u{0432}\u{0430}\u{043d}\u{0438}\u{0435} \u{043f}\u{0440}\u{0435}\u{0434}\u{043c}\u{0435}\u{0442}\u{043e}\u{0432}")
        ui.items_linken_menu = items_group:Label("\u{0421}\u{0431}\u{0438}\u{0442}\u{0438}\u{0435} \u{041b}\u{0438}\u{043d}\u{043a}\u{0438}")
        if ui.items_menu and ui.items_menu.Gear then
            local items_gear = ui.items_menu:Gear("\u{0418}\u{0441}\u{043f}\u{043e}\u{043b}\u{044c}\u{0437}\u{043e}\u{0432}\u{0430}\u{043d}\u{0438}\u{0435} \u{043f}\u{0440}\u{0435}\u{0434}\u{043c}\u{0435}\u{0442}\u{043e}\u{0432}", CFG.burger_icon, true)
            if items_gear and items_gear.MultiSelect then
                ui.items_important = items_gear:MultiSelect(
                    "\u{0412}\u{0430}\u{0436}\u{043d}\u{044b}\u{0435} \u{043f}\u{0440}\u{0435}\u{0434}\u{043c}\u{0435}\u{0442}\u{044b}",
                    item_utils.build_item_multiselect(CFG.important_items, true),
                    true
                )
                if ui.items_important and ui.items_important.DragAllowed then
                    ui.items_important:DragAllowed(false)
                end
            else
                ui.items_important = { Get = function() return false end }
            end
        else
            ui.items_important = { Get = function() return false end }
        end
        if ui.items_linken_menu and ui.items_linken_menu.Gear then
            local linken_gear = ui.items_linken_menu:Gear("\u{0421}\u{0431}\u{0438}\u{0442}\u{0438}\u{0435} \u{041b}\u{0438}\u{043d}\u{043a}\u{0438}", CFG.burger_icon, true)
            if linken_gear and linken_gear.MultiSelect then
                ui.items_linken_breakers = linken_gear:MultiSelect(
                    "\u{0421}\u{0431}\u{0438}\u{0442}\u{0438}\u{0435} \u{041b}\u{0438}\u{043d}\u{043a}\u{0438}",
                    item_utils.build_item_multiselect(CFG.linken_break_items, true),
                    true
                )
                if ui.items_linken_breakers and ui.items_linken_breakers.DragAllowed then
                    ui.items_linken_breakers:DragAllowed(false)
                end
            else
                ui.items_linken_breakers = { Get = function() return false end }
            end
        else
            ui.items_linken_breakers = { Get = function() return false end }
        end
        ui.items_enabled = { Get = function() return true end }
    else
        ui.items_enabled = { Get = function() return false end }
        ui.items_important = { Get = function() return false end }
        ui.items_linken_breakers = { Get = function() return false end }
    end
else
    ui.combo_enabled = { Get = function() return true end }
    ui.combo_key = { IsDown = function() return false end }
    ui.combo_type = { Get = function() return COMBO_MODE_SELECTED end }
    ui.combo_target_fov = { Get = function() return 140 end }
    ui.combo_state_machine = { Get = function() return true end }
    ui.combo_strict_control = { Get = function() return true end }
    ui.combo_control_break_checks = { Get = function() return true end }
    ui.combo_main_first = { Get = function() return true end }
    ui.combo_hold_disable_ms = { Get = function() return 450 end }
    ui.combo_poof_before_blink = { Get = function() return true end }
    ui.combo_blink_pre_poof_delay_ms = { Get = function() return 500 end }
    ui.combo_direct_cast = { Get = function() return true end }
    ui.net_on_tp = { Get = function() return false end }
    ui.net_on_tp_fog = { Get = function() return true end }
    ui.combo_debug = { Get = function() return false end }
    ui.enabled = { Get = function() return true end }
    ui.show_main = { Get = function() return true end }
    ui.show_clones = { Get = function() return true end }
    ui.draw_world = { Get = function() return true end }
    ui.draw_portraits = { Get = function() return false end }
    ui.show_tactical = { Get = function() return true end }
    ui.float_panel_enable = { Get = function() return true end }
    ui.float_panel_click_select = { Get = function() return true end }
    ui.float_panel_x = { Get = function() return 28 end }
    ui.float_panel_y = { Get = function() return 420 end }
    ui.float_panel_scale = { Get = function() return 100 end }
    ui.auto_dig = { Get = function() return false end }
    ui.auto_mega = { Get = function() return false end }
    ui.auto_dig_hp = { Get = function() return 28 end }
    ui.auto_mega_hp = { Get = function() return 35 end }
    ui.auto_safe_enable = { Get = function() return false end }
    ui.auto_safe_which_meepos = { Get = function() return 1 end }
    ui.auto_safe_poof_hp_enable = { Get = function() return true end }
    ui.auto_safe_poof_hp = { Get = function() return 25 end }
    ui.auto_safe_poof_dest = { Get = function() return 0 end }
    ui.auto_safe_cd_ms = { Get = function() return 2000 end }
    ui.auto_safe_enemy_poof = { Get = function() return true end }
    ui.auto_safe_enemy_radius = { Get = function() return 900 end }
    ui.autofarm_enable = { Get = function() return false end }
    ui.autofarm_toggle_key = { IsPressed = function() return false end, IsDown = function() return false end }
    ui.autofarm_show_map = { Get = function() return true end }
    ui.autofarm_map_x = { Get = function() return 28 end }
    ui.autofarm_map_y = { Get = function() return 820 end }
    ui.autofarm_map_scale = { Get = function() return 100 end }
    ui.autofarm_auto_stack = { Get = function() return false end }
    ui.poof_to_cursor = { IsPressed = function() return false end }
    ui.poof_on_self = { IsPressed = function() return false end }
    ui.items_enabled = { Get = function() return false end }
    ui.items_important = { Get = function() return false end }
    ui.items_linken_breakers = { Get = function() return false end }
end
local combo_bind = nil
local farm_bind = nil
local binds_initialized = false
local function init_binds_once()
    if binds_initialized then
        return
    end
    local success1, bind1 = pcall(function()
        return Menu.Find("Heroes", "Hero List", "Meepo", "Main Settings", "Hero Settings", "Combo Key")
    end)
    if success1 and bind1 then
        combo_bind = bind1
    end
    local success2, bind2 = pcall(function()
        return Menu.Find("Heroes", "Hero List", "Meepo", "Main Settings", "Jungle Settings", "Farm Key")
    end)
    if success2 and bind2 then
        farm_bind = bind2
    end
    binds_initialized = true
end
local font = Render.LoadFont("Arial", Enum.FontCreate.FONTFLAG_OUTLINE, Enum.FontWeight.BOLD)
local font_size = 16
local tactical_font_size = 12
local COLORS = {
    combo = Color(255, 80, 80, 255),
    farm = Color(120, 220, 120, 255),
    move = Color(255, 220, 120, 255),
    idle = Color(200, 200, 200, 255),
    dead = Color(150, 150, 255, 255),
    retreat = Color(255, 150, 90, 255),
    engage_ready = Color(120, 235, 255, 255),
    bg = Color(0, 0, 0, 150),
    tactical = Color(220, 235, 255, 230),
}
C = {
    BAR_OFFSET_Z = 35,
    PORTRAIT_X_PCT = 4,
    PORTRAIT_Y_PCT = 18,
    PORTRAIT_STEP_Y_PCT = 6,
    ENEMY_RADIUS = 800,
    READY_RADIUS = 900,
    RETREAT_HP_PCT = 32,
    SAFE_ENGAGE_HP_PCT = 35,
    AUTO_SAVE_ENEMY_RADIUS = 1000,
    ABILITY_POOF = "meepo_poof",
    ABILITY_NET = "meepo_earthbind",
    ABILITY_DIG = "meepo_petrify",
    ITEM_HEX = "item_sheepstick",
    MODIFIER_DIG = "modifier_meepo_petrify",
    ABILITY_MEGA_CANDIDATES = { "meepo_megameepo", "meepo_mega_meepo" },
    MODIFIER_MEGA_CANDIDATES = { "modifier_meepo_megameepo", "modifier_meepo_mega_meepo" },
    MODIFIER_NET_CANDIDATES = {
        "modifier_meepo_earthbind",
        "modifier_meepo_earthbind_debuff",
        "modifier_meepo_earthbind_root",
    },
    AUTO_DIG_RECAST_DELAY = 0.35,
    AUTO_MEGA_RECAST_DELAY = 0.45,
    AUTO_DIG_TICK_INTERVAL = 0.08,
    COMBO_MOVE_ORDER_INTERVAL = 0.10,
    COMBO_MOVE_MIN_DELTA = 4,
    COMBO_NET_CHAIN_BUFFER = 0.16,
    COMBO_NET_HANDOFF_EXTRA = 0.18,
    COMBO_NET_CASTER_RECAST_DELAY = 0.14,
    COMBO_NET_GLOBAL_RECAST_DELAY = 0.06,
    COMBO_NET_CAST_LOCK = 0.05,
    COMBO_NET_PENDING_CONFIRM_GRACE = 0.12,
    COMBO_NET_PROJECTILE_SPEED_FALLBACK = 900,
    COMBO_NET_RANGE_PADDING = 80,
    COMBO_NET_FACE_TIME_CAP = 0.35,
    COMBO_HEX_RANGE_PADDING = 50,
    COMBO_HEX_RANGE_FALLBACK = 800,
    COMBO_HEX_CHAIN_FROM_ABYSSAL_WINDOW = 0.30,
    COMBO_HEX_TO_CONTROL_CHAIN_WINDOW = 0.35,
    COMBO_HOLD_ORDER_INTERVAL = 0.12,
    COMBO_POOF_CASTER_RECAST_DELAY = 0.20,
    COMBO_POOF_ROOT_MIN_REMAINING = 0.30,
    COMBO_POOF_SAFE_ROOT_BUFFER = 0.06,
    COMBO_POOF_STAGGER = 0.04,
    COMBO_BLINK_RECAST_DELAY = 0.12,
    COMBO_POOF_CHANNEL_FALLBACK = 1.5,
    COMBO_POOF_DAMAGE_RADIUS_FALLBACK = 375,
    COMBO_POOF_DAMAGE_RADIUS_PAD = -50,
    COMBO_ATTACK_ORDER_INTERVAL = 0.28,
    COMBO_ACTION_MIN_INTERVAL = 0.12,
    COMBO_CONTROL_HOLD_MIN_REMAINING = 0.08,
    COMBO_DEBUG_LOG_MIN_GAP = 0.18,
    COMBO_LOGIC_TICK_INTERVAL = 0.03,
    COMBO_PURGE_GLOBAL_RECAST_DELAY = 0.65,
    COMBO_PURGE_SAME_TARGET_RECAST_DELAY = 1.25,
    COMBO_ITEM_FRAME_GAP = 3,
    ITEM_CAST_BUDGET_PER_FRAME = 2,
    ITEM_MIN_INTERVAL_SEC = 0.15,
    GENERIC_CAST_INTERVAL = 0.18,
    HUD_COMBO_Y_OFFSET = 245,
    HUD_COMBO_W = 126,
    HUD_COMBO_H = 24,
    HUD_COMBO_TEXT_ON = "\u{0412}\u{043a}\u{043b}",
    HUD_COMBO_TEXT_OFF = "\u{0412}\u{044b}\u{043a}\u{043b}",
    HUD_COMBO_TITLE = "\u{041a}\u{043e}\u{043c}\u{0431}\u{043e}",
}
local auto_dig_last_cast = {}
local auto_mega_last_cast = {}
local auto_dig_next_tick = 0
local combo_runtime_enabled = true
local combo_focus_target = nil
local combo_focus_source = nil
local combo_focus_target_key = nil
local combo_move_next_order_time = 0
local combo_move_last_position = nil
local combo_move_last_frame = -1
local combo_last_selection_key = nil
local combo_net_last_global_cast = -9999
local combo_net_last_cast_by_meepo = {}
local combo_hex_last_cast = -9999
local combo_hex_last_cast_by_meepo = {}
local combo_poof_last_cast_by_meepo = {}
local combo_attack_next_order_time = 0
local combo_was_active = false
local poof_cast_queue = {}
local poof_queue_by_meepo = {}
local can_schedule_poof
local schedule_poof_burst
script._poof_next_order_time = script._poof_next_order_time or 0
local function is_sync_poof_reason(reason)
    if not reason or reason == "" then
        return false
    end
    return reason == "meepo_combo_poof_sync"
        or reason == "meepo_poof_cursor"
        or reason == "meepo_poof_self"
end
local clear_poof_queue
local has_pending_poof_queue
script._debug_combo_log = true
script._debug_use_engine_echo = false
script._debug_emit_min_gap = script._debug_emit_min_gap or 0.15
script._debug_last_emit_time = script._debug_last_emit_time or -9999
function script._fmt_vec(v)
    if not v then
        return "nil"
    end
    return string.format("(%.1f,%.1f,%.1f)", v.x or 0, v.y or 0, v.z or 0)
end
function script._dbg(tag, msg)
    if not script._debug_combo_log then
        return
    end
    local debug_ui_enabled = false
    if ui and ui.combo_debug and ui.combo_debug.Get then
        local ok, enabled = pcall(function()
            return ui.combo_debug:Get()
        end)
        debug_ui_enabled = ok and enabled == true
    end
    if not debug_ui_enabled then
        return
    end
    pcall(function()
        local t = 0
        if GameRules and GameRules.GetGameTime then
            t = tonumber(GameRules.GetGameTime()) or 0
        end
        if tag ~= "combo_state" and (t - (script._debug_last_emit_time or -9999)) < (script._debug_emit_min_gap or 0) then
            return
        end
        local line = string.format("[meepo:%s][%.3f] %s", tag or "-", t, msg or "")
        print(line)
        script._debug_last_emit_time = t
        if script._debug_use_engine_echo and Engine and Engine.ExecuteCommand then
            pcall(function()
                Engine.ExecuteCommand("echo " .. line)
            end)
        end
    end)
end
script._combo_blink_last_cast_cmd = script._combo_blink_last_cast_cmd or -9999
local function is_meepo_hero(npc)
    if not npc or not Entity.IsHero(npc) then
        return false
    end
    local name = NPC.GetUnitName(npc)
    return name == "npc_dota_hero_meepo"
end
local function is_meepo_instance(npc)
    if not npc or not Entity.IsHero(npc) then
        return false
    end
    if safe_call(NPC.IsIllusion, npc) == true then
        return false
    end
    if NPC.IsMeepoClone and NPC.IsMeepoClone(npc) then
        return true
    end
    return is_meepo_hero(npc)
end
local function round_int(v)
    return math.floor((tonumber(v) or 0) + 0.5)
end
get_game_time = function()
    if not GameRules or not GameRules.GetGameTime then
        return 0
    end
    return tonumber(safe_call(GameRules.GetGameTime) or 0) or 0
end
local function get_health_pct(npc)
    local hp = tonumber(safe_call(Entity.GetHealth, npc) or 0) or 0
    local max_hp = tonumber(safe_call(Entity.GetMaxHealth, npc) or 0) or 0
    if max_hp <= 0 then
        return 0
    end
    local pct = (hp / max_hp) * 100
    if pct < 0 then pct = 0 end
    if pct > 100 then pct = 100 end
    return pct
end
local function get_mana_pct(npc)
    local mana = tonumber(safe_call(NPC.GetMana, npc) or 0) or 0
    local max_mana = tonumber(safe_call(NPC.GetMaxMana, npc) or 0) or 0
    if max_mana <= 0 then
        return 0
    end
    local pct = (mana / max_mana) * 100
    if pct < 0 then pct = 0 end
    if pct > 100 then pct = 100 end
    return pct
end
local function vec_dist_2d(a, b)
    if not a or not b then
        return nil
    end
    local dx = (a.x or 0) - (b.x or 0)
    local dy = (a.y or 0) - (b.y or 0)
    return math.sqrt(dx * dx + dy * dy)
end
local function get_enemy_info(npc, radius)
    local enemies = Entity.GetHeroesInRadius(npc, radius, Enum.TeamType.TEAM_ENEMY, false, true)
    local count = (enemies and #enemies) or 0
    if count <= 0 then
        return 0, nil
    end
    local meepo_pos = safe_call(Entity.GetAbsOrigin, npc)
    if not meepo_pos then
        return count, nil
    end
    local nearest = nil
    for i = 1, count do
        local enemy = enemies[i]
        local epos = safe_call(Entity.GetAbsOrigin, enemy)
        local d = vec_dist_2d(meepo_pos, epos)
        if d and (not nearest or d < nearest) then
            nearest = d
        end
    end
    return count, nearest
end
local function get_ability_cd(npc, ability_name)
    local ability = safe_call(NPC.GetAbility, npc, ability_name)
    if not ability then
        return nil
    end
    return tonumber(safe_call(Ability.GetCooldown, ability) or 0) or 0
end
local function is_ability_ready(npc, ability_name)
    local ability = safe_call(NPC.GetAbility, npc, ability_name)
    if not ability then
        return false
    end
    local mana = tonumber(safe_call(NPC.GetMana, npc) or 0) or 0
    local castable = safe_call(Ability.IsCastable, ability, mana)
    if castable ~= nil then
        return castable == true
    end
    local cd = tonumber(safe_call(Ability.GetCooldown, ability) or 0) or 0
    local mc = tonumber(safe_call(Ability.GetManaCost, ability) or 0) or 0
    return cd <= 0.05 and mana >= mc
end
local function fmt_cd(cd)
    if cd == nil then
        return "--"
    end
    local v = tonumber(cd) or 0
    if v <= 0.05 then
        return "0.0"
    end
    return string.format("%.1f", v)
end
local function fmt_dist(d)
    if d == nil then
        return "--"
    end
    return tostring(round_int(d))
end
local function build_tactical_line(hp_pct, mana_pct, poof_cd, net_cd, nearest_dist)
    return string.format(
        "HP %d%% | MP %d%% | P %s | N %s | E %s",
        round_int(hp_pct),
        round_int(mana_pct),
        fmt_cd(poof_cd),
        fmt_cd(net_cd),
        fmt_dist(nearest_dist)
    )
end
local function collect_meepos()
    local result = {}
    local heroes = Heroes.GetAll()
    if not heroes then
        return result
    end
    local local_hero = Heroes.GetLocal()
    local local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    for _, h in ipairs(heroes) do
        if is_meepo_instance(h) then
            local meepo_team = tonumber(safe_call(Entity.GetTeamNum, h) or -2) or -2
            if local_team < 0 or meepo_team == local_team then
                result[#result + 1] = h
            end
        end
    end
    return result
end
get_entity_key = function(entity)
    local idx = tonumber(safe_call(Entity.GetIndex, entity) or 0) or 0
    if idx > 0 then
        return idx
    end
    return entity
end
local get_earthbind_projectile_speed
local function should_trigger_save_by_enemy(npc)
    local enemy_count = select(1, get_enemy_info(npc, C.AUTO_SAVE_ENEMY_RADIUS))
    return (enemy_count or 0) > 0
end
local function has_any_modifier(npc, modifier_names)
    if not npc or not modifier_names then
        return false
    end
    for i = 1, #modifier_names do
        if safe_call(NPC.HasModifier, npc, modifier_names[i]) then
            return true
        end
    end
    return false
end
can_cast_ability_for_npc = function(npc, ability)
    if not npc or not ability then
        return false
    end
    local mana = tonumber(safe_call(NPC.GetMana, npc) or 0) or 0
    local castable = safe_call(Ability.IsCastable, ability, mana)
    if castable ~= nil then
        return castable == true
    end
    local cd = tonumber(safe_call(Ability.GetCooldown, ability) or 0) or 0
    local mc = tonumber(safe_call(Ability.GetManaCost, ability) or 0) or 0
    return cd <= 0.05 and mana >= mc
end
local function find_ability_by_names(npc, ability_names)
    if not npc or not ability_names then
        return nil
    end
    for i = 1, #ability_names do
        local ability = safe_call(NPC.GetAbility, npc, ability_names[i])
        if ability then
            return ability
        end
    end
    return nil
end
is_item_enabled = function(item_name)
    if ui.items_important and ui.items_important.Get and item_name then
        local ok, enabled = pcall(function()
            return ui.items_important:Get(item_name)
        end)
        if ok then
            return enabled == true
        end
    end
    return true
end
local function get_blink_item(npc)
    if not npc then
        return nil
    end
    local blink = find_ability_by_names(npc, CFG.blink_item_candidates)
    if not blink and NPC.GetItem then
        for i = 1, #CFG.blink_item_candidates do
            blink = safe_call(NPC.GetItem, npc, CFG.blink_item_candidates[i], true)
            if blink then
                break
            end
        end
    end
    if not blink then
        return nil
    end
    local name = safe_call(Ability.GetName, blink)
    if name and name ~= "" and not is_item_enabled(name) then
        return nil
    end
    return blink
end
local function can_cast_dig(meepo)
    local dig = safe_call(NPC.GetAbility, meepo, C.ABILITY_DIG)
    if not dig then
        return false, nil
    end
    return can_cast_ability_for_npc(meepo, dig), dig
end
local function can_cast_mega(meepo)
    local mega = find_ability_by_names(meepo, C.ABILITY_MEGA_CANDIDATES)
    if not mega then
        return false, nil
    end
    return can_cast_ability_for_npc(meepo, mega), mega
end
local function get_lowest_hp_meepo(meepos)
    local lowest_meepo = nil
    local lowest_hp_pct = nil
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            local hp_pct = get_health_pct(meepo)
            if not lowest_hp_pct or hp_pct < lowest_hp_pct then
                lowest_hp_pct = hp_pct
                lowest_meepo = meepo
            end
        end
    end
    return lowest_meepo, lowest_hp_pct
end
local function is_combo_key_down()
    if ui.combo_key and ui.combo_key.IsDown then
        local ok, down = pcall(function()
            return ui.combo_key:IsDown()
        end)
        if ok and down then
            return true
        end
    end
    if combo_bind and combo_bind.IsDown then
        local ok, down = pcall(function()
            return combo_bind:IsDown()
        end)
        if ok and down then
            return true
        end
    end
    return false
end
local function is_combo_active()
    if not combo_runtime_enabled then
        return false
    end
    if not ui.combo_enabled or not ui.combo_enabled.Get or not ui.combo_enabled:Get() then
        return false
    end
    return is_combo_key_down()
end
local function get_combo_type_index()
    if ui.combo_type and ui.combo_type.Get then
        local ok, idx = pcall(function()
            return ui.combo_type:Get()
        end)
        if ok and idx ~= nil then
            return tonumber(idx) or COMBO_MODE_SELECTED
        end
    end
    return COMBO_MODE_SELECTED
end
local function is_combo_spell_enabled(spell_key, fallback_switch)
    if ui.combo_spells and ui.combo_spells.Get and spell_key then
        local ok, enabled = pcall(function()
            return ui.combo_spells:Get(spell_key)
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end
    if fallback_switch and fallback_switch.Get then
        local ok, enabled = pcall(function()
            return fallback_switch:Get()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end
    return false
end
local function get_selected_meepo(local_player)
    if not local_player or not Player or not Player.GetSelectedUnits then
        return nil
    end
    local selected_units = safe_call(Player.GetSelectedUnits, local_player)
    if not selected_units then
        return nil
    end
    for i = 1, #selected_units do
        local unit = selected_units[i]
        if unit and is_meepo_instance(unit) and Entity.IsAlive(unit) then
            return unit
        end
    end
    return nil
end
local function get_main_meepo(local_hero)
    if local_hero and is_meepo_instance(local_hero) and Entity.IsAlive(local_hero) then
        local is_clone = NPC.IsMeepoClone and NPC.IsMeepoClone(local_hero) or false
        if not is_clone then
            return local_hero
        end
    end
    local meepos = collect_meepos()
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            local is_clone = NPC.IsMeepoClone and NPC.IsMeepoClone(meepo) or false
            if not is_clone then
                return meepo
            end
        end
    end
    if local_hero and is_meepo_instance(local_hero) and Entity.IsAlive(local_hero) then
        return local_hero
    end
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            return meepo
        end
    end
    return nil
end
local function get_combo_anchor_meepo(local_player, local_hero)
    local mode = get_combo_type_index()
    if mode == COMBO_MODE_SELECTED then
        local selected_meepo = get_selected_meepo(local_player)
        if selected_meepo then
            return selected_meepo
        end
        if local_hero and is_meepo_instance(local_hero) and Entity.IsAlive(local_hero) then
            return local_hero
        end
        return get_main_meepo(local_hero)
    end
    if mode == COMBO_MODE_ALL then
        return get_main_meepo(local_hero)
    end
    return get_main_meepo(local_hero)
end
function script.get_combo_main_priority_key(local_hero)
    if not script.is_combo_option_enabled(ui.combo_main_first) then
        return nil
    end
    local main_meepo = get_main_meepo(local_hero)
    if not main_meepo or not Entity.IsAlive(main_meepo) then
        return nil
    end
    return get_entity_key(main_meepo)
end
function script.should_take_combo_candidate(candidate, dist, best, best_dist, preferred_key)
    if not candidate then
        return false
    end
    if not best then
        return true
    end
    if preferred_key then
        local candidate_is_preferred = get_entity_key(candidate) == preferred_key
        local best_is_preferred = get_entity_key(best) == preferred_key
        if candidate_is_preferred ~= best_is_preferred then
            return candidate_is_preferred
        end
    end
    if best_dist == nil then
        return true
    end
    if dist == nil then
        return false
    end
    return dist < best_dist
end
local function reset_combo_move_state()
    combo_move_next_order_time = 0
    combo_move_last_position = nil
    combo_move_last_frame = -1
    combo_last_selection_key = nil
    combo_net_last_global_cast = -9999
    combo_net_last_cast_by_meepo = {}
    script._combo_net_pending_target_key = nil
    script._combo_net_pending_end_time = 0
    script._combo_net_pending_arrival_time = 0
    script._combo_silence_last_global = -9999
    script._combo_silence_last_attempt_global = -9999
    script._combo_silence_last_attempt_frame = -1
    script._combo_silence_last_by_meepo = {}
    script._combo_silence_last_frame_by_meepo = {}
    script._combo_atos_last_global = -9999
    script._combo_atos_last_attempt_global = -9999
    script._combo_atos_last_attempt_frame = -1
    script._combo_atos_last_by_meepo = {}
    script._combo_atos_last_frame_by_meepo = {}
    script._combo_atos_pending_target_key = nil
    script._combo_atos_pending_end_time = 0
    script._combo_abyssal_last_global = -9999
    script._combo_abyssal_last_attempt_global = -9999
    script._combo_abyssal_last_attempt_frame = -1
    script._combo_abyssal_last_by_meepo = {}
    script._combo_abyssal_last_frame_by_meepo = {}
    script._combo_abyssal_pending_target_key = nil
    script._combo_abyssal_pending_end_time = 0
    script._combo_abyssal_recent_blink_until = 0
    script._combo_abyssal_recent_blink_target_key = nil
    script._combo_abyssal_recent_blink_caster_key = nil
    script._item_next_allowed_time = {}
    script._item_last_frame_by_meepo = {}
    script._item_frame_budget_consumed = 0
    combo_hex_last_cast = -9999
    script._combo_hex_last_attempt_global = -9999
    script._combo_hex_last_attempt_frame = -1
    script._combo_hex_last_frame_by_meepo = {}
    script._combo_purge_last_global = -9999
    script._combo_purge_last_target_key = nil
    script._combo_purge_last_attempt_global = -9999
    script._combo_purge_last_attempt_frame = -1
    script._combo_purge_last_by_meepo = {}
    combo_hex_last_cast_by_meepo = {}
    combo_poof_last_cast_by_meepo = {}
    combo_attack_next_order_time = 0
    script._combo_logic_next_tick = 0
    script._combo_hold_next_order_time = 0
    script._combo_action_next_order_time = 0
    combo_focus_target_key = nil
    script._combo_state_phase = script.COMBO_PHASE_ABYSSAL
    script._combo_state_target_key = nil
    script._combo_debug_phase = script.COMBO_PHASE_ABYSSAL
    script._combo_debug_reason = "idle"
    script._combo_debug_next_disable = ""
    script._combo_debug_last_non_active_emit = -9999
    script._combo_debug_last_emit = ""
    script._combo_last_net_follow_poof_count = 0
    script._combo_last_net_follow_poof_time = -9999
    script._combo_last_net_follow_poof_reason = ""
    script._combo_net_priority_until = 0
    script._combo_net_priority_target_key = nil
    script._combo_search_next_move_time = 0
    script._combo_search_last_position = nil
    if clear_poof_queue then
        clear_poof_queue()
    else
        poof_cast_queue = {}
        poof_queue_by_meepo = {}
    end
    script._combo_blink_scheduled_time = 0
    script._combo_blink_target = nil
    script._combo_blink_anchor = nil
    script._combo_blink_target_key = nil
    script._combo_blink_last_schedule = -9999
    script._combo_blink_poof_units = {}
    script._combo_blink_post_poof_delay = 0
    script._combo_blink_next_attempt = 0
    script._combo_blink_retry_deadline = 0
    script._combo_blink_last_cast_cmd = -9999
    script.clear_preblink_poof_state()
    script._combo_target_last_seen_time = -9999
    script._tp_interrupt_last_target_key = nil
    script._tp_interrupt_last_time = -9999
end
local function collect_combo_move_units(local_player, local_hero, meepos)
    local units = {}
    local seen = {}
    local local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    local function add_unit(unit)
        if not unit or not is_meepo_instance(unit) or not Entity.IsAlive(unit) then
            return
        end
        local unit_team = tonumber(safe_call(Entity.GetTeamNum, unit) or -2) or -2
        if local_team >= 0 and unit_team ~= local_team then
            return
        end
        local key = get_entity_key(unit)
        if seen[key] then
            return
        end
        seen[key] = true
        units[#units + 1] = unit
    end
    local mode = get_combo_type_index()
    if mode == COMBO_MODE_SELECTED then
        local selected_units = nil
        if local_player and Player and Player.GetSelectedUnits then
            selected_units = safe_call(Player.GetSelectedUnits, local_player)
        end
        if selected_units then
            for i = 1, #selected_units do
                add_unit(selected_units[i])
            end
        end
    else
        for i = 1, #meepos do
            add_unit(meepos[i])
        end
    end
    if #units == 0 then
        add_unit(get_combo_anchor_meepo(local_player, local_hero))
    end
    return units
end
local function collect_owned_meepo_units(local_hero, meepos)
    local units = {}
    if not meepos then
        return units
    end
    local seen = {}
    local local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and is_meepo_instance(meepo) and Entity.IsAlive(meepo) then
            local team = tonumber(safe_call(Entity.GetTeamNum, meepo) or -2) or -2
            if local_team < 0 or team == local_team then
                local key = get_entity_key(meepo)
                if not seen[key] then
                    seen[key] = true
                    units[#units + 1] = meepo
                end
            end
        end
    end
    return units
end
local function build_units_key(units)
    if not units or #units == 0 then
        return ""
    end
    local ids = {}
    for i = 1, #units do
        local unit = units[i]
        local idx = tonumber(safe_call(Entity.GetIndex, unit) or 0) or 0
        if idx > 0 then
            ids[#ids + 1] = idx
        end
    end
    table.sort(ids)
    return table.concat(ids, ",")
end
local function ensure_combo_units_selected(player, units)
    if not player or not units or #units == 0 or not Player then
        return false
    end
    if not Player.GetSelectedUnits or not Player.ClearSelectedUnits or not Player.AddSelectedUnit then
        return false
    end
    local key = build_units_key(units)
    if key == "" then
        return false
    end
    local current = safe_call(Player.GetSelectedUnits, player)
    if current and build_units_key(current) == key then
        combo_last_selection_key = key
        return true
    end
    local cleared = pcall(function()
        Player.ClearSelectedUnits(player)
    end)
    if not cleared then
        return false
    end
    local added_any = false
    for i = 1, #units do
        local unit = units[i]
        if unit and Entity.IsAlive(unit) then
            local ok = pcall(function()
                Player.AddSelectedUnit(player, unit)
            end)
            if ok then
                added_any = true
            end
        end
    end
    if added_any then
        combo_last_selection_key = key
    end
    return added_any
end
local function issue_combo_move_order(player, units, position, now)
    if not player or not units or #units == 0 or not position then
        return false
    end
    local frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if frame >= 0 and frame == combo_move_last_frame then
        return false
    end
    if now < combo_move_next_order_time then
        return false
    end
    if combo_move_last_position then
        local delta = vec_dist_2d(combo_move_last_position, position) or 0
        if delta < C.COMBO_MOVE_MIN_DELTA then
            return false
        end
    end
    combo_move_next_order_time = now + C.COMBO_MOVE_ORDER_INTERVAL
    combo_move_last_position = Vector(position.x or 0, position.y or 0, position.z or 0)
    combo_move_last_frame = frame
    local order_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if not order_type or not issuer_type or not Player or not Player.PrepareUnitOrders then
        return false
    end
    local issued_any = false
    for i = 1, #units do
        local unit = units[i]
        if unit and Entity.IsAlive(unit) then
            local ok = pcall(function()
                Player.PrepareUnitOrders(
                    player,
                    order_type,
                    nil,
                    position,
                    nil,
                    issuer_type,
                    unit,
                    false,
                    true,
                    true,
                    false,
                    "meepo_combo_group_click",
                    false
                )
            end)
            if ok then
                issued_any = true
            end
        end
    end
    return issued_any
end
local function get_modifier_remaining_time(modifier, now)
    if not modifier then
        return 0
    end
    local die_time = tonumber(safe_call(Modifier.GetDieTime, modifier) or 0) or 0
    if die_time > 0 then
        local remaining = die_time - now
        if remaining > 0 then
            return remaining
        end
    end
    local last_applied = tonumber(safe_call(Modifier.GetLastAppliedTime, modifier) or 0) or 0
    local duration = tonumber(safe_call(Modifier.GetDuration, modifier) or 0) or 0
    if last_applied > 0 and duration > 0 then
        local remaining = (last_applied + duration) - now
        if remaining > 0 then
            return remaining
        end
    end
    return 0
end
local function get_target_earthbind_remaining(target, now)
    if not target or not Entity.IsAlive(target) then
        return 0
    end
    local best_remaining = 0
    for i = 1, #C.MODIFIER_NET_CANDIDATES do
        local mod = safe_call(NPC.GetModifier, target, C.MODIFIER_NET_CANDIDATES[i])
        local remaining = get_modifier_remaining_time(mod, now)
        if remaining > best_remaining then
            best_remaining = remaining
        end
    end
    if best_remaining > 0 then
        return best_remaining
    end
    if NPC.GetModifiers and Modifier and Modifier.GetName then
        local mods = safe_call(NPC.GetModifiers, target)
        if mods then
            for i = 1, #mods do
                local mod = mods[i]
                local mod_name = safe_call(Modifier.GetName, mod)
                if mod_name then
                    local lower_name = string.lower(mod_name)
                    if string.find(lower_name, "earthbind", 1, true) then
                        local remaining = get_modifier_remaining_time(mod, now)
                        if remaining > best_remaining then
                            best_remaining = remaining
                        end
                    end
                end
            end
        end
    end
    return best_remaining
end
function script.get_target_modifier_remaining(target, names, now, keyword)
    if not target or not Entity.IsAlive(target) then
        return 0
    end
    local best_remaining = 0
    if names then
        for i = 1, #names do
            local mod = safe_call(NPC.GetModifier, target, names[i])
            local remaining = get_modifier_remaining_time(mod, now)
            if remaining > best_remaining then
                best_remaining = remaining
            end
        end
    end
    if best_remaining > 0 then
        return best_remaining
    end
    if keyword and NPC.GetModifiers and Modifier and Modifier.GetName then
        local mods = safe_call(NPC.GetModifiers, target)
        if mods then
            for i = 1, #mods do
                local mod = mods[i]
                local mod_name = safe_call(Modifier.GetName, mod)
                if mod_name then
                    local lower_name = string.lower(mod_name)
                    if string.find(lower_name, keyword, 1, true) then
                        local remaining = get_modifier_remaining_time(mod, now)
                        if remaining > best_remaining then
                            best_remaining = remaining
                        end
                    end
                end
            end
        end
    end
    return best_remaining
end
function script.get_item_special_value(item, key_primary, key_alt, fallback)
    local value = 0
    if item and Ability.GetSpecialValueFor then
        if key_primary and key_primary ~= "" then
            value = tonumber(safe_call(Ability.GetSpecialValueFor, item, key_primary) or 0) or 0
        end
        if value <= 0 and key_alt and key_alt ~= "" then
            value = tonumber(safe_call(Ability.GetSpecialValueFor, item, key_alt) or 0) or 0
        end
    end
    if value <= 0 and item and Ability.GetLevelSpecialValueFor then
        if key_primary and key_primary ~= "" then
            value = tonumber(safe_call(Ability.GetLevelSpecialValueFor, item, key_primary, -1) or 0) or 0
        end
        if value <= 0 and key_alt and key_alt ~= "" then
            value = tonumber(safe_call(Ability.GetLevelSpecialValueFor, item, key_alt, -1) or 0) or 0
        end
    end
    if value <= 0 then
        return tonumber(fallback or 0) or 0
    end
    return value
end
function script.get_enabled_item_by_names(npc, names)
    if not npc or not names or not NPC.GetItem then
        return nil
    end
    for i = 1, #names do
        local name = names[i]
        if name and is_item_enabled(name) then
            local item = safe_call(NPC.GetItem, npc, name, true)
            if item then
                return item
            end
        end
    end
    return nil
end
function script.can_cast_target_item_now(npc, item)
    if not npc or not item then
        return false
    end
    local name = safe_call(Ability.GetName, item) or ""
    if name ~= "" and not is_item_enabled(name) then
        return false
    end
    if not can_cast_ability_for_npc(npc, item) then
        return false
    end
    local in_phase = safe_call(Ability.IsInAbilityPhase, item)
    if in_phase == true then
        return false
    end
    return true
end
function script.get_item_cast_range(item, fallback)
    local cast_range = tonumber(safe_call(Ability.GetCastRange, item) or 0) or 0
    if cast_range <= 0 then
        cast_range = tonumber(fallback or 0) or 0
    end
    return cast_range
end
function script.get_item_cast_range_for_npc(npc, item, fallback)
    local cast_range = script.get_item_cast_range(item, fallback)
    if cast_range <= 0 then
        cast_range = tonumber(fallback or 0) or 0
    end
    local bonus = tonumber(safe_call(NPC.GetCastRangeBonus, npc) or 0) or 0
    if bonus > 0 then
        cast_range = cast_range + bonus
    end
    return cast_range
end
function script.get_target_hex_remaining(target, now)
    return script.get_target_modifier_remaining(target, script._combo_modifier_sets.hex, now, "sheep")
end
function script.get_target_silence_remaining(target, now)
    return script.get_target_modifier_remaining(target, script._combo_modifier_sets.silence, now, "orchid")
end
function script.get_target_atos_remaining(target, now)
    local remaining = script.get_target_modifier_remaining(target, script._combo_modifier_sets.atos, now, "atos")
    if not target then
        return remaining
    end
    local target_key = get_entity_key(target)
    if target_key and script._combo_atos_pending_target_key == target_key then
        local pending = script._combo_atos_pending_end_time - now
        if pending > remaining then
            remaining = pending
        end
        if pending <= 0 then
            script._combo_atos_pending_target_key = nil
            script._combo_atos_pending_end_time = 0
        end
    end
    return remaining
end
function script.get_target_abyssal_remaining(target, now)
    local remaining = 0
    if target then
        local modifier_remaining = script.get_target_modifier_remaining(target, nil, now, "abyssal")
        if modifier_remaining > remaining then
            remaining = modifier_remaining
        end
        local bash_remaining = script.get_target_modifier_remaining(target, nil, now, "bash")
        if bash_remaining > remaining then
            remaining = bash_remaining
        end
        local target_key = get_entity_key(target)
        if target_key and script._combo_abyssal_pending_target_key == target_key then
            local pending = script._combo_abyssal_pending_end_time - now
            if pending > remaining then
                remaining = pending
            end
            if pending <= 0 then
                script._combo_abyssal_pending_target_key = nil
                script._combo_abyssal_pending_end_time = 0
            end
        end
    end
    return remaining
end
get_earthbind_projectile_speed = function(ability)
    if not ability then
        return C.COMBO_NET_PROJECTILE_SPEED_FALLBACK
    end
    local speed = 0
    if Ability.GetSpecialValueFor then
        speed = tonumber(safe_call(Ability.GetSpecialValueFor, ability, "speed") or 0) or 0
        if speed <= 0 then
            speed = tonumber(safe_call(Ability.GetSpecialValueFor, ability, "projectile_speed") or 0) or 0
        end
    end
    if speed <= 0 and Ability.GetLevelSpecialValueFor then
        speed = tonumber(safe_call(Ability.GetLevelSpecialValueFor, ability, "speed", -1) or 0) or 0
        if speed <= 0 then
            speed = tonumber(safe_call(Ability.GetLevelSpecialValueFor, ability, "projectile_speed", -1) or 0) or 0
        end
    end
    if speed <= 0 then
        speed = C.COMBO_NET_PROJECTILE_SPEED_FALLBACK
    end
    return speed
end
function script.get_earthbind_root_duration(ability)
    if not ability then
        return 2.0
    end
    local duration = 0
    if Ability.GetSpecialValueFor then
        duration = tonumber(safe_call(Ability.GetSpecialValueFor, ability, "duration") or 0) or 0
        if duration <= 0 then
            duration = tonumber(safe_call(Ability.GetSpecialValueFor, ability, "ensnare_duration") or 0) or 0
        end
    end
    if duration <= 0 and Ability.GetLevelSpecialValueFor then
        duration = tonumber(safe_call(Ability.GetLevelSpecialValueFor, ability, "duration", -1) or 0) or 0
        if duration <= 0 then
            duration = tonumber(safe_call(Ability.GetLevelSpecialValueFor, ability, "ensnare_duration", -1) or 0) or 0
        end
    end
    if duration <= 0 then
        duration = 2.0
    end
    return duration
end
local function get_net_cast_range(caster, ability)
    local cast_range = tonumber(safe_call(Ability.GetCastRange, ability) or 0) or 0
    if cast_range <= 0 then
        cast_range = 700
    end
    local bonus = tonumber(safe_call(NPC.GetCastRangeBonus, caster) or 0) or 0
    if bonus > 0 then
        cast_range = cast_range + bonus
    end
    return cast_range
end
function script.get_simple_net_position(caster, target, net, now)
    if not caster or not target or not net then
        return nil
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return nil
    end
    if not Entity.IsAlive(target) then
        return target_pos
    end
    local sample_now = tonumber(now or get_game_time() or 0) or 0
    if get_target_earthbind_remaining(target, sample_now) > 0 then
        return target_pos
    end
    if NPC.IsStunned and safe_call(NPC.IsStunned, target) == true then
        return target_pos
    end
    if NPC.IsRunning and safe_call(NPC.IsRunning, target) ~= true then
        return target_pos
    end
    if NPC.IsTurning and safe_call(NPC.IsTurning, target) == true then
        return target_pos
    end
    local rot = safe_call(Entity.GetRotation, target)
    if not rot or not rot.GetForward then
        return target_pos
    end
    local forward = rot:GetForward()
    if not forward then
        return target_pos
    end
    forward = forward:Normalized()
    local move_speed = tonumber(safe_call(NPC.GetMoveSpeed, target) or 0) or 0
    if move_speed <= 0 then
        return target_pos
    end
    local caster_pos = safe_call(Entity.GetAbsOrigin, caster)
    if not caster_pos then
        return target_pos
    end
    local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
    if cast_point < 0 then
        cast_point = 0
    end
    local speed = get_earthbind_projectile_speed(net)
    local function build_predicted(base_pos)
        local dist = vec_dist_2d(caster_pos, base_pos) or 0
        local face_time = tonumber(safe_call(NPC.GetTimeToFacePosition, caster, base_pos) or 0) or 0
        face_time = math.max(0, math.min(C.COMBO_NET_FACE_TIME_CAP, face_time))
        local travel_time = face_time + cast_point + (dist / math.max(1, speed))
        travel_time = math.max(0, math.min(0.80, travel_time))
        local lead_x = (forward.x or 0) * move_speed * travel_time
        local lead_y = (forward.y or 0) * move_speed * travel_time
        local lead_len = math.sqrt((lead_x * lead_x) + (lead_y * lead_y))
        if lead_len > 340 and lead_len > 0 then
            local scale = 340 / lead_len
            lead_x = lead_x * scale
            lead_y = lead_y * scale
        end
        return Vector(
            (target_pos.x or 0) + lead_x,
            (target_pos.y or 0) + lead_y,
            target_pos.z or 0
        )
    end
    local pass1 = build_predicted(target_pos)
    if not pass1 then
        return target_pos
    end
    return build_predicted(pass1) or pass1
end
local function get_effective_earthbind_remaining(target, now)
    local remaining = get_target_earthbind_remaining(target, now)
    if not target then
        return remaining
    end
    local target_key = get_entity_key(target)
    if target_key and script._combo_net_pending_target_key == target_key then
        local pending = script._combo_net_pending_end_time - now
        local pending_arrival = tonumber(script._combo_net_pending_arrival_time or 0) or 0
        local pending_still_valid = true
        if pending_arrival > 0 and now > (pending_arrival + C.COMBO_NET_PENDING_CONFIRM_GRACE) then
            if remaining <= 0.01 then
                pending_still_valid = false
            end
        end
        if pending_still_valid and pending > remaining then
            remaining = pending
        end
        if (not pending_still_valid) or pending <= 0 then
            script._combo_net_pending_target_key = nil
            script._combo_net_pending_end_time = 0
            script._combo_net_pending_arrival_time = 0
        end
    end
    local atos_remaining = script.get_target_atos_remaining(target, now)
    if atos_remaining > remaining then
        remaining = atos_remaining
    end
    local abyssal_remaining = script.get_target_abyssal_remaining(target, now)
    if abyssal_remaining > remaining then
        remaining = abyssal_remaining
    end
    return remaining
end
local function get_confirmed_control_remaining(target, now)
    if not target or not Entity.IsAlive(target) then
        return 0
    end
    local remaining = get_target_earthbind_remaining(target, now)
    local hex_remaining = script.get_target_modifier_remaining(target, script._combo_modifier_sets.hex, now, "hex")
    if hex_remaining > remaining then
        remaining = hex_remaining
    end
    local atos_remaining = script.get_target_modifier_remaining(target, script._combo_modifier_sets.atos, now, "atos")
    if atos_remaining > remaining then
        remaining = atos_remaining
    end
    local abyssal_remaining = script.get_target_modifier_remaining(target, nil, now, "abyssal")
    if abyssal_remaining > remaining then
        remaining = abyssal_remaining
    end
    local bash_remaining = script.get_target_modifier_remaining(target, nil, now, "bash")
    if bash_remaining > remaining then
        remaining = bash_remaining
    end
    return remaining
end
local function is_net_projectile_in_flight(target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    local target_key = get_entity_key(target)
    if not target_key or script._combo_net_pending_target_key ~= target_key then
        return false
    end
    local pending_end = tonumber(script._combo_net_pending_end_time or 0) or 0
    if pending_end <= now then
        script._combo_net_pending_target_key = nil
        script._combo_net_pending_end_time = 0
        script._combo_net_pending_arrival_time = 0
        return false
    end
    local arrival = tonumber(script._combo_net_pending_arrival_time or 0) or 0
    return arrival > now
end
function script.get_modifier_state_enum(state_name)
    if not Enum or not Enum.ModifierState then
        return nil
    end
    return Enum.ModifierState[state_name]
end
function script.has_modifier_state(npc, state_name)
    local state = script.get_modifier_state_enum(state_name)
    if not npc or not state or not NPC.HasState then
        return false
    end
    return safe_call(NPC.HasState, npc, state) == true
end
function script.get_control_break_reason(target, single_target)
    if not script.is_combo_option_enabled(ui.combo_control_break_checks) then
        return nil
    end
    if not target or not Entity.IsAlive(target) then
        return "invalid_target"
    end
    if script.has_modifier_state(target, "MODIFIER_STATE_INVULNERABLE") then
        return "invulnerable"
    end
    if script.has_modifier_state(target, "MODIFIER_STATE_UNTARGETABLE")
        or script.has_modifier_state(target, "MODIFIER_STATE_UNTARGETABLE_ENEMY") then
        return "untargetable"
    end
    if script.has_modifier_state(target, "MODIFIER_STATE_MAGIC_IMMUNE")
        or script.has_modifier_state(target, "MODIFIER_STATE_DEBUFF_IMMUNE") then
        return "debuff_immune"
    end
    if single_target then
        if script.is_target_linkens_protected(target) then
            return "linkens"
        end
        if safe_call(NPC.HasModifier, target, "modifier_item_lotus_orb_active") == true then
            return "lotus"
        end
    end
    return nil
end
function script.set_combo_debug_state(phase, reason, next_disable)
    local now = 0
    if GameRules and GameRules.GetGameTime then
        now = tonumber(safe_call(GameRules.GetGameTime)) or 0
    end
    script._combo_debug_last_phase = script._combo_debug_last_phase or ""
    script._combo_debug_last_reason = script._combo_debug_last_reason or ""
    script._combo_debug_last_change = script._combo_debug_last_change or -9999
    script._combo_debug_last_non_active_emit = script._combo_debug_last_non_active_emit or -9999
    script._combo_debug_last_emit_time = script._combo_debug_last_emit_time or -9999
    local incoming_phase = script._combo_debug_phase
    local incoming_reason = script._combo_debug_reason
    local incoming_next_disable = script._combo_debug_next_disable
    if phase and phase ~= "" then
        incoming_phase = phase
    end
    if reason and reason ~= "" then
        incoming_reason = reason
    end
    if next_disable ~= nil then
        incoming_next_disable = next_disable
    end
    if incoming_reason == "active" then
        local phase_changed = incoming_phase ~= script._combo_debug_last_phase
        local since_non_active = now - (tonumber(script._combo_debug_last_non_active_emit or -9999) or -9999)
        if (not phase_changed) and since_non_active < 0.30 then
            return
        end
    end
    local changed = (incoming_phase ~= script._combo_debug_last_phase)
        or (incoming_reason ~= script._combo_debug_last_reason)
        or (incoming_next_disable ~= script._combo_debug_next_disable)
    if changed then
        script._combo_debug_phase = incoming_phase
        script._combo_debug_reason = incoming_reason
        script._combo_debug_next_disable = incoming_next_disable
        script._combo_debug_last_phase = incoming_phase
        script._combo_debug_last_reason = incoming_reason
        script._combo_debug_last_change = now
        if incoming_reason ~= "active" then
            script._combo_debug_last_non_active_emit = now
        end
    end
    if not changed then
        return
    end
    if not script.is_combo_option_enabled(ui.combo_debug) then
        return
    end
    local emit_gap = tonumber(C and C.COMBO_DEBUG_LOG_MIN_GAP or 0.12) or 0.12
    if (now - (tonumber(script._combo_debug_last_emit_time or -9999) or -9999)) < emit_gap then
        return
    end
    local line = tostring(script._combo_debug_phase) .. " | " .. tostring(script._combo_debug_reason) .. " | " .. tostring(script._combo_debug_next_disable or "")
    if line ~= script._combo_debug_last_emit then
        script._combo_debug_last_emit = line
        script._combo_debug_last_emit_time = now
        script._dbg("combo_state", line)
    end
end
function script.resolve_combo_state_phase(target_key, has_abyssal_item, abyssal_ready, abyssal_remaining, hex_ready_anywhere, hex_remaining, net_enabled, net_actionable, now)
    if not target_key or target_key ~= script._combo_state_target_key then
        script._combo_state_target_key = target_key
        script._combo_state_phase = script.COMBO_PHASE_ABYSSAL
    end
    local net_ok = net_enabled and net_actionable == true
    local hex_active = hex_remaining and hex_remaining > 0
    local prefer_hex_open = hex_ready_anywhere and not has_abyssal_item
    local lock_now = tonumber(now or 0) or 0
    local net_priority_lock =
        net_enabled
        and target_key ~= nil
        and script._combo_net_priority_target_key == target_key
        and (tonumber(script._combo_net_priority_until or 0) or 0) > lock_now
    if not script.is_combo_option_enabled(ui.combo_state_machine) then
        if has_abyssal_item and (abyssal_ready or abyssal_remaining > 0.08) then
            script._combo_state_phase = script.COMBO_PHASE_ABYSSAL
        elseif net_priority_lock then
            script._combo_state_phase = script.COMBO_PHASE_NET_CHAIN
        elseif prefer_hex_open or (hex_active and not net_ok) then
            script._combo_state_phase = script.COMBO_PHASE_HEX
        elseif net_ok then
            script._combo_state_phase = script.COMBO_PHASE_NET_CHAIN
        else
            script._combo_state_phase = script.COMBO_PHASE_POOF_ATTACK
        end
        return script._combo_state_phase
    end
    if has_abyssal_item and (abyssal_ready or abyssal_remaining > 0.08) then
        script._combo_state_phase = script.COMBO_PHASE_ABYSSAL
    elseif net_priority_lock then
        script._combo_state_phase = script.COMBO_PHASE_NET_CHAIN
    elseif prefer_hex_open or (hex_active and not net_ok) then
        script._combo_state_phase = script.COMBO_PHASE_HEX
    elseif net_ok then
        script._combo_state_phase = script.COMBO_PHASE_NET_CHAIN
    else
        script._combo_state_phase = script.COMBO_PHASE_POOF_ATTACK
    end
    return script._combo_state_phase
end
local function get_poof_channel_duration(poof)
    if not poof then
        return C.COMBO_POOF_CHANNEL_FALLBACK
    end
    local duration = 0
    if Ability.GetLevelSpecialValueFor then
        duration = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "teleport_duration", -1) or 0) or 0
        if duration <= 0 then
            duration = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "poof_duration", -1) or 0) or 0
        end
        if duration <= 0 then
            duration = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "channel_time", -1) or 0) or 0
        end
    end
    if duration <= 0 then
        duration = C.COMBO_POOF_CHANNEL_FALLBACK
    end
    return duration
end
local function get_poof_damage_radius(poof)
    if not poof then
        return C.COMBO_POOF_DAMAGE_RADIUS_FALLBACK
    end
    local radius = 0
    if Ability.GetLevelSpecialValueFor then
        radius = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "radius", -1) or 0) or 0
        if radius <= 0 then
            radius = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "poof_radius", -1) or 0) or 0
        end
        if radius <= 0 then
            radius = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "damage_radius", -1) or 0) or 0
        end
    end
    if radius <= 0 then
        radius = C.COMBO_POOF_DAMAGE_RADIUS_FALLBACK
    end
    return radius
end
local function get_allowed_poof_anchor_distance(max_radius)
    local radius = max_radius
    if not radius or radius <= 0 then
        radius = C.COMBO_POOF_DAMAGE_RADIUS_FALLBACK
    end
    local pad = tonumber(C.COMBO_POOF_DAMAGE_RADIUS_PAD or 0) or 0
    if pad < 0 then
        pad = 0
    end
    return radius + pad
end
can_schedule_poof = function(meepo, now)
    if not meepo or not Entity.IsAlive(meepo) then
        return false, nil
    end
    local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
    if not poof or not can_cast_ability_for_npc(meepo, poof) then
        return false, poof
    end
    local meepo_key = get_entity_key(meepo)
    local last_cast = combo_poof_last_cast_by_meepo[meepo_key] or -9999
    if now - last_cast < C.COMBO_POOF_CASTER_RECAST_DELAY then
        return false, poof
    end
    local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
    local channelling = safe_call(Ability.IsChannelling, poof)
    if in_phase == true or channelling == true then
        return false, poof
    end
    return true, poof
end
script.can_schedule_poof = can_schedule_poof
local function get_required_root_for_poof(ready_count, max_channel)
    if ready_count <= 0 then
        return C.COMBO_POOF_ROOT_MIN_REMAINING
    end
    local stagger = C.COMBO_POOF_STAGGER * math.max(0, ready_count - 1)
    local required = max_channel + stagger + C.COMBO_POOF_SAFE_ROOT_BUFFER
    if required < C.COMBO_POOF_ROOT_MIN_REMAINING then
        required = C.COMBO_POOF_ROOT_MIN_REMAINING
    end
    return required
end
local function get_ready_poof_burst_info(units, now)
    local ready_count = 0
    local max_radius = 0
    local max_channel = 0
    for i = 1, #units do
        local meepo = units[i]
        local ready, poof = can_schedule_poof(meepo, now)
        if ready and poof then
            ready_count = ready_count + 1
            local radius = get_poof_damage_radius(poof)
            if radius > max_radius then
                max_radius = radius
            end
            local channel = get_poof_channel_duration(poof)
            if channel > max_channel then
                max_channel = channel
            end
        end
    end
    return ready_count, max_radius, max_channel
end
local function should_refresh_root_for_poof(units, target, now, remaining_root)
    if not target or remaining_root <= 0 then
        return false
    end
    if not is_combo_spell_enabled("poof", ui.combo_use_poof) then
        return false
    end
    local ready_count, _, max_channel = get_ready_poof_burst_info(units, now)
    if ready_count <= 0 then
        return false
    end
    local required_root = get_required_root_for_poof(ready_count, max_channel)
    return remaining_root < required_root
end
local function get_ordered_units(units)
    if not units then
        return {}
    end
    local ordered = {}
    for i = 1, #units do
        ordered[#ordered + 1] = units[i]
    end
    table.sort(ordered, function(a, b)
        local a_idx = tonumber(safe_call(Entity.GetIndex, a) or 0) or 0
        local b_idx = tonumber(safe_call(Entity.GetIndex, b) or 0) or 0
        return a_idx < b_idx
    end)
    return ordered
end
local function queue_poof_cast(meepo, target, cast_time, reason)
    if not meepo or not target then
        return false
    end
    if not Entity.IsAlive(meepo) or not Entity.IsAlive(target) then
        return false
    end
    local key = get_entity_key(meepo)
    if not key or poof_queue_by_meepo[key] then
        return false
    end
    poof_queue_by_meepo[key] = true
    poof_cast_queue[#poof_cast_queue + 1] = {
        time = cast_time or 0,
        meepo = meepo,
        target = target,
        key = key,
        reason = reason or "meepo_poof_queue",
    }
    return true
end
clear_poof_queue = function()
    poof_cast_queue = {}
    poof_queue_by_meepo = {}
end
has_pending_poof_queue = function()
    return poof_cast_queue and #poof_cast_queue > 0
end
local function resolve_poof_target_for_meepo(meepo, fallback_target, enemy_target_pos)
    if not meepo or not fallback_target then
        return fallback_target
    end
    if not enemy_target_pos or not Entity.IsAlive(meepo) then
        return fallback_target
    end
    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
    local dist = vec_dist_2d(meepo_pos, enemy_target_pos)
    if not dist then
        return fallback_target
    end
    local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
    local radius = get_poof_damage_radius(poof)
    if dist <= (radius + 24) then
        return meepo
    end
    return fallback_target
end
schedule_poof_burst = function(units, target, now, reason, stagger, enemy_target_pos)
    if not units or #units == 0 or not target then
        return 0
    end
    local ordered = get_ordered_units(units)
    local cast_stagger = stagger
    if cast_stagger == nil then
        cast_stagger = C.COMBO_POOF_STAGGER
    end
    if cast_stagger < 0 then
        cast_stagger = 0
    end
    local scheduled = 0
    for i = 1, #ordered do
        local meepo = ordered[i]
        local ready = can_schedule_poof(meepo, now)
        if ready then
            local cast_time = now + (scheduled * cast_stagger)
            local poof_target = resolve_poof_target_for_meepo(meepo, target, enemy_target_pos)
            if queue_poof_cast(meepo, poof_target, cast_time, reason) then
                scheduled = scheduled + 1
            end
        end
    end
    return scheduled
end
script.schedule_poof_burst = schedule_poof_burst
function script.process_poof_queue(now)
    if not poof_cast_queue or #poof_cast_queue == 0 then
        return
    end
    local has_due_sync = false
    for i = 1, #poof_cast_queue do
        local q = poof_cast_queue[i]
        if q and now >= (q.time or 0) and is_sync_poof_reason(q.reason) then
            has_due_sync = true
            break
        end
    end
    if (not has_due_sync) and now < (script._poof_next_order_time or 0) then
        return
    end
    local remaining = {}
    local cast_issued = false
    for i = 1, #poof_cast_queue do
        local item = poof_cast_queue[i]
        local keep = true
        if not item or not item.meepo or not item.target then
            keep = false
        elseif not Entity.IsAlive(item.meepo) or not Entity.IsAlive(item.target) then
            keep = false
        elseif now >= (item.time or 0) then
            local poof = safe_call(NPC.GetAbility, item.meepo, C.ABILITY_POOF)
            local cast_ok = false
            if poof and can_cast_ability_for_npc(item.meepo, poof) then
                local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
                local channelling = safe_call(Ability.IsChannelling, poof)
                if in_phase ~= true and channelling ~= true then
                    cast_ok = pcall(function()
                        Ability.CastTarget(
                            poof,
                            item.target,
                            false,
                            true,
                            true,
                            item.reason
                        )
                    end)
                    if cast_ok then
                        combo_poof_last_cast_by_meepo[item.key] = now
                        if is_sync_poof_reason(item.reason) then
                        else
                            cast_issued = true
                            script._poof_next_order_time = now + 0.08
                        end
                    end
                end
            end
            if cast_ok then
                keep = false
            else
                item.time = now + 0.03
                keep = true
            end
        end
        if keep then
            remaining[#remaining + 1] = item
        elseif item and item.key then
            poof_queue_by_meepo[item.key] = nil
        end
        if cast_issued then
            for j = i + 1, #poof_cast_queue do
                local rest = poof_cast_queue[j]
                if rest and rest.key then
                    remaining[#remaining + 1] = rest
                end
            end
            break
        end
    end
    poof_cast_queue = remaining
end
local function choose_poof_anchor(units, target_pos, max_anchor_distance, allow_relaxed_fallback)
    local best = nil
    local best_dist = nil
    local best_non_main = nil
    local best_non_main_dist = nil
    local best_any = nil
    local best_any_dist = nil
    local best_any_non_main = nil
    local best_any_non_main_dist = nil
    local local_hero = safe_call(Heroes.GetLocal)
    local main_meepo = get_main_meepo(local_hero)
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local pos = safe_call(Entity.GetAbsOrigin, meepo)
            local d = vec_dist_2d(pos, target_pos)
            if d then
                if (not best_any_dist) or d < best_any_dist then
                    best_any = meepo
                    best_any_dist = d
                end
                if meepo ~= main_meepo and ((not best_any_non_main_dist) or d < best_any_non_main_dist) then
                    best_any_non_main = meepo
                    best_any_non_main_dist = d
                end
                if (not max_anchor_distance) or d <= max_anchor_distance then
                    if (not best_dist) or d < best_dist then
                        best = meepo
                        best_dist = d
                    end
                    if meepo ~= main_meepo then
                        if (not best_non_main_dist) or d < best_non_main_dist then
                            best_non_main = meepo
                            best_non_main_dist = d
                        end
                    end
                end
            end
        end
    end
    if best_non_main then
        return best_non_main, best_non_main_dist
    end
    if best then
        return best, best_dist
    end
    if allow_relaxed_fallback then
        if best_any_non_main then
            return best_any_non_main, best_any_non_main_dist
        end
        return best_any, best_any_dist
    end
    return nil, nil
end
function script.get_world_cursor_position()
    if not Input or not Input.GetWorldCursorPos then
        return nil
    end
    local ok, pos = pcall(function()
        return Input.GetWorldCursorPos()
    end)
    if ok then
        return pos
    end
    return nil
end
function script.is_bind_pressed(bind)
    if not bind then
        return false
    end
    if bind.IsPressed then
        local ok, pressed = pcall(function()
            return bind:IsPressed()
        end)
        if ok and pressed == true then
            return true
        end
    end
    if bind.IsDown then
        local ok, down = pcall(function()
            return bind:IsDown()
        end)
        if ok and down == true then
            return true
        end
    end
    return false
end
function script.is_bind_just_pressed(bind, state_key)
    local down = false
    local pressed = false
    if bind then
        if bind.IsPressed then
            local ok, value = pcall(function()
                return bind:IsPressed()
            end)
            if ok and value == true then
                pressed = true
            end
        end
        if bind.IsDown then
            local ok, value = pcall(function()
                return bind:IsDown()
            end)
            if ok and value == true then
                down = true
            end
        end
    end
    local states = script._utility_bind_down_state or {}
    script._utility_bind_down_state = states
    if state_key then
        local was_down = states[state_key] == true
        states[state_key] = down
        if pressed then
            return true
        end
        return down and not was_down
    end
    if pressed then
        return true
    end
    return down
end
function script.schedule_poof_self(units, now, reason)
    if not units or #units == 0 then
        return 0
    end
    local ordered = get_ordered_units(units)
    local scheduled = 0
    for i = 1, #ordered do
        local meepo = ordered[i]
        local ready = can_schedule_poof(meepo, now)
        if ready then
            local cast_time = now
            if queue_poof_cast(meepo, meepo, cast_time, reason) then
                scheduled = scheduled + 1
            end
        end
    end
    return scheduled
end
function script.clear_blink_schedule()
    script._combo_blink_scheduled_time = 0
    script._combo_blink_target = nil
    script._combo_blink_anchor = nil
    script._combo_blink_target_key = nil
    script._combo_blink_last_schedule = -9999
    script._combo_blink_poof_units = {}
    script._combo_blink_post_poof_delay = 0
    script._combo_blink_poof_prescheduled = false
    script._combo_blink_next_attempt = 0
    script._combo_blink_retry_deadline = 0
    script.clear_preblink_poof_state()
    local now = get_game_time()
    if combo_move_next_order_time > (now + C.COMBO_MOVE_ORDER_INTERVAL) then
        combo_move_next_order_time = now + C.COMBO_MOVE_ORDER_INTERVAL
    end
end
function script.clear_preblink_poof_state()
    script._combo_preblink_phase = "idle"
    script._combo_preblink_target_key = nil
    script._combo_preblink_anchor_key = nil
    script._combo_preblink_poof_sent_time = 0
    script._combo_preblink_wait_until = 0
    script._combo_preblink_sent_set = {}
end
local function get_preblink_delay_sec()
    if ui.combo_blink_pre_poof_delay_ms and ui.combo_blink_pre_poof_delay_ms.Get then
        local ok, v = pcall(function()
            return ui.combo_blink_pre_poof_delay_ms:Get()
        end)
        if ok and v ~= nil then
            local ms = tonumber(v) or 500
            if ms < 0 then
                ms = 0
            elseif ms > 2000 then
                ms = 2000
            end
            return ms / 1000.0
        end
    end
    return 0.50
end
function script.can_cast_blink_now(npc, blink)
    if not npc or not blink then
        return false
    end
    if Ability and Ability.IsReady then
        local ready = safe_call(Ability.IsReady, blink)
        if ready ~= nil and ready ~= true then
            return false
        end
    end
    if not can_cast_ability_for_npc(npc, blink) then
        return false
    end
    local in_phase = safe_call(Ability.IsInAbilityPhase, blink)
    if in_phase == true then
        return false
    end
    return true
end
function script.is_linken_breaker_item_enabled(item_name)
    if not item_name or item_name == "" then
        return false
    end
    if ui.items_linken_breakers and ui.items_linken_breakers.Get then
        local ok, enabled = pcall(function()
            return ui.items_linken_breakers:Get(item_name)
        end)
        if ok then
            return enabled == true
        end
    end
    return false
end
function script.is_linkens_item_ready(item)
    if not item then
        return false
    end
    if Ability and Ability.IsReady then
        local ready = safe_call(Ability.IsReady, item)
        if ready ~= nil then
            return ready == true
        end
    end
    local cd = tonumber(safe_call(Ability.GetCooldown, item) or 0) or 0
    return cd <= 0.05
end
function script.is_target_linkens_protected(target)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if NPC.IsLinkensProtected then
        local protected = safe_call(NPC.IsLinkensProtected, target)
        if protected ~= nil and protected == true then
            return true
        end
    end
    local sphere = safe_call(NPC.GetItem, target, "item_sphere", true)
    if sphere and script.is_linkens_item_ready(sphere) then
        return true
    end
    local mirror = safe_call(NPC.GetItem, target, "item_mirror_shield", true)
    if mirror and script.is_linkens_item_ready(mirror) then
        return true
    end
    if safe_call(NPC.HasModifier, target, "modifier_item_sphere_target") == true then
        return true
    end
    if safe_call(NPC.HasModifier, target, "modifier_item_sphere") == true then
        if not sphere then
            return true
        end
    end
    if safe_call(NPC.HasModifier, target, "modifier_item_mirror_shield") == true then
        if not mirror then
            return true
        end
    end
    return false
end
function script.should_combo_surprise_hold(local_hero, target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if (script._combo_blink_scheduled_time or 0) > now then
        return true
    end
    if (script._combo_hold_next_order_time or 0) > now then
        return true
    end
    if has_pending_poof_queue and has_pending_poof_queue() then
        return true
    end
    local anchor = get_main_meepo(local_hero)
    if not anchor or not Entity.IsAlive(anchor) then
        return false
    end
    local blink = get_blink_item(anchor)
    if not script.can_cast_blink_now(anchor, blink) then
        return false
    end
    local anchor_pos = safe_call(Entity.GetAbsOrigin, anchor)
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not anchor_pos or not target_pos then
        return false
    end
    local dist = vec_dist_2d(anchor_pos, target_pos) or 0
    local blink_range = script.get_item_cast_range_for_npc(anchor, blink, 1200)
    return dist > 0 and dist <= (blink_range + 80)
end
function script.cast_combo_blink(anchor, target, now, reason_tag)
    if not anchor or not target then
        return false
    end
    local blink = get_blink_item(anchor)
    if not script.can_cast_blink_now(anchor, blink) then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    local anchor_pos = safe_call(Entity.GetAbsOrigin, anchor)
    if not target_pos or not anchor_pos then
        return false
    end
    local dist = vec_dist_2d(anchor_pos, target_pos) or 0
    local blink_range = script.get_item_cast_range_for_npc(anchor, blink, 1200)
    if blink_range <= 0 then
        blink_range = 1200
    end
    if dist <= 40 then
        return false
    end
    local cast_pos = target_pos
    if dist > blink_range then
        local dx = (target_pos.x or 0) - (anchor_pos.x or 0)
        local dy = (target_pos.y or 0) - (anchor_pos.y or 0)
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
            local scale = blink_range / len
            cast_pos = Vector(
                (anchor_pos.x or 0) + dx * scale,
                (anchor_pos.y or 0) + dy * scale,
                target_pos.z or anchor_pos.z or 0
            )
        end
    end
    local name = "blink_" .. tostring(anchor)
    local next_ok = script._cast_next_allowed_time[name] or -9999
    if now < next_ok then
        return false
    end
    local ok = false
    local issued_by = "none"
    local local_player = safe_call(Players.GetLocal)
    local order_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if script.is_direct_cast_mode() then
        ok = pcall(function()
            Ability.CastPosition(
                blink,
                cast_pos,
                false,
                true,
                true,
                reason_tag or "meepo_combo_blink_simple",
                true
            )
        end)
        if ok then
            issued_by = "ability_cast"
        end
    end
    if not ok and local_player and order_type and issuer_type and Player and Player.PrepareUnitOrders then
        ok = pcall(function()
            Player.PrepareUnitOrders(
                local_player,
                order_type,
                nil,
                cast_pos,
                blink,
                issuer_type,
                anchor,
                false,
                true,
                true,
                true,
                reason_tag or "meepo_combo_blink_simple",
                true
            )
        end)
        if ok then
            issued_by = "prepare_order"
        end
    end
    if (not ok) and (not script.is_direct_cast_mode()) then
        ok = pcall(function()
            Ability.CastPosition(
                blink,
                cast_pos,
                false,
                true,
                true,
                reason_tag or "meepo_combo_blink_simple",
                true
            )
        end)
        if ok then
            issued_by = "ability_cast"
        end
    end
    if ok then
        script._combo_blink_last_cast_cmd = now
        script._cast_next_allowed_time[name] = now + C.GENERIC_CAST_INTERVAL
        set_combo_action_lock(now, C.GENERIC_CAST_INTERVAL)
        script._dbg("blink", string.format("issued via %s dist %.0f range %.0f", issued_by, dist, blink_range))
    else
        script._dbg("blink", string.format("failed dist %.0f range %.0f", dist, blink_range))
    end
    return ok == true
end
function script.has_ready_hex_item_for_blink(units)
    if not units or #units == 0 then
        return false
    end
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) and NPC.GetItem then
            local hex = safe_call(NPC.GetItem, meepo, C.ITEM_HEX, true)
            if hex then
                local name = safe_call(Ability.GetName, hex)
                local enabled = true
                if name and name ~= "" then
                    enabled = is_item_enabled(name)
                end
                if enabled and can_cast_ability_for_npc(meepo, hex) and safe_call(Ability.IsInAbilityPhase, hex) ~= true then
                    return true
                end
            end
        end
    end
    return false
end
function script.try_combo_blink_sync(local_hero, units, target, now, net_units)
    if not target or not Entity.IsAlive(target) then
        script.clear_preblink_poof_state()
        return false
    end
    local anchor = get_main_meepo(local_hero)
    if not anchor or not Entity.IsAlive(anchor) then
        script.clear_preblink_poof_state()
        return false
    end
    local blink = get_blink_item(anchor)
    if not script.can_cast_blink_now(anchor, blink) then
        script.clear_preblink_poof_state()
        return false
    end
    if script._combo_blink_scheduled_time > 0 then
        script.clear_blink_schedule()
    end
    if now < (script._combo_blink_last_schedule or -9999) + C.COMBO_BLINK_RECAST_DELAY then
        script.clear_preblink_poof_state()
        return false
    end
    local target_key = get_entity_key(target)
    local anchor_key = get_entity_key(anchor)
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    local poof_units = (net_units and #net_units > 0) and net_units or units
    local ready_casters = {}
    local poof_enabled = script.is_combo_option_enabled(ui.combo_poof_before_blink) and is_combo_spell_enabled("poof", ui.combo_use_poof)
    if poof_enabled and poof_units and #poof_units > 0 then
        for i = 1, #poof_units do
            local meepo = poof_units[i]
            if meepo and meepo ~= anchor and Entity.IsAlive(meepo) then
                local ready = can_schedule_poof(meepo, now)
                if ready then
                    ready_casters[#ready_casters + 1] = meepo
                end
            end
        end
    end
    local preblink_active_for_pair =
        script._combo_preblink_phase ~= "idle"
        and script._combo_preblink_target_key == target_key
        and script._combo_preblink_anchor_key == anchor_key
    if poof_enabled and (#ready_casters > 0 or preblink_active_for_pair) then
        local state_changed = false
        if script._combo_preblink_target_key ~= target_key then
            state_changed = true
        end
        if script._combo_preblink_anchor_key ~= anchor_key then
            state_changed = true
        end
        if state_changed then
            script.clear_preblink_poof_state()
        end
        if script._combo_preblink_phase == "idle" then
            script._combo_preblink_phase = "poof"
            script._combo_preblink_target_key = target_key
            script._combo_preblink_anchor_key = anchor_key
            script._combo_preblink_poof_sent_time = 0
            script._combo_preblink_wait_until = 0
            script._combo_preblink_sent_set = script._combo_preblink_sent_set or {}
        end
        if script._combo_preblink_phase == "poof" then
            for i = 1, #poof_units do
                local meepo = poof_units[i]
                if meepo and meepo ~= anchor and Entity.IsAlive(meepo) then
                    local meepo_key = get_entity_key(meepo)
                    if not script._combo_preblink_sent_set[meepo_key] then
                        local ready, poof = can_schedule_poof(meepo, now)
                        if ready and poof then
                            local poof_target = resolve_poof_target_for_meepo(meepo, anchor, target_pos)
                            local cast_ok = pcall(function()
                                Ability.CastTarget(
                                    poof,
                                    poof_target,
                                    false,
                                    true,
                                    true,
                                    "meepo_poof_before_blink"
                                )
                            end)
                            script._combo_preblink_sent_set[meepo_key] = true
                            if cast_ok then
                                combo_poof_last_cast_by_meepo[meepo_key] = now
                                if (script._combo_preblink_poof_sent_time or 0) <= 0 then
                                    script._combo_preblink_poof_sent_time = now
                                end
                                script._poof_next_order_time = now + 0.05
                                script._dbg("blink", "pre-poof cast")
                            end
                            return true
                        else
                            script._combo_preblink_sent_set[meepo_key] = true
                        end
                    end
                end
            end
            if (script._combo_preblink_poof_sent_time or 0) <= 0 then
                script._combo_preblink_poof_sent_time = now
            end
            script._combo_preblink_wait_until = script._combo_preblink_poof_sent_time + get_preblink_delay_sec()
            script._combo_preblink_phase = "wait"
            return true
        end
        if script._combo_preblink_phase == "wait" then
            if now < (script._combo_preblink_wait_until or 0) then
                return true
            end
            script._combo_preblink_phase = "blink"
        end
    else
        script.clear_preblink_poof_state()
    end
    local blinked = script.cast_combo_blink(anchor, target, now, "meepo_combo_blink_simple")
    if not blinked then
        if script._combo_preblink_phase == "blink" then
            local retry_deadline = tonumber(script._combo_blink_retry_deadline or 0) or 0
            if retry_deadline <= now then
                script._combo_blink_retry_deadline = now + 0.25
                return true
            end
            if now <= retry_deadline then
                return true
            end
            script.clear_preblink_poof_state()
        end
        return false
    end
    script._combo_blink_last_schedule = now
    script._combo_blink_retry_deadline = 0
    local hex_units = (net_units and #net_units > 0) and net_units or units
    local hex_ready_for_blink = script.has_ready_hex_item_for_blink(hex_units)
    if not hex_ready_for_blink then
        script.try_main_earthbind_after_blink(anchor, target, now)
    elseif clear_poof_queue then
        clear_poof_queue()
    end
    if (not hex_ready_for_blink) and (not poof_enabled) and #ready_casters > 0 then
        schedule_poof_burst(ready_casters, anchor, now + 0.02, "meepo_combo_poof_sync", 0)
    end
    script.clear_preblink_poof_state()
    return true
end
function script.try_main_earthbind_after_blink(anchor, target, now)
    if not anchor or not target or not Entity.IsAlive(anchor) or not Entity.IsAlive(target) then
        return false
    end
    if not is_combo_spell_enabled("net", ui.combo_use_net) then
        return false
    end
    if script.get_control_break_reason(target, false) then
        return false
    end
    local net = safe_call(NPC.GetAbility, anchor, C.ABILITY_NET)
    if not net or not can_cast_ability_for_npc(anchor, net) then
        return false
    end
    if safe_call(Ability.IsInAbilityPhase, net) == true then
        return false
    end
    local caster_key = get_entity_key(anchor)
    local last_cast = combo_net_last_cast_by_meepo[caster_key] or -9999
    if now - last_cast < C.COMBO_NET_CASTER_RECAST_DELAY then
        return false
    end
    if now - combo_net_last_global_cast < C.COMBO_NET_GLOBAL_RECAST_DELAY then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    local caster_pos = safe_call(Entity.GetAbsOrigin, anchor)
    if not target_pos or not caster_pos then
        return false
    end
    local cast_pos = script.get_simple_net_position(anchor, target, net, now) or target_pos
    local max_cast_dist = get_net_cast_range(anchor, net) + C.COMBO_NET_RANGE_PADDING
    local dist = vec_dist_2d(caster_pos, cast_pos)
    if dist and dist > max_cast_dist then
        cast_pos = target_pos
        dist = vec_dist_2d(caster_pos, cast_pos)
        if not dist or dist > max_cast_dist then
            return false
        end
    end
    local ok = pcall(function()
        Ability.CastPosition(
            net,
            cast_pos,
            false,
            true,
            true,
            "meepo_combo_blink_main_net",
            false
        )
    end)
    if not ok then
        return false
    end
    combo_net_last_cast_by_meepo[caster_key] = now
    combo_net_last_global_cast = now
    local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
    if cast_point < 0 then
        cast_point = 0
    end
    local turn_time = tonumber(safe_call(NPC.GetTimeToFacePosition, anchor, cast_pos) or 0) or 0
    if turn_time < 0 then
        turn_time = 0
    elseif turn_time > C.COMBO_NET_FACE_TIME_CAP then
        turn_time = C.COMBO_NET_FACE_TIME_CAP
    end
    local speed = get_earthbind_projectile_speed(net)
    local travel_dist = vec_dist_2d(caster_pos, cast_pos) or 0
    local arrival_time = now + turn_time + cast_point + (travel_dist / math.max(1, speed))
    script._combo_net_pending_target_key = get_entity_key(target)
    script._combo_net_pending_arrival_time = arrival_time
    script._combo_net_pending_end_time = arrival_time + script.get_earthbind_root_duration(net)
    combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_NET_CAST_LOCK)
    set_combo_action_lock(now, C.COMBO_NET_CAST_LOCK)
    return true
end
function script.is_combo_option_enabled(option)
    if option and option.Get then
        local ok, value = pcall(function()
            return option:Get()
        end)
        if ok then
            return value == true
        end
    end
    return false
end
function script.get_combo_hold_window_sec()
    if ui.combo_hold_disable_ms and ui.combo_hold_disable_ms.Get then
        local ok, value = pcall(function()
            return ui.combo_hold_disable_ms:Get()
        end)
        if ok and value ~= nil then
            local ms = tonumber(value) or 450
            if ms < 100 then
                ms = 100
            end
            return ms / 1000.0
        end
    end
    return 0.45
end
function script.process_blink_queue(now)
    if (script._combo_blink_scheduled_time or 0) > 0 then
        script.clear_blink_schedule()
    end
end
function script.collect_utility_poof_units(local_player, local_hero, meepos)
    local mode = get_combo_type_index()
    if mode == COMBO_MODE_ALL then
        return collect_owned_meepo_units(local_hero, meepos)
    end
    return collect_combo_move_units(local_player, local_hero, meepos)
end
function script.collect_ready_poof_casters(units, now)
    local ready = {}
    local ability = nil
    if not units or #units == 0 then
        return ready, ability
    end
    for i = 1, #units do
        local meepo = units[i]
        local can_cast, poof = can_schedule_poof(meepo, now)
        if can_cast and poof then
            ready[#ready + 1] = meepo
            if not ability then
                ability = poof
            end
        end
    end
    return ready, ability
end
function script.issue_group_poof_target_order(local_player, casters, anchor, now, reason)
    if not casters or #casters == 0 or not anchor or not Entity.IsAlive(anchor) then
        return false
    end
    local ready_casters = script.collect_ready_poof_casters(casters, now)
    if #ready_casters == 0 then
        return false
    end
    local casted = 0
    local failed = {}
    for i = 1, #ready_casters do
        local meepo = ready_casters[i]
        if meepo and Entity.IsAlive(meepo) then
            local can_cast, poof = can_schedule_poof(meepo, now)
            if can_cast and poof then
                local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
                local channelling = safe_call(Ability.IsChannelling, poof)
                if in_phase ~= true and channelling ~= true then
                    local ok = pcall(function()
                        Ability.CastTarget(
                            poof,
                            anchor,
                            false,
                            true,
                            true,
                            reason or "meepo_poof_group_target"
                        )
                    end)
                    if ok then
                        local key = get_entity_key(meepo)
                        combo_poof_last_cast_by_meepo[key] = now
                        casted = casted + 1
                    else
                        failed[#failed + 1] = meepo
                    end
                else
                    failed[#failed + 1] = meepo
                end
            else
                failed[#failed + 1] = meepo
            end
        else
            failed[#failed + 1] = meepo
        end
    end
    local queued = 0
    if #failed > 0 then
        queued = schedule_poof_burst(failed, anchor, now + 0.02, reason or "meepo_poof_group_target", 0)
    end
    if casted <= 0 and queued <= 0 then
        script._dbg("poof_util", "cursor direct cast failed (queued 0)")
        return false
    end
    script._dbg("poof_util", string.format("cursor direct casted %d queued %d", casted, queued))
    script._poof_next_order_time = now + 0.05
    return true
end
function script.issue_group_poof_self_order(local_player, casters, now, reason)
    if not casters or #casters == 0 then
        return false
    end
    local ready_casters = script.collect_ready_poof_casters(casters, now)
    if #ready_casters == 0 then
        return false
    end
    local casted = 0
    local failed = {}
    for i = 1, #ready_casters do
        local meepo = ready_casters[i]
        if meepo and Entity.IsAlive(meepo) then
            local can_cast, poof = can_schedule_poof(meepo, now)
            if can_cast and poof then
                local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
                local channelling = safe_call(Ability.IsChannelling, poof)
                if in_phase ~= true and channelling ~= true then
                    local ok = pcall(function()
                        Ability.CastTarget(
                            poof,
                            meepo,
                            false,
                            true,
                            true,
                            reason or "meepo_poof_group_self"
                        )
                    end)
                    if ok then
                        local key = get_entity_key(meepo)
                        combo_poof_last_cast_by_meepo[key] = now
                        casted = casted + 1
                    else
                        failed[#failed + 1] = meepo
                    end
                else
                    failed[#failed + 1] = meepo
                end
            else
                failed[#failed + 1] = meepo
            end
        else
            failed[#failed + 1] = meepo
        end
    end
    local queued = 0
    if #failed > 0 then
        queued = script.schedule_poof_self(failed, now + 0.02, reason or "meepo_poof_group_self")
    end
    if casted <= 0 and queued <= 0 then
        script._dbg("poof_util", "self direct cast failed (queued 0)")
        return false
    end
    script._dbg("poof_util", string.format("self direct casted %d queued %d", casted, queued))
    script._poof_next_order_time = now + 0.05
    return true
end
function script.try_poof_to_cursor(local_player, local_hero, meepos, now)
    local units = script.collect_utility_poof_units(local_player, local_hero, meepos)
    if #units == 0 then
        return false
    end
    local cursor_pos = script.get_world_cursor_position()
    if not cursor_pos then
        return false
    end
    local anchor = select(1, choose_poof_anchor(units, cursor_pos, nil))
    if not anchor then
        return false
    end
    local filtered = {}
    for i = 1, #units do
        local meepo = units[i]
        if meepo and meepo ~= anchor then
            filtered[#filtered + 1] = meepo
        end
    end
    if #filtered == 0 then
        return false
    end
    if script.issue_group_poof_target_order(local_player, filtered, anchor, now, "meepo_poof_cursor_group") then
        return true
    end
    script._dbg("poof_util", "cursor fallback queue")
    return schedule_poof_burst(filtered, anchor, now, "meepo_poof_cursor", 0) > 0
end
function script.try_poof_on_self(local_player, local_hero, meepos, now)
    local units = script.collect_utility_poof_units(local_player, local_hero, meepos)
    if #units == 0 then
        return false
    end
    if script.issue_group_poof_self_order(local_player, units, now, "meepo_poof_self_group") then
        return true
    end
    script._dbg("poof_util", "self fallback queue")
    return script.schedule_poof_self(units, now, "meepo_poof_self") > 0
end
local function is_poof_in_progress(units)
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
            if poof then
                local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
                local channelling = safe_call(Ability.IsChannelling, poof)
                if in_phase == true or channelling == true then
                    return true
                end
            end
        end
    end
    return false
end
is_combo_cast_in_progress = function(meepo)
    if not meepo or not Entity.IsAlive(meepo) then
        return false
    end
    local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
    if poof then
        local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
        local channelling = safe_call(Ability.IsChannelling, poof)
        if in_phase == true or channelling == true then
            return true
        end
    end
    local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
    if net and safe_call(Ability.IsInAbilityPhase, net) == true then
        return true
    end
    return false
end
local function interrupt_combo_casts(player, units)
    if not player or not units or #units == 0 then
        return false
    end
    local stop_order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_STOP or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    local interrupted = false
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) and is_combo_cast_in_progress(meepo) then
            local issued = false
            if stop_order and issuer_type and Player and Player.PrepareUnitOrders then
                issued = pcall(function()
                    Player.PrepareUnitOrders(
                        player,
                        stop_order,
                        nil,
                        safe_call(Entity.GetAbsOrigin, meepo),
                        nil,
                        issuer_type,
                        meepo,
                        false,
                        true,
                        true,
                        true,
                        "meepo_combo_cancel_cast",
                        false
                    )
                end)
            end
            if (not issued) and Player and Player.HoldPosition then
                issued = pcall(function()
                    Player.HoldPosition(player, meepo, false, true, true, "meepo_combo_cancel_cast_hold")
                end)
            end
            if issued then
                interrupted = true
            end
        end
    end
    return interrupted
end
local function choose_earthbind_caster(units, target, now, preferred_caster)
    local best_meepo = nil
    local best_ability = nil
    local best_arrival = nil
    local best_cast_pos = nil
    local preferred_meepo = nil
    local preferred_ability = nil
    local preferred_arrival = nil
    local preferred_cast_pos = nil
    local preferred_key = nil
    if preferred_caster and Entity.IsAlive(preferred_caster) then
        preferred_key = get_entity_key(preferred_caster)
    end
    if not target or not Entity.IsAlive(target) then
        return nil, nil, nil, nil
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return nil, nil, nil, nil
    end
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
            if net and can_cast_ability_for_npc(meepo, net) then
                local meepo_key = get_entity_key(meepo)
                local last_cast = combo_net_last_cast_by_meepo[meepo_key] or -9999
                if now - last_cast >= C.COMBO_NET_CASTER_RECAST_DELAY then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local cast_pos = script.get_simple_net_position(meepo, target, net, now) or target_pos
                    local dist = vec_dist_2d(meepo_pos, cast_pos)
                    if dist then
                        local cast_range = get_net_cast_range(meepo, net)
                        if dist > cast_range + C.COMBO_NET_RANGE_PADDING then
                            cast_pos = target_pos
                            dist = vec_dist_2d(meepo_pos, cast_pos)
                        end
                        if dist and dist <= cast_range + C.COMBO_NET_RANGE_PADDING then
                            local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
                            if cast_point < 0 then
                                cast_point = 0
                            end
                            local turn_time = tonumber(safe_call(NPC.GetTimeToFacePosition, meepo, cast_pos) or 0) or 0
                            if turn_time < 0 then
                                turn_time = 0
                            elseif turn_time > C.COMBO_NET_FACE_TIME_CAP then
                                turn_time = C.COMBO_NET_FACE_TIME_CAP
                            end
                            local speed = get_earthbind_projectile_speed(net)
                            local time_to_land = turn_time + cast_point + (dist / math.max(1, speed))
                            local arrival = now + time_to_land
                            local meepo_key_now = get_entity_key(meepo)
                            if preferred_key and meepo_key_now == preferred_key then
                                if not preferred_arrival or arrival < preferred_arrival then
                                    preferred_arrival = arrival
                                    preferred_meepo = meepo
                                    preferred_ability = net
                                    preferred_cast_pos = cast_pos
                                end
                            elseif not best_arrival or arrival < best_arrival then
                                best_arrival = arrival
                                best_meepo = meepo
                                best_ability = net
                                best_cast_pos = cast_pos
                            end
                        end
                    end
                end
            end
        end
    end
    if preferred_meepo and preferred_ability and preferred_arrival then
        return preferred_meepo, preferred_ability, preferred_arrival, preferred_cast_pos
    end
    return best_meepo, best_ability, best_arrival, best_cast_pos
end
local function get_hex_item(npc)
    if not npc or not NPC.GetItem then
        return nil
    end
    local hex = safe_call(NPC.GetItem, npc, C.ITEM_HEX, true)
    if not hex then
        return nil
    end
    local name = safe_call(Ability.GetName, hex)
    if name and name ~= "" and not is_item_enabled(name) then
        return nil
    end
    return hex
end
local function can_cast_hex_now(npc, hex)
    if not npc or not hex then
        return false
    end
    if not can_cast_ability_for_npc(npc, hex) then
        return false
    end
    local in_phase = safe_call(Ability.IsInAbilityPhase, hex)
    if in_phase == true then
        return false
    end
    return true
end
local function get_hex_cast_range(caster, hex)
    return script.get_item_cast_range_for_npc(caster, hex, C.COMBO_HEX_RANGE_FALLBACK)
end
script.can_cast_combo_hex_now = function(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if script.get_control_break_reason(target, true) then
        return false
    end
    if not units or #units == 0 then
        return false
    end
    local has_enabled_abyssal = false
    local has_enabled_atos = false
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            if (not has_enabled_abyssal) and script.get_enabled_item_by_names(meepo, script._combo_item_sets.abyssal) then
                has_enabled_abyssal = true
            end
            if (not has_enabled_atos) and script.get_enabled_item_by_names(meepo, script._combo_item_sets.atos) then
                has_enabled_atos = true
            end
            if has_enabled_abyssal and has_enabled_atos then
                break
            end
        end
    end
    local abyssal_remaining = has_enabled_abyssal and script.get_target_abyssal_remaining(target, now) or 0
    local atos_remaining = has_enabled_atos and script.get_target_atos_remaining(target, now) or 0
    if has_enabled_atos and atos_remaining > 0.10 then
        return false
    end
    local hex_remaining = script.get_target_hex_remaining(target, now)
    if hex_remaining > 0.20 then
        return false
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local hex = get_hex_item(meepo)
            if hex and can_cast_hex_now(meepo, hex) then
                local meepo_key = get_entity_key(meepo)
                local last_frame = script._combo_hex_last_frame_by_meepo[meepo_key] or -1
                if attempt_frame < 0 or (attempt_frame - last_frame) > C.COMBO_ITEM_FRAME_GAP then
                    local cast_point = tonumber(safe_call(Ability.GetCastPoint, hex, true) or 0) or 0
                    if cast_point < 0 then
                        cast_point = 0
                    end
                    local abyssal_gate = cast_point + C.COMBO_POOF_SAFE_ROOT_BUFFER
                    if abyssal_gate < C.COMBO_HEX_CHAIN_FROM_ABYSSAL_WINDOW then
                        abyssal_gate = C.COMBO_HEX_CHAIN_FROM_ABYSSAL_WINDOW
                    end
                    if (not has_enabled_abyssal) or abyssal_remaining <= abyssal_gate then
                        local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                        local dist = vec_dist_2d(meepo_pos, target_pos)
                        if dist then
                            local cast_range = get_hex_cast_range(meepo, hex)
                            if dist <= cast_range + C.COMBO_HEX_RANGE_PADDING then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end
local function try_combo_hex(units, target, now)
    local break_reason = script.get_control_break_reason(target, true)
    if break_reason then
        return false
    end
    if not script.can_cast_combo_hex_now(units, target, now) then
        return false
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if attempt_frame >= 0 then
        local gap = attempt_frame - script._combo_hex_last_attempt_frame
        if gap <= C.COMBO_ITEM_FRAME_GAP then
            return false
        end
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local best_meepo = nil
    local best_hex = nil
    local best_dist = nil
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local hex = get_hex_item(meepo)
            if hex and can_cast_hex_now(meepo, hex) then
                local meepo_key = get_entity_key(meepo)
                local last_frame = script._combo_hex_last_frame_by_meepo[meepo_key] or -1
                if attempt_frame < 0 or (attempt_frame - last_frame) > C.COMBO_ITEM_FRAME_GAP then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local dist = vec_dist_2d(meepo_pos, target_pos)
                    if dist then
                        local cast_range = get_hex_cast_range(meepo, hex)
                        if dist <= cast_range + C.COMBO_HEX_RANGE_PADDING then
                            if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                best_dist = dist
                                best_meepo = meepo
                                best_hex = hex
                            end
                        end
                    end
                end
            end
        end
    end
    if best_meepo and best_hex then
        local caster_key = get_entity_key(best_meepo)
        if attempt_frame >= 0 then
            script._combo_hex_last_frame_by_meepo[caster_key] = attempt_frame
        end
        script._combo_hex_last_attempt_global = now
        script._combo_hex_last_attempt_frame = attempt_frame
        local cast_ok = cast_target_item_budgeted(best_meepo, best_hex, target, "meepo_combo_hex")
        if cast_ok then
            combo_hex_last_cast = now
            combo_hex_last_cast_by_meepo[caster_key] = now
            return true
        end
    end
    return false
end
function script.try_combo_linken_break(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, "invalid_target"
    end
    if not script.is_target_linkens_protected(target) then
        return false, nil
    end
    if not units or #units == 0 then
        return false, "no_units"
    end
    if script.is_combo_option_enabled(ui.combo_control_break_checks)
        and safe_call(NPC.HasModifier, target, "modifier_item_lotus_orb_active") == true then
        return false, "lotus"
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false, "no_position"
    end
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local best_priority = 9999
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
            local dist = vec_dist_2d(meepo_pos, target_pos)
            if dist then
                for j = 1, #CFG.linken_break_items do
                    local item_name = CFG.linken_break_items[j]
                    if script.is_linken_breaker_item_enabled(item_name) then
                        local item = safe_call(NPC.GetItem, meepo, item_name, true)
                        if item and script.can_cast_target_item_now(meepo, item) then
                            local cast_range = script.get_item_cast_range_for_npc(meepo, item, 900)
                            if dist <= cast_range + 50 then
                                local should_take = false
                                if not best_item or j < best_priority then
                                    should_take = true
                                elseif j == best_priority and script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                    should_take = true
                                end
                                if should_take then
                                    best_priority = j
                                    best_dist = dist
                                    best_meepo = meepo
                                    best_item = item
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false, "no_enabled_breaker"
    end
    local best_name = safe_call(Ability.GetName, best_item) or ""
    if best_name ~= "" and not script.is_linken_breaker_item_enabled(best_name) then
        return false, "disabled_breaker"
    end
    local cast_ok = cast_target_item_budgeted(best_meepo, best_item, target, "meepo_combo_break_linken", target_pos)
    if not cast_ok then
        return false, "cast_failed"
    end
    combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_ACTION_MIN_INTERVAL)
    set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
    return true, safe_call(Ability.GetName, best_item) or "item"
end
function script.try_combo_silence(units, target, now)
    local break_reason = script.get_control_break_reason(target, true)
    if break_reason then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if not units or #units == 0 then
        return false
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if attempt_frame >= 0 then
        local gap = attempt_frame - script._combo_silence_last_attempt_frame
        if gap <= C.COMBO_ITEM_FRAME_GAP then
            return false
        end
    end
    if script.get_target_silence_remaining(target, now) > 0.25 then
        return false
    end
    if script.get_target_atos_remaining(target, now) > 0.10 then
        return false
    end
    if script.get_target_hex_remaining(target, now) > 0.20 then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    script._combo_silence_last_by_meepo = script._combo_silence_last_by_meepo or {}
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local meepo_key = get_entity_key(meepo)
            local last_frame = script._combo_silence_last_frame_by_meepo[meepo_key] or -1
            if attempt_frame < 0 or (attempt_frame - last_frame) > C.COMBO_ITEM_FRAME_GAP then
                local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                local dist = vec_dist_2d(meepo_pos, target_pos)
                if dist then
                    for j = 1, #script._combo_item_sets.silence do
                        local item_name = script._combo_item_sets.silence[j]
                        if item_name and is_item_enabled(item_name) then
                            local silence_item = safe_call(NPC.GetItem, meepo, item_name, true)
                            if silence_item and script.can_cast_target_item_now(meepo, silence_item) then
                                local cast_range = script.get_item_cast_range_for_npc(meepo, silence_item, 900)
                                if dist <= cast_range + 50 then
                                    if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                        best_dist = dist
                                        best_meepo = meepo
                                        best_item = silence_item
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false
    end
    local caster_key = get_entity_key(best_meepo)
    if attempt_frame >= 0 then
        script._combo_silence_last_frame_by_meepo[caster_key] = attempt_frame
    end
    script._combo_silence_last_attempt_global = now
    script._combo_silence_last_attempt_frame = attempt_frame
    local cast_ok = cast_target_item_budgeted(best_meepo, best_item, target, "meepo_combo_silence")
    if cast_ok then
        script._combo_silence_last_global = now
        script._combo_silence_last_by_meepo[caster_key] = now
        return true
    end
    return false
end
function script.try_combo_atos(units, target, now)
    local break_reason = script.get_control_break_reason(target, true)
    if break_reason then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if not units or #units == 0 then
        return false
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if attempt_frame >= 0 then
        local gap = attempt_frame - script._combo_atos_last_attempt_frame
        if gap <= C.COMBO_ITEM_FRAME_GAP then
            return false
        end
    end
    if script.get_target_abyssal_remaining(target, now) > 0.35 then
        return false
    end
    if script.get_target_hex_remaining(target, now) > 0.35 then
        return false
    end
    if script.get_target_atos_remaining(target, now) > 0.25 then
        return false
    end
    if get_effective_earthbind_remaining(target, now) > 0.65 then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    script._combo_atos_last_by_meepo = script._combo_atos_last_by_meepo or {}
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local meepo_key = get_entity_key(meepo)
            local last_frame = script._combo_atos_last_frame_by_meepo[meepo_key] or -1
            if attempt_frame < 0 or (attempt_frame - last_frame) > C.COMBO_ITEM_FRAME_GAP then
                local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                local dist = vec_dist_2d(meepo_pos, target_pos)
                if dist then
                    for j = 1, #script._combo_item_sets.atos do
                        local item_name = script._combo_item_sets.atos[j]
                        if item_name and is_item_enabled(item_name) then
                            local root_item = safe_call(NPC.GetItem, meepo, item_name, true)
                            if root_item and script.can_cast_target_item_now(meepo, root_item) then
                                local cast_range = script.get_item_cast_range_for_npc(meepo, root_item, 1100)
                                if dist <= cast_range + 50 then
                                    if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                        best_dist = dist
                                        best_meepo = meepo
                                        best_item = root_item
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false
    end
    local caster_key = get_entity_key(best_meepo)
    if attempt_frame >= 0 then
        script._combo_atos_last_frame_by_meepo[caster_key] = attempt_frame
    end
    script._combo_atos_last_attempt_global = now
    script._combo_atos_last_attempt_frame = attempt_frame
    local cast_ok = cast_target_item_budgeted(best_meepo, best_item, target, "meepo_combo_atos", target_pos)
    if cast_ok then
        script._combo_atos_last_global = now
        script._combo_atos_last_by_meepo[caster_key] = now
        local cast_point = tonumber(safe_call(Ability.GetCastPoint, best_item, true) or 0) or 0
        if cast_point < 0 then
            cast_point = 0
        end
        local item_name = safe_call(Ability.GetName, best_item) or ""
        local projectile_speed = script.get_item_special_value(best_item, "projectile_speed", "speed", 0)
        local duration = script.get_item_special_value(best_item, "duration", "ensnare_duration", 2.0)
        local travel = 0
        if item_name == "item_gleipnir" then
            travel = script.get_item_special_value(best_item, "activation_delay", "delay", 0.30)
            if travel < 0 then
                travel = 0
            end
        elseif projectile_speed > 0 then
            travel = (best_dist or 0) / math.max(1, projectile_speed)
        end
        local arrival = now + cast_point + travel
        script._combo_atos_pending_target_key = get_entity_key(target)
        script._combo_atos_pending_end_time = arrival + duration
        combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true
    end
    return false
end
function script.try_combo_item_on_target(units, target, item_names, tag, fallback_range, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if not units or #units == 0 or not item_names then
        return false, nil
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false, nil
    end
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    local target_linkens = script.is_target_linkens_protected(target)
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
            local dist = vec_dist_2d(meepo_pos, target_pos)
            if dist then
                for j = 1, #item_names do
                    local item_name = item_names[j]
                    if item_name and item_name ~= "" and is_item_enabled(item_name) then
                        local can_use_item = true
                        if target_linkens and not script.is_linken_breaker_item_enabled(item_name) then
                            can_use_item = false
                        end
                        if can_use_item then
                            local item = safe_call(NPC.GetItem, meepo, item_name, true)
                            if item and script.can_cast_target_item_now(meepo, item) then
                                local cast_range = script.get_item_cast_range_for_npc(meepo, item, fallback_range or 800)
                                if dist <= cast_range + 50 then
                                    if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                        best_meepo = meepo
                                        best_item = item
                                        best_dist = dist
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false, nil
    end
    local cast_ok = cast_target_item_budgeted(best_meepo, best_item, target, tag, target_pos)
    if cast_ok then
        combo_move_next_order_time = math.max(combo_move_next_order_time, (now or get_game_time()) + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true, safe_call(Ability.GetName, best_item) or ""
    end
    return false, nil
end
function script.is_meepo_windwalked(meepo)
    if not meepo then
        return false
    end
    if safe_call(NPC.HasModifier, meepo, "modifier_item_silver_edge_windwalk") == true then
        return true
    end
    if safe_call(NPC.HasModifier, meepo, "modifier_item_invisibility_edge_windwalk") == true then
        return true
    end
    if safe_call(NPC.HasModifier, meepo, "modifier_item_shadow_amulet_fade") == true then
        return true
    end
    return script.has_modifier_state(meepo, "MODIFIER_STATE_INVISIBLE")
end
function script.try_combo_item_no_target(units, item_names, tag, now, target, max_distance, require_not_windwalked)
    if not units or #units == 0 or not item_names then
        return false, nil
    end
    local target_pos = nil
    if target and Entity.IsAlive(target) then
        target_pos = safe_call(Entity.GetAbsOrigin, target)
    end
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            if not require_not_windwalked or not script.is_meepo_windwalked(meepo) then
                local dist = 0
                if target_pos then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    dist = vec_dist_2d(meepo_pos, target_pos) or 99999
                    if max_distance and max_distance > 0 and dist > max_distance then
                        dist = nil
                    end
                end
                if dist ~= nil then
                    for j = 1, #item_names do
                        local item_name = item_names[j]
                        if item_name and item_name ~= "" and is_item_enabled(item_name) then
                            local item = safe_call(NPC.GetItem, meepo, item_name, true)
                            if item and script.cast_no_target_item_budgeted and script.can_cast_target_item_now then
                                if script.can_cast_target_item_now(meepo, item) then
                                    if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                        best_meepo = meepo
                                        best_item = item
                                        best_dist = dist
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false, nil
    end
    if script.cast_no_target_item_budgeted(best_meepo, best_item, tag) then
        combo_move_next_order_time = math.max(combo_move_next_order_time, (now or get_game_time()) + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true, safe_call(Ability.GetName, best_item) or ""
    end
    return false, nil
end
function script.try_combo_armlet_control(units, should_enable, now)
    if not units or #units == 0 then
        return false
    end
    if should_enable and not is_item_enabled("item_armlet") then
        return false
    end
    if (not should_enable) and not script._combo_armlet_forced_on then
        return false
    end
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    local best_meepo = nil
    local best_item = nil
    local best_pref = false
    local armlet_active_found = false
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local armlet = safe_call(NPC.GetItem, meepo, "item_armlet", true)
            local armlet_cast_ok = false
            if armlet then
                if should_enable then
                    armlet_cast_ok = script.can_cast_target_item_now(meepo, armlet)
                else
                    armlet_cast_ok = can_cast_ability_for_npc(meepo, armlet) and safe_call(Ability.IsInAbilityPhase, armlet) ~= true
                end
            end
            if armlet and armlet_cast_ok then
                local active = safe_call(NPC.HasModifier, meepo, "modifier_item_armlet_unholy_strength") == true
                if active then
                    armlet_active_found = true
                end
                if (should_enable and not active) or ((not should_enable) and active) then
                    local is_pref = preferred_key and get_entity_key(meepo) == preferred_key or false
                    if not best_meepo or (is_pref and not best_pref) then
                        best_meepo = meepo
                        best_item = armlet
                        best_pref = is_pref
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        if not should_enable and not armlet_active_found then
            script._combo_armlet_forced_on = false
        end
        return false
    end
    if script.cast_no_target_item_budgeted(best_meepo, best_item, should_enable and "meepo_combo_armlet_on" or "meepo_combo_armlet_off") then
        script._combo_armlet_forced_on = should_enable and true or false
        combo_move_next_order_time = math.max(combo_move_next_order_time, (now or get_game_time()) + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true
    end
    return false
end
function script.try_combo_phase_shadow_engage(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if get_effective_earthbind_remaining(target, now) > 0.12 then
        return false, nil
    end
    local casted, cast_name = script.try_combo_item_no_target(
        units,
        script._combo_item_sets.phase,
        "meepo_combo_phase",
        now,
        target,
        1400,
        false
    )
    if casted then
        return true, cast_name
    end
    return script.try_combo_item_no_target(
        units,
        script._combo_item_sets.shadow,
        "meepo_combo_shadow",
        now,
        target,
        1400,
        true
    )
end
function script.try_combo_diffusal_disperser(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if script.get_control_break_reason(target, false) then
        return false, nil
    end
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local target_key = get_entity_key(target)
    local since_global = now_time - (tonumber(script._combo_purge_last_global or -9999) or -9999)
    if since_global < (tonumber(C.COMBO_PURGE_GLOBAL_RECAST_DELAY or 0.65) or 0.65) then
        return false, nil
    end
    if target_key and script._combo_purge_last_target_key == target_key then
        if since_global < (tonumber(C.COMBO_PURGE_SAME_TARGET_RECAST_DELAY or 1.25) or 1.25) then
            return false, nil
        end
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if attempt_frame >= 0 then
        local gap = attempt_frame - (tonumber(script._combo_purge_last_attempt_frame or -1) or -1)
        if gap <= (tonumber(C.COMBO_ITEM_FRAME_GAP or 3) or 3) then
            return false, nil
        end
    end
    script._combo_purge_last_attempt_global = now_time
    script._combo_purge_last_attempt_frame = attempt_frame
    local casted, cast_name = script.try_combo_item_on_target(
        units,
        target,
        script._combo_item_sets.purge,
        "meepo_combo_purge",
        700,
        now_time
    )
    if casted then
        script._combo_purge_last_global = now_time
        script._combo_purge_last_target_key = target_key
    end
    return casted, cast_name
end
function script.try_combo_grenade(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if get_effective_earthbind_remaining(target, now) > 0.20 then
        return false, nil
    end
    return script.try_combo_item_on_target(
        units,
        target,
        script._combo_item_sets.grenade,
        "meepo_combo_grenade",
        900,
        now
    )
end
function script.try_combo_manta_after_net(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if get_effective_earthbind_remaining(target, now) <= 0.05 then
        return false, nil
    end
    return script.try_combo_item_no_target(
        units,
        script._combo_item_sets.manta,
        "meepo_combo_manta_after_net",
        now,
        target,
        650,
        false
    )
end
function script.try_combo_mjollnir_self(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if not units or #units == 0 then
        return false, nil
    end
    if not is_item_enabled("item_mjollnir") then
        return false, nil
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false, nil
    end
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            if safe_call(NPC.HasModifier, meepo, "modifier_item_mjollnir_shield") ~= true then
                local mjollnir = safe_call(NPC.GetItem, meepo, "item_mjollnir", true)
                if mjollnir and script.can_cast_target_item_now(meepo, mjollnir) then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local dist = vec_dist_2d(meepo_pos, target_pos)
                    if dist and dist <= 900 then
                        if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                            best_meepo = meepo
                            best_item = mjollnir
                            best_dist = dist
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false, nil
    end
    if cast_target_item_budgeted(best_meepo, best_item, best_meepo, "meepo_combo_mjollnir_self") then
        combo_move_next_order_time = math.max(combo_move_next_order_time, (now or get_game_time()) + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true, "item_mjollnir"
    end
    return false, nil
end
function script.try_combo_blademail_close(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    return script.try_combo_item_no_target(
        units,
        script._combo_item_sets.blademail,
        "meepo_combo_blademail",
        now,
        target,
        420,
        false
    )
end
function script.try_combo_mom_finish(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if get_effective_earthbind_remaining(target, now) > 0.05 then
        return false, nil
    end
    return script.try_combo_item_no_target(
        units,
        script._combo_item_sets.mom,
        "meepo_combo_mom_finish",
        now,
        target,
        650,
        false
    )
end
function script.try_combo_abyssal(units, target, now)
    local break_reason = script.get_control_break_reason(target, true)
    if break_reason then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if not units or #units == 0 then
        return false
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if attempt_frame >= 0 then
        local gap = attempt_frame - script._combo_abyssal_last_attempt_frame
        if gap <= C.COMBO_ITEM_FRAME_GAP then
            return false
        end
    end
    if script.get_target_abyssal_remaining(target, now) > 0.25 then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local target_key = get_entity_key(target)
    local recent_blink_until = script._combo_abyssal_recent_blink_until or 0
    if recent_blink_until > 0 and now > recent_blink_until then
        script._combo_abyssal_recent_blink_until = 0
        script._combo_abyssal_recent_blink_target_key = nil
        script._combo_abyssal_recent_blink_caster_key = nil
    end
    script._combo_abyssal_last_by_meepo = script._combo_abyssal_last_by_meepo or {}
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local best_range = 0
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local abyssal = script.get_enabled_item_by_names(meepo, script._combo_item_sets.abyssal)
            if abyssal and script.can_cast_target_item_now(meepo, abyssal) then
                local meepo_key = get_entity_key(meepo)
                local last_frame = script._combo_abyssal_last_frame_by_meepo[meepo_key] or -1
                if attempt_frame < 0 or (attempt_frame - last_frame) > C.COMBO_ITEM_FRAME_GAP then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local dist = vec_dist_2d(meepo_pos, target_pos)
                    if dist then
                        local cast_range = script.get_item_cast_range(abyssal, 600)
                        local cast_bonus = tonumber(safe_call(NPC.GetCastRangeBonus, meepo) or 0) or 0
                        if cast_bonus > 0 then
                            cast_range = cast_range + cast_bonus
                        end
                        if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                            best_dist = dist
                            best_meepo = meepo
                            best_item = abyssal
                            best_range = cast_range
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false
    end
    local cast_point = tonumber(safe_call(Ability.GetCastPoint, best_item, true) or 0) or 0
    if cast_point < 0 then
        cast_point = 0
    end
    local hex_remaining = script.get_target_hex_remaining(target, now)
    if hex_remaining > (cast_point + C.COMBO_POOF_SAFE_ROOT_BUFFER) then
        return false
    end
    local anchor = get_main_meepo(safe_call(Heroes.GetLocal))
    if (not anchor or not Entity.IsAlive(anchor)) and best_meepo and Entity.IsAlive(best_meepo) then
        anchor = best_meepo
    end
    local poof_clones = {}
    if anchor then
        for i = 1, #units do
            local meepo = units[i]
            if meepo and meepo ~= anchor and Entity.IsAlive(meepo) then
                poof_clones[#poof_clones + 1] = meepo
            end
        end
    end
    local function prepare_abyssal_poof()
        if not anchor or not Entity.IsAlive(anchor) then
            return 0
        end
        if not poof_clones or #poof_clones == 0 then
            return 0
        end
        local poof_time = now + math.max(0, cast_point)
        return schedule_poof_burst(poof_clones, anchor, poof_time, "meepo_combo_abyssal_poof", 0, target_pos)
    end
    local caster_key = get_entity_key(best_meepo)
    if (best_dist or 99999) > (best_range + 40) then
        local local_hero = safe_call(Heroes.GetLocal)
        local blinked = false
        if local_hero then
            blinked = script.try_combo_blink_sync(local_hero, units, target, now, units) == true
        end
        if blinked then
            script._combo_abyssal_recent_blink_until = now + 0.75
            script._combo_abyssal_recent_blink_target_key = target_key
            script._combo_abyssal_recent_blink_caster_key = caster_key
            return true
        end
        if (script._combo_abyssal_recent_blink_until or 0) > now
            and script._combo_abyssal_recent_blink_target_key == target_key
            and script._combo_abyssal_recent_blink_caster_key == caster_key then
            return true
        end
        return false
    end
    if attempt_frame >= 0 then
        script._combo_abyssal_last_frame_by_meepo[caster_key] = attempt_frame
    end
    script._combo_abyssal_last_attempt_global = now
    script._combo_abyssal_last_attempt_frame = attempt_frame
    local cast_ok = cast_target_item_budgeted(best_meepo, best_item, target, "meepo_combo_abyssal")
    if cast_ok then
        prepare_abyssal_poof()
        script._combo_abyssal_recent_blink_until = 0
        script._combo_abyssal_recent_blink_target_key = nil
        script._combo_abyssal_recent_blink_caster_key = nil
        script._combo_abyssal_last_global = now
        script._combo_abyssal_last_by_meepo[caster_key] = now
        local duration = script.get_item_special_value(best_item, "stun_duration", "duration", 0)
        local alt_duration = script.get_item_special_value(best_item, "bash_duration", "active_duration", 0)
        if alt_duration > duration then
            duration = alt_duration
        end
        if duration <= 0 then
            duration = 1.6
        end
        script._combo_abyssal_pending_target_key = target_key
        script._combo_abyssal_pending_end_time = now + cast_point + duration
        combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true
    end
    return false
end
function script.has_ready_abyssal_for_combo(units, target, now)
    local break_reason = script.get_control_break_reason(target, true)
    if break_reason then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if not units or #units == 0 then
        return false
    end
    if script.get_target_abyssal_remaining(target, now) > 0.25 then
        return false
    end
    script._combo_abyssal_last_by_meepo = script._combo_abyssal_last_by_meepo or {}
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local abyssal = script.get_enabled_item_by_names(meepo, script._combo_item_sets.abyssal)
            if abyssal and script.can_cast_target_item_now(meepo, abyssal) then
                local meepo_key = get_entity_key(meepo)
                local last_cast = script._combo_abyssal_last_by_meepo[meepo_key] or -9999
                if now - last_cast >= 0.22 then
                    return true
                end
            end
        end
    end
    return false
end
local function has_combo_item_equipped(units, item_names)
    if not units or #units == 0 or not item_names then
        return false
    end
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local item = script.get_enabled_item_by_names(meepo, item_names)
            if item then
                return true
            end
        end
    end
    return false
end
local function has_any_combo_items_equipped(local_hero, units)
    if has_combo_item_equipped(units, script._combo_item_sets.purge) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.silence) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.atos) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.abyssal) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.grenade) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.phase) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.shadow) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.mjollnir) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.mom) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.armlet) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.manta) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.blademail) then
        return true
    end
    if units and #units > 0 then
        for i = 1, #units do
            local meepo = units[i]
            if meepo and Entity.IsAlive(meepo) then
                local hex = get_hex_item(meepo)
                if hex then
                    return true
                end
            end
        end
    end
    local main = get_main_meepo(local_hero)
    if main and Entity.IsAlive(main) then
        local blink = get_blink_item(main)
        if blink then
            return true
        end
    end
    return false
end
local function has_ready_hex_for_combo(units)
    if not units or #units == 0 then
        return false
    end
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local hex = get_hex_item(meepo)
            if hex and can_cast_hex_now(meepo, hex) then
                return true
            end
        end
    end
    return false
end
local function is_meepo_net_ready_for_combo(meepo, now)
    if not meepo or not Entity.IsAlive(meepo) then
        return false
    end
    local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
    if not net or not can_cast_ability_for_npc(meepo, net) then
        return false
    end
    if safe_call(Ability.IsInAbilityPhase, net) == true then
        return false
    end
    local meepo_key = get_entity_key(meepo)
    local last_cast = combo_net_last_cast_by_meepo[meepo_key] or -9999
    if now - last_cast < C.COMBO_NET_CASTER_RECAST_DELAY then
        return false
    end
    return true
end
local function has_any_meepo_net_ready_for_combo(units, now)
    if not units or #units == 0 then
        return false
    end
    for i = 1, #units do
        local meepo = units[i]
        if is_meepo_net_ready_for_combo(meepo, now) then
            return true
        end
    end
    return false
end
function script.get_target_teleport_remaining(target, now)
    if not target or not Entity.IsAlive(target) then
        return 0
    end
    local best_remaining = 0
    local had_teleport_modifier = false
    local candidates = script._tp_teleport_modifier_candidates or {}
    for i = 1, #candidates do
        local mod_name = candidates[i]
        local has_mod = safe_call(NPC.HasModifier, target, mod_name) == true
        local mod = safe_call(NPC.GetModifier, target, mod_name)
        if has_mod or mod then
            had_teleport_modifier = true
            if mod then
                local remaining = get_modifier_remaining_time(mod, now)
                if remaining > best_remaining then
                    best_remaining = remaining
                end
            elseif best_remaining <= 0 then
                best_remaining = 0.20
            end
        end
    end
    if NPC.GetModifiers and Modifier and Modifier.GetName then
        local mods = safe_call(NPC.GetModifiers, target)
        if mods then
            for i = 1, #mods do
                local mod = mods[i]
                local mod_name = safe_call(Modifier.GetName, mod)
                if mod_name then
                    local lower_name = string.lower(mod_name)
                    if string.find(lower_name, "teleport", 1, true) then
                        had_teleport_modifier = true
                        local remaining = get_modifier_remaining_time(mod, now)
                        if remaining > best_remaining then
                            best_remaining = remaining
                        end
                    end
                end
            end
        end
    end
    if had_teleport_modifier and best_remaining <= 0 then
        return 0.01
    end
    return best_remaining
end
function script.try_net_on_teleport(local_hero, meepos, now)
    if not script.is_combo_option_enabled(ui.net_on_tp) then
        return false
    end
    if not local_hero or not Entity.IsAlive(local_hero) then
        return false
    end
    local units = collect_owned_meepo_units(local_hero, meepos)
    if not units or #units == 0 then
        return false
    end
    local allow_fog = script.is_combo_option_enabled(ui.net_on_tp_fog)
    local local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    local best_target = nil
    local best_caster = nil
    local best_net = nil
    local best_cast_pos = nil
    local best_arrival = nil
    local best_margin = nil
    local best_can_catch = false
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
            if net and can_cast_ability_for_npc(meepo, net) and safe_call(Ability.IsInAbilityPhase, net) ~= true then
                local meepo_key = get_entity_key(meepo)
                local last_cast = combo_net_last_cast_by_meepo[meepo_key] or -9999
                if now - last_cast >= C.COMBO_NET_CASTER_RECAST_DELAY and now - combo_net_last_global_cast >= C.COMBO_NET_GLOBAL_RECAST_DELAY then
                    local cast_range = get_net_cast_range(meepo, net) + C.COMBO_NET_RANGE_PADDING
                    local enemies = nil
                    if allow_fog then
                        enemies = safe_call(Heroes.GetAll)
                    else
                        enemies = Entity.GetHeroesInRadius(
                            meepo,
                            cast_range + 80,
                            Enum.TeamType.TEAM_ENEMY,
                            true,
                            true
                        )
                    end
                    if enemies then
                        for j = 1, #enemies do
                            local enemy = enemies[j]
                            if enemy and Entity.IsAlive(enemy) and not safe_call(NPC.IsIllusion, enemy) then
                                local enemy_team = tonumber(safe_call(Entity.GetTeamNum, enemy) or -2) or -2
                                local enemy_valid = (local_team < 0 or enemy_team ~= local_team)
                                    and (allow_fog or safe_call(NPC.IsVisible, enemy) == true)
                                if enemy_valid then
                                    local tp_remaining = script.get_target_teleport_remaining(enemy, now)
                                    if tp_remaining > 0 then
                                        local enemy_pos = safe_call(Entity.GetAbsOrigin, enemy)
                                        local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                                        local cast_pos = script.get_simple_net_position(meepo, enemy, net, now) or enemy_pos
                                        local dist = vec_dist_2d(meepo_pos, cast_pos)
                                        if enemy_pos and meepo_pos and dist and dist <= cast_range then
                                            local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
                                            if cast_point < 0 then
                                                cast_point = 0
                                            end
                                            local turn_time = tonumber(safe_call(NPC.GetTimeToFacePosition, meepo, cast_pos) or 0) or 0
                                            if turn_time < 0 then
                                                turn_time = 0
                                            elseif turn_time > C.COMBO_NET_FACE_TIME_CAP then
                                                turn_time = C.COMBO_NET_FACE_TIME_CAP
                                            end
                                            local speed = get_earthbind_projectile_speed(net)
                                            local travel = dist / math.max(1, speed)
                                            local time_to_land = turn_time + cast_point + travel
                                            local arrival = now + time_to_land
                                            local margin = tp_remaining - time_to_land
                                            local can_catch = margin >= -0.05
                                            local take = false
                                            if not best_target then
                                                take = true
                                            elseif can_catch and not best_can_catch then
                                                take = true
                                            elseif can_catch == best_can_catch then
                                                if can_catch then
                                                    if not best_arrival or arrival < best_arrival then
                                                        take = true
                                                    end
                                                elseif not best_margin or margin > best_margin then
                                                    take = true
                                                end
                                            end
                                            if take then
                                                best_target = enemy
                                                best_caster = meepo
                                                best_net = net
                                                best_cast_pos = cast_pos
                                                best_arrival = arrival
                                                best_margin = margin
                                                best_can_catch = can_catch
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_target or not best_caster or not best_net or not best_cast_pos then
        return false
    end
    local best_target_key = get_entity_key(best_target)
    if best_target_key then
        if script._combo_net_pending_target_key == best_target_key and (script._combo_net_pending_end_time or 0) > now then
            return false
        end
        local last_tp_key = script._tp_interrupt_last_target_key
        local last_tp_time = script._tp_interrupt_last_time or -9999
        if last_tp_key == best_target_key and (now - last_tp_time) < 1.20 then
            return false
        end
    end
    local ok = pcall(function()
        Ability.CastPosition(
            best_net,
            best_cast_pos,
            false,
            true,
            true,
            "meepo_tp_interrupt_net",
            false
        )
    end)
    if not ok then
        return false
    end
    local caster_key = get_entity_key(best_caster)
    combo_net_last_cast_by_meepo[caster_key] = now
    combo_net_last_global_cast = now
    script._tp_interrupt_last_target_key = best_target_key
    script._tp_interrupt_last_time = now
    script._last_net_cast_pos = best_cast_pos
    script._last_net_cast_time = now
    if best_arrival then
        script._combo_net_pending_target_key = best_target_key
        script._combo_net_pending_end_time = best_arrival + script.get_earthbind_root_duration(best_net)
    end
    combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_NET_CAST_LOCK)
    set_combo_action_lock(now, C.COMBO_NET_CAST_LOCK)
    return true
end
function script.get_disable_ready_delay_for(meepo, ability)
    if not meepo or not ability then
        return nil
    end
    if can_cast_ability_for_npc(meepo, ability) and safe_call(Ability.IsInAbilityPhase, ability) ~= true then
        return 0
    end
    local cd = tonumber(safe_call(Ability.GetCooldown, ability) or 0) or 0
    if cd > 0 then
        return cd
    end
    local mana = tonumber(safe_call(NPC.GetMana, meepo) or 0) or 0
    local mana_cost = tonumber(safe_call(Ability.GetManaCost, ability) or 0) or 0
    if mana < mana_cost then
        return 1.20
    end
    return 0.20
end
function script.get_next_disable_ready_delay(local_hero, units, now)
    if not units or #units == 0 then
        return nil, nil
    end
    local preferred_key = script.get_combo_main_priority_key(local_hero)
    local best_delay = nil
    local best_source = nil
    local best_is_preferred = false
    local function consider_candidate(meepo, delay, source)
        if delay == nil then
            return
        end
        local is_preferred = preferred_key and get_entity_key(meepo) == preferred_key or false
        if best_delay == nil
            or delay < best_delay
            or (delay == best_delay and is_preferred and not best_is_preferred) then
            best_delay = delay
            best_source = source
            best_is_preferred = is_preferred
        end
    end
    local net_enabled = is_combo_spell_enabled("net", ui.combo_use_net)
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            if net_enabled then
                local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
                consider_candidate(meepo, script.get_disable_ready_delay_for(meepo, net), "net")
            end
            local hex = get_hex_item(meepo)
            consider_candidate(meepo, script.get_disable_ready_delay_for(meepo, hex), "hex")
            local abyssal = script.get_enabled_item_by_names(meepo, script._combo_item_sets.abyssal)
            consider_candidate(meepo, script.get_disable_ready_delay_for(meepo, abyssal), "abyssal")
        end
    end
    return best_delay, best_source
end
function script.get_next_net_ready_delay(units, now)
    if not units or #units == 0 then
        return nil
    end
    local best_delay = nil
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
            if net then
                local meepo_key = get_entity_key(meepo)
                local last_cast = combo_net_last_cast_by_meepo[meepo_key] or -9999
                local recast_left = C.COMBO_NET_CASTER_RECAST_DELAY - (now - last_cast)
                if recast_left < 0 then
                    recast_left = 0
                end
                local delay = nil
                if can_cast_ability_for_npc(meepo, net) and safe_call(Ability.IsInAbilityPhase, net) ~= true then
                    delay = recast_left
                else
                    local cd = tonumber(safe_call(Ability.GetCooldown, net) or 0) or 0
                    if cd > 0 then
                        delay = math.max(cd, recast_left)
                    else
                        local mana = tonumber(safe_call(NPC.GetMana, meepo) or 0) or 0
                        local mana_cost = tonumber(safe_call(Ability.GetManaCost, net) or 0) or 0
                        if mana < mana_cost then
                            delay = 1.20
                        else
                            delay = math.max(0.20, recast_left)
                        end
                    end
                end
                if delay ~= nil and (best_delay == nil or delay < best_delay) then
                    best_delay = delay
                end
            end
        end
    end
    return best_delay
end
script.can_cast_net_chain_now = function(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if script.get_control_break_reason(target, false) then
        return false
    end
    local remaining_root = get_effective_earthbind_remaining(target, now)
    local _, _, arrival = choose_earthbind_caster(units, target, now)
    if not arrival then
        return false
    end
    local time_to_land = math.max(0, arrival - now)
    local abyssal_remaining = script.get_target_abyssal_remaining(target, now)
    if abyssal_remaining > (time_to_land + C.COMBO_NET_CHAIN_BUFFER) then
        return false
    end
    if remaining_root > 0 then
        local handoff_window = time_to_land + C.COMBO_NET_CHAIN_BUFFER + C.COMBO_NET_HANDOFF_EXTRA
        if remaining_root > handoff_window then
            return false
        end
    end
    return true
end
local function can_cast_poof_burst_now(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    local root_remaining = get_confirmed_control_remaining(target, now)
    if root_remaining < C.COMBO_POOF_ROOT_MIN_REMAINING then
        return false
    end
    local ready_count, max_radius, max_channel = get_ready_poof_burst_info(units, now)
    if ready_count <= 0 then
        return false
    end
    local required_root = get_required_root_for_poof(ready_count, max_channel)
    if root_remaining < required_root then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local allowed_anchor_dist = get_allowed_poof_anchor_distance(max_radius)
    local anchor = select(1, choose_poof_anchor(units, target_pos, allowed_anchor_dist))
    return anchor ~= nil
end
local function can_cast_poof_burst_uncontrolled_now(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    local ready_count, max_radius = get_ready_poof_burst_info(units, now)
    if ready_count <= 0 then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local allowed_anchor_dist = get_allowed_poof_anchor_distance(max_radius)
    local anchor = select(1, choose_poof_anchor(units, target_pos, allowed_anchor_dist))
    return anchor ~= nil
end
local function schedule_follow_poof_after_net(units, net_caster, target, now, arrival_time)
    if not is_combo_spell_enabled("poof", ui.combo_use_poof) then
        return 0, 0
    end
    if not units or #units == 0 or not net_caster or not Entity.IsAlive(net_caster) then
        return 0, 0
    end
    local poof_units = {}
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            poof_units[#poof_units + 1] = meepo
        end
    end
    if #poof_units <= 0 then
        return 0, 0
    end
    local _, max_radius, max_channel = get_ready_poof_burst_info(poof_units, now)
    local poof_time = now + 0.01
    if arrival_time and arrival_time > 0 then
        local desired_time = arrival_time + 0.02
        if desired_time > poof_time then
            poof_time = desired_time
        end
    end
    local anchor = net_caster
    local target_pos = target and safe_call(Entity.GetAbsOrigin, target) or nil
    if target_pos then
        local allowed_anchor_dist = get_allowed_poof_anchor_distance(max_radius)
        local preferred_anchor = select(1, choose_poof_anchor(poof_units, target_pos, allowed_anchor_dist, true))
        if preferred_anchor and Entity.IsAlive(preferred_anchor) then
            anchor = preferred_anchor
        end
    end
    local scheduled = schedule_poof_burst(poof_units, anchor, poof_time, "meepo_combo_net_follow_poof", 0, target_pos)
    if scheduled <= 0 then
        return 0, 0
    end
    local lock = 0
    if max_channel > 0 then
        local delay = math.max(0, poof_time - now)
        lock = delay + max_channel + (C.COMBO_POOF_STAGGER * math.max(0, scheduled - 1))
    end
    return scheduled, lock
end
local function try_combo_earthbind_chain(units, target, now, preferred_caster)
    local break_reason = script.get_control_break_reason(target, false)
    if break_reason then
        return false
    end
    if not is_combo_spell_enabled("net", ui.combo_use_net) then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if now - combo_net_last_global_cast < C.COMBO_NET_GLOBAL_RECAST_DELAY then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local remaining_root = get_effective_earthbind_remaining(target, now)
    local caster, net, arrival, cast_pos = choose_earthbind_caster(units, target, now, preferred_caster)
    if not caster or not net or not arrival then
        return false
    end
    local time_to_land = math.max(0, arrival - now)
    local hex_remaining = script.get_target_hex_remaining(target, now)
    if hex_remaining > (time_to_land + C.COMBO_POOF_SAFE_ROOT_BUFFER) then
        return false
    end
    local abyssal_remaining = script.get_target_abyssal_remaining(target, now)
    if abyssal_remaining > (time_to_land + C.COMBO_NET_CHAIN_BUFFER) then
        return false
    end
    if remaining_root > 0 then
        local handoff_window = time_to_land + C.COMBO_NET_CHAIN_BUFFER + C.COMBO_NET_HANDOFF_EXTRA
        if remaining_root > handoff_window then
            return false
        end
    end
    cast_pos = cast_pos or target_pos
    local caster_pos = safe_call(Entity.GetAbsOrigin, caster)
    if caster_pos then
        local dist_to_cast = vec_dist_2d(caster_pos, cast_pos)
        local max_cast_dist = get_net_cast_range(caster, net) + C.COMBO_NET_RANGE_PADDING
        if dist_to_cast and dist_to_cast > max_cast_dist and dist_to_cast > 0 then
            local scale = max_cast_dist / dist_to_cast
            cast_pos = Vector(
                (caster_pos.x or 0) + ((cast_pos.x or 0) - (caster_pos.x or 0)) * scale,
                (caster_pos.y or 0) + ((cast_pos.y or 0) - (caster_pos.y or 0)) * scale,
                cast_pos.z or (caster_pos.z or 0)
            )
        end
    end
    script._last_net_cast_pos = cast_pos
    script._last_net_cast_time = now
    local ok = pcall(function()
        Ability.CastPosition(
            net,
            cast_pos,
            false,
            true,
            true,
            "meepo_combo_earthbind_chain",
            false
        )
    end)
    if not ok then
        return false
    end
    local caster_key = get_entity_key(caster)
    combo_net_last_cast_by_meepo[caster_key] = now
    combo_net_last_global_cast = now
    local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
    if cast_point < 0 then
        cast_point = 0
    end
    caster_pos = safe_call(Entity.GetAbsOrigin, caster)
    local dist = (caster_pos and cast_pos) and (vec_dist_2d(caster_pos, cast_pos) or 0) or 0
    local turn_time = tonumber(safe_call(NPC.GetTimeToFacePosition, caster, cast_pos) or 0) or 0
    if turn_time < 0 then
        turn_time = 0
    elseif turn_time > C.COMBO_NET_FACE_TIME_CAP then
        turn_time = C.COMBO_NET_FACE_TIME_CAP
    end
    local speed = get_earthbind_projectile_speed(net)
    local arrival_time = now + turn_time + cast_point + (dist / math.max(1, speed))
    script._combo_net_pending_target_key = get_entity_key(target)
    script._combo_net_pending_arrival_time = arrival_time
    script._combo_net_pending_end_time = arrival_time + script.get_earthbind_root_duration(net)
    local follow_poof_count, follow_poof_lock = schedule_follow_poof_after_net(units, caster, target, now, arrival_time)
    script._combo_last_net_follow_poof_count = follow_poof_count or 0
    script._combo_last_net_follow_poof_time = now
    combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_NET_CAST_LOCK)
    set_combo_action_lock(now, C.COMBO_NET_CAST_LOCK)
    if follow_poof_lock and follow_poof_lock > 0 then
        combo_move_next_order_time = math.max(combo_move_next_order_time, now + follow_poof_lock)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
    end
    return true
end
local function try_combo_poof_burst(units, target, now)
    if not is_combo_spell_enabled("poof", ui.combo_use_poof) then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    local root_remaining = get_confirmed_control_remaining(target, now)
    if root_remaining < C.COMBO_POOF_ROOT_MIN_REMAINING then
        return false
    end
    local ready_count, max_radius, max_channel = get_ready_poof_burst_info(units, now)
    if ready_count <= 0 then
        return false
    end
    local required_root = get_required_root_for_poof(ready_count, max_channel)
    if root_remaining < required_root then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local allowed_anchor_dist = get_allowed_poof_anchor_distance(max_radius)
    local anchor = select(1, choose_poof_anchor(units, target_pos, allowed_anchor_dist))
    if not anchor then
        return false
    end
    local scheduled = schedule_poof_burst(units, anchor, now, "meepo_combo_poof_burst", nil, target_pos)
    if scheduled > 0 and max_channel > 0 then
        local total_lock = max_channel + (C.COMBO_POOF_STAGGER * math.max(0, scheduled - 1))
        combo_move_next_order_time = math.max(combo_move_next_order_time, now + total_lock)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
    end
    return scheduled > 0
end
local function try_combo_poof_burst_uncontrolled(units, target, now, reason)
    if not is_combo_spell_enabled("poof", ui.combo_use_poof) then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    local ready_count, max_radius, max_channel = get_ready_poof_burst_info(units, now)
    if ready_count <= 0 then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local allowed_anchor_dist = get_allowed_poof_anchor_distance(max_radius)
    local anchor = select(1, choose_poof_anchor(units, target_pos, allowed_anchor_dist))
    if not anchor then
        return false
    end
    local scheduled = schedule_poof_burst(units, anchor, now, reason or "meepo_combo_poof_uncontrolled", nil, target_pos)
    if scheduled > 0 and max_channel > 0 then
        local total_lock = max_channel + (C.COMBO_POOF_STAGGER * math.max(0, scheduled - 1))
        combo_move_next_order_time = math.max(combo_move_next_order_time, now + total_lock)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
    end
    return scheduled > 0
end
local function try_combo_poof_burst_hex_fallback(units, target, now)
    return try_combo_poof_burst_uncontrolled(units, target, now, "meepo_combo_poof_hex_fallback")
end
local function can_meepo_attack_target_now(meepo, target, target_pos, target_hull)
    if not meepo or not target or not Entity.IsAlive(meepo) or not Entity.IsAlive(target) then
        return false
    end
    local unit_pos = safe_call(Entity.GetAbsOrigin, meepo)
    if not unit_pos or not target_pos then
        return false
    end
    local dist = vec_dist_2d(unit_pos, target_pos)
    if not dist then
        return false
    end
    local attack_range = tonumber(safe_call(NPC.GetAttackRange, meepo) or 0) or 0
    local attack_bonus = tonumber(safe_call(NPC.GetAttackRangeBonus, meepo) or 0) or 0
    local meepo_hull = tonumber(safe_call(NPC.GetHullRadius, meepo) or 0) or 0
    local reach = attack_range + attack_bonus + meepo_hull + (target_hull or 0) + 30
    return dist <= reach
end
local function can_any_meepo_attack_target_now(units, target)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local target_hull = tonumber(safe_call(NPC.GetHullRadius, target) or 0) or 0
    for i = 1, #units do
        if can_meepo_attack_target_now(units[i], target, target_pos, target_hull) then
            return true
        end
    end
    return false
end
local function issue_combo_attack_order(player, units, target, now)
    if not player or not units or #units == 0 or not target or not Entity.IsAlive(target) then
        return false
    end
    if now < combo_attack_next_order_time then
        return false
    end
    local order_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if not order_type or not issuer_type or not Player or not Player.PrepareUnitOrders then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    local issued_any = false
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) and not is_combo_cast_in_progress(meepo) then
            local ok = pcall(function()
                Player.PrepareUnitOrders(
                    player,
                    order_type,
                    target,
                    target_pos,
                    nil,
                    issuer_type,
                    meepo,
                    false,
                    true,
                    true,
                    false,
                    "meepo_combo_attack_fallback",
                    false
                )
            end)
            if ok then
                issued_any = true
            end
        end
    end
    if issued_any then
        combo_attack_next_order_time = now + C.COMBO_ATTACK_ORDER_INTERVAL
        set_combo_action_lock(now, C.COMBO_ATTACK_ORDER_INTERVAL)
    end
    return issued_any
end
function script.issue_combo_hold_order(player, units, now, reason, hold_target)
    if not player or not units or #units == 0 then
        return false
    end
    if now < (script._combo_hold_next_order_time or 0) then
        return false
    end
    if not Player or not Player.HoldPosition then
        return false
    end
    local hold_target_pos = nil
    local hold_target_hull = 0
    if hold_target and Entity.IsAlive(hold_target) then
        hold_target_pos = safe_call(Entity.GetAbsOrigin, hold_target)
        hold_target_hull = tonumber(safe_call(NPC.GetHullRadius, hold_target) or 0) or 0
    end
    local issued = false
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) and not is_combo_cast_in_progress(meepo) then
            local can_attack_target = false
            if hold_target_pos then
                can_attack_target = can_meepo_attack_target_now(meepo, hold_target, hold_target_pos, hold_target_hull)
            end
            if not can_attack_target then
                local ok = pcall(function()
                    Player.HoldPosition(player, meepo, false, true, true, reason or "meepo_combo_hold_disable")
                end)
                if ok then
                    issued = true
                end
            end
        end
    end
    if issued then
        script._combo_hold_next_order_time = now + C.COMBO_HOLD_ORDER_INTERVAL
    end
    return issued
end
local function get_combo_target_fov_radius()
    if ui.combo_target_fov and ui.combo_target_fov.Get then
        local ok, value = pcall(function()
            return ui.combo_target_fov:Get()
        end)
        if ok and value ~= nil then
            local radius = tonumber(value) or 140
            if radius < 20 then
                radius = 20
            end
            return radius
        end
    end
    return 140
end
local function get_cursor_position()
    if not Input or not Input.GetCursorPos then
        return nil, nil
    end
    local ok, x, y = pcall(function()
        return Input.GetCursorPos()
    end)
    if not ok then
        return nil, nil
    end
    return tonumber(x), tonumber(y)
end
local function get_mouse1_code()
    if Enum and Enum.ButtonCode and Enum.ButtonCode.KEY_MOUSE1 ~= nil then
        return Enum.ButtonCode.KEY_MOUSE1
    end
    return nil
end
function list_has_string(list, value)
    if not list or not value then
        return false
    end
    for i = 1, #list do
        if tostring(list[i]) == tostring(value) then
            return true
        end
    end
    return false
end
local function get_mouse2_code()
    if Enum and Enum.ButtonCode and Enum.ButtonCode.KEY_MOUSE2 ~= nil then
        return Enum.ButtonCode.KEY_MOUSE2
    end
    return nil
end
