<#
  Builds dist/team-mode-<version>.zip for the Qoder "扩展 → 插件 → 添加插件 → 上传" flow.

  The validator and the host both require .qoder-plugin/plugin.json to sit at the
  ROOT of the archive, so this packs the plugin's contents, never the folder that
  holds them.
#>
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
# Regex, not ConvertFrom-Json: Windows PowerShell 5.1 decodes -Raw with the OEM
# codepage, which mangles descriptionZh and makes JSON parsing throw.
$raw = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root '.qoder-plugin/plugin.json')
$version = [regex]::Match($raw, '"version"\s*:\s*"([^"]+)"').Groups[1].Value
if (-not $version) { throw "could not read version from .qoder-plugin/plugin.json" }

$distDir = Join-Path $root 'dist'
New-Item -ItemType Directory -Force -Path $distDir | Out-Null
$zipPath = Join-Path $distDir "team-mode-$version.zip"
if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }

$excludeDirs = @('dist', '.git', '.qoder-credits', '__MACOSX', '__pycache__')
$excludeNames = @('.DS_Store', 'settings.local.json')

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  Get-ChildItem -LiteralPath $root -Recurse -File -Force | ForEach-Object {
    $rel = $_.FullName.Substring($root.Length + 1).Replace('\', '/')
    $parts = $rel.Split('/')
    $skip = $false
    foreach ($p in $parts) { if ($excludeDirs -contains $p) { $skip = $true } }
    if ($skip) { return }
    if ($excludeNames -contains $parts[-1]) { return }
    $entry = $archive.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
    $in = [System.IO.File]::OpenRead($_.FullName)
    $out = $entry.Open()
    try { $in.CopyTo($out) } finally { $out.Dispose(); $in.Dispose() }
    Write-Host "  + $rel"
  }
} finally { $archive.Dispose() }

Write-Host "`nWrote $zipPath"
