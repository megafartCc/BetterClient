-- Usage: lua tools/check_local_limit.lua "MeepoV2 (1).lua"
-- Heuristic checker for Lua 5.1 local-variable limit (200) per function.

local path = arg[1]
if not path or path == "" then
    io.stderr:write("usage: lua tools/check_local_limit.lua <file.lua>\n")
    os.exit(2)
end

local f = assert(io.open(path, "r"))
local src = f:read("*a")
f:close()

src = src:gsub("%-%-%[%[.-%]%]", "")
src = src:gsub("%-%-[^\n]*", "")
src = src:gsub('"[^"\\\n]*"', '""')
src = src:gsub("'[^'\\\n]*'", "''")

local lines = {}
for line in src:gmatch("([^\n]*)\n?") do
    lines[#lines + 1] = line
end

local stack = {}
local function push(name, line)
    stack[#stack + 1] = { name = name or "<anon>", line = line, locals = 0, blocks = { "function" } }
end
local function top() return stack[#stack] end

for i = 1, #lines do
    local line = lines[i]

    local localFn = line:match("%f[%a]local%s+function%s+([%w_%.:]+)")
    if localFn and top() then
        top().locals = top().locals + 1
    end

    if line:match("%f[%a]function%f[%A]") then
        local fnName = line:match("%f[%a]function%s+([%w_%.:]+)") or "<anon>"
        push(fnName, i)
    end

    local current = top()
    if current then
        for decl in line:gmatch("%f[%a]local%s+([^=\n]+)") do
            if not decl:match("^function%s+") then
                local n = 0
                for _ in decl:gmatch("[%w_]+") do
                    n = n + 1
                end
                current.locals = current.locals + n
            end
        end
    end

    for _ in line:gmatch("%f[%a](if|for|while|do|repeat)%f[%A]") do
        if top() then top().blocks[#top().blocks + 1] = "block" end
    end

    for _ in line:gmatch("%f[%a](end|until)%f[%A]") do
        if top() then
            local b = table.remove(top().blocks)
            if b == "function" then
                local fn = table.remove(stack)
                if fn.locals > 200 then
                    io.write(string.format("FAIL %s:%d has %d locals (>200)\n", fn.name, fn.line, fn.locals))
                    os.exit(1)
                end
            end
        end
    end
end

io.write("OK: no function exceeded 200 locals (heuristic scan).\n")
