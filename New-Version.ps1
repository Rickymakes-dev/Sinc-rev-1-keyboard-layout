<#
.SYNOPSIS
Creates the next version folder from the latest vX-Y-Z folder.

.DESCRIPTION
Edit the call at the bottom of this file, then press the Run button in VS Code.
  -Major $false  minor update (v1-0-0 -> v1-1-0)
  -Major $true   major update (v1-0-0 -> v2-0-0)
  -ImportMode $true   move the .json from the "download" folder into the new version folder
                      (renamed to match the version), then empty the "download" folder.
  -ImportMode $false  copy the last version's .json into the new version folder.
#>
function New-Version {
    [CmdletBinding()]
    param(
        [bool]$Major = $false,
        [bool]$ImportMode = $true
    )

    $ErrorActionPreference = 'Stop'
    $root = $PSScriptRoot
    $downloadDir = Join-Path $root 'download'

    $latest = Get-ChildItem -Path $root -Directory |
        Where-Object { $_.Name -match '^v(\d+)-(\d+)-(\d+)$' } |
        Sort-Object { [version]($_.Name.Substring(1) -replace '-', '.') } |
        Select-Object -Last 1
    if (-not $latest) { throw 'No existing version folder (vX-Y-Z) found.' }

    $null = $latest.Name -match '^v(\d+)-(\d+)-(\d+)$'
    $maj = [int]$Matches[1]; $min = [int]$Matches[2]
    if ($Major) { $maj++; $min = 0 } else { $min++ }

    $oldTag = $latest.Name.Substring(1)          # 1-0-0
    $newTag = "$maj-$min-0"                      # 1-1-0
    $oldDot = $oldTag -replace '-', '.'
    $newDir = Join-Path $root "v$newTag"
    if (Test-Path $newDir) { throw "$newDir already exists." }

    # Resolve the source json before creating anything.
    if ($ImportMode) {
        if (-not (Test-Path $downloadDir)) { New-Item -ItemType Directory -Path $downloadDir | Out-Null }
        $sourceJson = Get-ChildItem -Path $downloadDir -Filter '*.json' -File |
            Sort-Object LastWriteTime | Select-Object -Last 1
        if (-not $sourceJson) { throw "No .json file found in $downloadDir." }
        $sourceJson = $sourceJson.FullName
    }
    else {
        $sourceJson = Join-Path $latest.FullName "version-$oldTag.json"
        if (-not (Test-Path $sourceJson -PathType Leaf)) { throw "$sourceJson not found." }
    }

    New-Item -ItemType Directory -Path $newDir | Out-Null

    $newJson = Join-Path $newDir "version-$newTag.json"
    if ($ImportMode) {
        Move-Item -Path $sourceJson -Destination $newJson
        Get-ChildItem -Path $downloadDir -Force | Where-Object Name -ne '.gitkeep' | Remove-Item -Recurse -Force
    }
    else {
        Copy-Item -Path $sourceJson -Destination $newJson
    }

    $oldNote = Join-Path $latest.FullName "version-$oldTag-note.md"
    $notePath = Join-Path $newDir "version-$newTag-note.md"
    if (Test-Path $oldNote) {
        Copy-Item -Path $oldNote -Destination $notePath
        $lines = [System.Collections.Generic.List[string]](Get-Content -Path $notePath)

        $idx = @{}
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^##\s+(.+?)\s*$') { $idx[$Matches[1].ToLower()] = $i }
        }
        $fIdx = $idx['feature']; $uIdx = $idx['what was updated']
        if ($null -eq $fIdx -or $null -eq $uIdx -or $uIdx -le $fIdx) {
            throw 'Note must contain "## Feature" followed by "## What Was Updated".'
        }

        $nextIdx = ($idx.Values | Where-Object { $_ -gt $uIdx } | Measure-Object -Minimum).Minimum
        if ($null -eq $nextIdx) { $nextIdx = $lines.Count }

        $featureBody = @($lines[($fIdx + 1)..($uIdx - 1)])
        $updatedBody = @($lines[($uIdx + 1)..($nextIdx - 1)])
        while ($featureBody.Count -and [string]::IsNullOrWhiteSpace($featureBody[-1])) { $featureBody = $featureBody[0..($featureBody.Count - 2)] }
        while ($updatedBody.Count -and [string]::IsNullOrWhiteSpace($updatedBody[0])) { $updatedBody = $updatedBody[1..($updatedBody.Count - 1)] }
        while ($updatedBody.Count -and [string]::IsNullOrWhiteSpace($updatedBody[-1])) { $updatedBody = $updatedBody[0..($updatedBody.Count - 2)] }

        $out = [System.Collections.Generic.List[string]]::new()
        $out.AddRange([string[]]$lines[0..$fIdx])
        $out.AddRange([string[]]$featureBody)
        $out.Add('')
        $out.Add("### Version $oldDot")
        $out.Add('')
        $out.AddRange([string[]]$updatedBody)
        $out.Add('')
        $out.Add($lines[$uIdx])
        $out.Add('')
        $out.Add('- ')
        $out.Add('')
        if ($nextIdx -lt $lines.Count) { $out.AddRange([string[]]$lines[$nextIdx..($lines.Count - 1)]) }

        # Point the File section at the new version.
        $inFile = $false
        for ($i = 0; $i -lt $out.Count; $i++) {
            if ($out[$i] -match '^##\s+') { $inFile = ($out[$i] -match '^##\s+File\s*$') }
            elseif ($inFile) { $out[$i] = $out[$i].Replace("version-$oldTag", "version-$newTag") }
        }

        Set-Content -Path $notePath -Value $out -Encoding UTF8
    }

    Write-Host "Created $newDir (from $($latest.Name), ImportMode=$ImportMode)"
}

# Edit these values, then press Run.
New-Version -Major $false -ImportMode $true
