param(
  [string]$configYaml
)

# Loading YamlDotNet assembly
$scriptPath = Split-Path $MyInvocation.MyCommand.Path
$libDir = Join-Path $scriptPath "lib"
$assemblyFile = Join-Path $libDir "YamlDotNet.dll"
[Reflection.Assembly]::LoadFrom($assemblyFile) | Out-Null

function Convert-PSObject($node) {
    switch($node.GetType().FullName){
        "YamlDotNet.RepresentationModel.YamlMappingNode"{
            $ret = @{}
            foreach($i in $node.Children.Keys) {
                $ret[$i.Value] = Convert-PSObject $node.Children[$i]
            }
            return $ret
        }
        "YamlDotNet.RepresentationModel.YamlSequenceNode" {
            $ret = [System.Collections.Generic.List[object]](New-Object "System.Collections.Generic.List[object]")
            foreach($i in $node.Children){
                $ret.Add((Convert-PSObject $i))
            }
            return $ret
        }
        "YamlDotNet.RepresentationModel.YamlScalarNode" {
            $value = $node.Value
            if (!($value -is [string])) {
                return $value
            }
            $types = @([int], [long], [double], [boolean], [datetime])
            foreach($i in $types){
                try {
                    return $i::Parse($value)
                } catch {
                    continue
                }
            }
            return $value
        }
    }

    Throw "Unknown node type: " + $node.GetType().FullName
}

$stringReader = New-Object System.IO.StringReader((Get-Content $configYaml -Raw))
$yamlStream = New-Object "YamlDotNet.RepresentationModel.YamlStream"
$yamlStream.Load([System.IO.TextReader] $stringReader)
$stringReader.Close()
$documents = $yamlStream.Documents

if (!$documents.Count) {
    return
}

if($documents.Count -eq 1){
    $config = Convert-PSObject $documents[0].RootNode
}
else {
  $config = @()
  foreach($i in $documents) {
      $config += Convert-PSObject $i.RootNode
  }
}

return $config
