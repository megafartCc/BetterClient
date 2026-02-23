local PARTS = {
    "parts/00_base.lua",
    "parts/10_combo.lua",
    "parts/20_panels.lua",
    "parts/30_farm.lua",
    "parts/40_hooks.lua",
}

local function read_local(path)
    local file, err = io.open("modules/meepov2/" .. path, "rb")
    if not file then
        return nil, err
    end
    local body = file:read("*a")
    file:close()
    return body
end

local function read_part(runtime, path)
    if runtime and runtime.fetch then
        return runtime:fetch(path)
    end
    return read_local(path)
end

local function build_bundle(runtime)
    local sections = {}
    for _, path in ipairs(PARTS) do
        local body, err = read_part(runtime, path)
        if not body or body == "" then
            error(string.format("[MeepoV2] Failed to load part '%s': %s", tostring(path), tostring(err)))
        end
        sections[#sections + 1] = body
    end
    return table.concat(sections, "\n")
end

return function(runtime)
    local source = build_bundle(runtime)
    local chunk, err = load(source, "@modules/meepov2/bundle.lua")
    if not chunk then
        error(string.format("[MeepoV2] Failed to compile bundled source: %s", tostring(err)))
    end
    return chunk()
end
