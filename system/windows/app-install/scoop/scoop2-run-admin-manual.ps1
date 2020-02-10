set-executionpolicy remotesigned -scope currentuser
$env:SCOOP='C:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
$env:SCOOP_GLOBAL='C:\ScoopApps'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')
[environment]::SetEnvironmentvariable("Path", $env:Path + ";C:\Scoop\shims", "User")