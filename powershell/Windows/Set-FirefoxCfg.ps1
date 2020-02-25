$overridepath = "C:\Program Files\Mozilla Firefox\browser\override.ini"
$localsettingspath = "C:\Program Files\Mozilla Firefox\defaults\pref\local-settings.js"
$cfgpath = "C:\Program Files\Mozilla Firefox\mozilla.cfg"

$overrideini = @"
[XRE]
EnableProfileMigrator=false
"@

$localsettingsjs = @"
pref("general.config.obscure_value", 0);
pref("general.config.filename", "mozilla.cfg");
"@

$originalcfg = Get-Content -Path $cfgpath
$mozillacfg = Get-Content -Path $cfgpath

$prefs = @(
    "lockPref(`"gfx.direct2d.disabled`", true);",
    "lockPref(`"layers.acceleration.disabled`", true);"
)

foreach ($pref in $prefs) {
    if ($mozillacfg -notcontains $pref) {
        $mozillacfg += $pref
    }    
}

if (!($originalcfg -ne $mozillacfg)) {
    Write-Output $mozillacfg | Out-File $cfgpath
}
