# PushD
Deploy to multiple locations with ease.

## Configuration
Define your configurations in `pushd.yml` in a YAML and PushD does the rest. PushD accepts configuration file name as well so that can have multiple configurations files for staging and production. 


```YAML
# pushd.yml

# Name of your app for display purpose
name: 'MyApp'

# backup source of production
backup_source: 'C:\Workspace\MyApp'

# Backup destination of production
backup_destination: 'C:\Workpsace\Backups\MyApp'

# Source directory for new deployment
source: 'C:\Workspace\Release\MyApp-1.0'

# List of destinations directories
destination:
  - 'C:\Workspace\MyApp' # Also a backup source
  - '\\dev01.mydomain.com\c$\Workspace\MyApp'

options:

  # Shows descriptive output
  verbos: true

  # Delete files no longer doesn't exist in source
  purge: true

  # List all actions without effecting files of destinations
  dry_run: true

  # List of exclude files for copy or purge from destination
  exclude:
    - 'Web.config'
    - 'Log4net.xml'
    - '*app_offline.htm'
```
