# PushD deployment script
param(
  [string]$configYaml = "pushd.yml"
)

$date = Get-Date
$config = .\config.ps1 $configYaml

write-host
write-host "---------------------------------------------------------------------------" -foregroundcolor "green"
write-host "    Starting deployment for application '$($config.name)'." -foregroundcolor "green"
write-host "---------------------------------------------------------------------------" -foregroundcolor "green"
echo . . .

if($config.backup_source -and $config.backup_destination) {
  $backup_source = $config.backup_source
  $backup_destination = Join-Path $config.backup_destination $date.ToString("yyyy-MM-dd-HH-mm")
  if ($config.dry_run) { $dry_run = "/l" }

  write-host "---------------------------------------------------------------------------" -foregroundcolor "green"
  write-host "    Backing up..." -foregroundcolor "green"
  write-host "---------------------------------------------------------------------------" -foregroundcolor "green"
  robocopy $backup_source $backup_destination /s /e /purge /xo /np /eta $dry_run
  write-host "---------------------------------------------------------------------------" -foregroundcolor "green"
  write-host "    Backup Done..." -foregroundcolor "green"
  write-host "---------------------------------------------------------------------------" -foregroundcolor "green"
}

echo . . .
write-host "---------------------------------------------------------------------------" -foregroundcolor "green"
write-host "    Starting Deployment..." -foregroundcolor "green"
write-host "---------------------------------------------------------------------------" -foregroundcolor "green"

$options = $config.options
$roboOptions = @("/s", "/e", "/np", "/eta", "/fft")

if($options.purge) { $roboOptions += "/purge" }
if($options.exclude -and $options.exclude.length) { $roboOptions += @("/xf") + $options.exclude }
if($options.verbos) { $roboOptions += "/v" }
if($options.dry_run) { $roboOptions += "/l" }

$destinations = if ($config.destination -is [string]) { @($config.destination) } else { $config.destination }
foreach($destination in $destinations) {
    robocopy "$($config.source)" "$destination" $roboOptions
}
write-host "---------------------------------------------------------------------------" -foregroundcolor "green"
write-host "    Deployment Done..." -foregroundcolor "green"
write-host "---------------------------------------------------------------------------" -foregroundcolor "green"
