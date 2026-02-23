local Loader = {}

local function trim_trailing_slash(value)
    if type(value) ~= "string" then
        return value
    end
    return (value:gsub("/+$", ""))
end

local function try_http_get(url)
    if type(http) == "table" and type(http.Get) == "function" then
        local ok, body = pcall(http.Get, url)
        if ok and type(body) == "string" and body ~= "" then
            return body
        end
    end

    if type(HTTP) == "table" and type(HTTP.Get) == "function" then
        local ok, body = pcall(HTTP.Get, url)
        if ok and type(body) == "string" and body ~= "" then
            return body
        end
    end

    if type(WebRequest) == "table" and type(WebRequest.Get) == "function" then
        local ok, body = pcall(WebRequest.Get, url)
        if ok and type(body) == "string" and body ~= "" then
            return body
        end
    end

    return nil
end

function Loader.new(config)
    local state = {
        base_url = trim_trailing_slash(config.base_url),
        branch = config.branch or "main",
        root = trim_trailing_slash(config.root or ""),
        cache = {},
    }

    local function make_url(path)
        local relative = path:gsub("^/+", "")
        local root_prefix = state.root ~= "" and (state.root .. "/") or ""
        return string.format("%s/%s/%s%s", state.base_url, state.branch, root_prefix, relative)
    end

    local function compile_chunk(source, chunk_name)
        local chunk, err = load(source, chunk_name)
        if not chunk then
            error(string.format("[MeepoV2] Failed to compile %s: %s", chunk_name, tostring(err)))
        end
        return chunk
    end

    function state:fetch(path)
        local cache_key = tostring(path)
        if self.cache[cache_key] then
            return self.cache[cache_key]
        end

        local url = make_url(path)
        local body = try_http_get(url)
        if not body then
            error(string.format("[MeepoV2] Failed to download module '%s' from '%s'.", cache_key, url))
        end

        self.cache[cache_key] = body
        return body
    end

    function state:run_module(path)
        local source = self:fetch(path)
        local chunk_name = string.format("@%s", make_url(path))
        local chunk = compile_chunk(source, chunk_name)
        local module = chunk()
        if type(module) == "function" then
            return module(self)
        end
        return module
    end

    return state
end

return Loader
