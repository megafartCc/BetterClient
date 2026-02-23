local manifest = {
    version = "2.2.0",
    entry = "app.lua",
    modules = {
        "app.lua",
        "loader.lua",
        "parts/00_base.lua",
        "parts/10_combo.lua",
        "parts/20_panels.lua",
        "parts/30_farm.lua",
        "parts/40_hooks.lua",
    },
}

return manifest
