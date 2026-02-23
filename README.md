# BetterClient

Modular Meepo script with a single remote bootstrap entry.

## One-line Remote Load

```lua
return loadstring(http.Get("https://raw.githubusercontent.com/megafartCc/BetterClient/main/MeepoV2.lua"))()
```

If your runtime exposes a different HTTP getter, fetch the same URL and execute it with `load`/`loadstring`.

## Structure

- `MeepoV2.lua`: bootstrap loader (single entrypoint)
- `modules/meepov2/loader.lua`: remote module fetch/runtime cache
- `modules/meepov2/manifest.lua`: module manifest + entry file
- `modules/meepov2/app.lua`: bundles parts and compiles final script
- `modules/meepov2/parts/`: split modules (`base`, `combo`, `panels`, `farm`, `hooks`)

## Updating Modules

Use:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\split_meepov2.ps1
```

Default source is:

- `C:\Users\da204\Downloads\uc\scripts\MeepoV2.lua`

You can override:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\split_meepov2.ps1 -Source "C:\path\to\MeepoV2.lua"
```
