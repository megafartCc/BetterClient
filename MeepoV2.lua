local CONFIG = {
    -- Raw GitHub base URL without trailing slash.
    base_url = "https://raw.githubusercontent.com/megafartCc/BetterClient",
    branch = "main",
    root = "modules/meepov2",
}

local function compile_chunk(source, chunk_name)
    if type(load) == "function" then
        local chunk, err = load(source, chunk_name)
        if chunk then
            return chunk
        end
        if err then
            return nil, err
        end
    end

    if type(loadstring) == "function" then
        local chunk, err = loadstring(source, chunk_name)
        if not chunk then
            return nil, err
        end
        return chunk
    end

    return nil, "load/loadstring is unavailable"
end

local function try_http_get(url)
    local providers = {
        function()
            return type(http) == "table" and type(http.Get) == "function" and http.Get(url) or nil
        end,
        function()
            return type(HTTP) == "table" and type(HTTP.Get) == "function" and HTTP.Get(url) or nil
        end,
        function()
            return type(WebRequest) == "table" and type(WebRequest.Get) == "function" and WebRequest.Get(url) or nil
        end,
    }

    for i = 1, #providers do
        local ok, body = pcall(providers[i])
        if ok and type(body) == "string" and body ~= "" then
            return body
        end
    end

    return nil
end

local function load_local_module(path)
    local chunk, err = loadfile(path)
    if not chunk then
        return nil, err
    end
    return chunk()
end

local function try_bootstrap_remote()
    local url = string.format("%s/%s/%s/loader.lua", CONFIG.base_url, CONFIG.branch, CONFIG.root)
    local loader_source = try_http_get(url)

    if not loader_source then
        return nil, "HTTP GET provider is unavailable or loader.lua could not be downloaded"
    end

    local compile, compile_err = compile_chunk(loader_source, "@meepov2/loader.lua")
    if not compile then
        return nil, compile_err
    end

    local Loader = compile()
    local runtime = Loader.new(CONFIG)
    local manifest = runtime:run_module("manifest.lua")

    if type(manifest) ~= "table" or type(manifest.entry) ~= "string" then
        return nil, "manifest.lua must return a table with an 'entry' field"
    end

    return runtime:run_module(manifest.entry)
end

local function bootstrap()
    local remote_ok, remote_result = pcall(try_bootstrap_remote)
    if remote_ok and remote_result then
        return remote_result
    end

    -- Local fallback: useful for development/testing before pushing to GitHub.
    local Loader, loader_err = load_local_module("modules/meepov2/loader.lua")
    if not Loader then
        error(string.format("[MeepoV2] Remote bootstrap failed (%s) and local loader failed (%s)", tostring(remote_result), tostring(loader_err)))
    end

    local runtime = Loader.new(CONFIG)
    local manifest = load_local_module("modules/meepov2/manifest.lua")
    if type(manifest) ~= "table" or type(manifest.entry) ~= "string" then
        error("[MeepoV2] modules/meepov2/manifest.lua must return a table with an 'entry' field")
    end

    local entry, entry_err = load_local_module(string.format("modules/meepov2/%s", manifest.entry))
    if not entry then
        error(string.format("[MeepoV2] Failed to load local entry module: %s", tostring(entry_err)))
    end

    if type(entry) == "function" then
        return entry(runtime)
    end

    return entry
end

return bootstrap()
