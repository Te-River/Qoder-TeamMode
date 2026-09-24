<#
  Runs Qoder's OWN plugin validator (the one the "上传 ZIP" install path calls) against
  a directory or a freshly-extracted copy of dist/*.zip.

  Why this exists: the create-plugin skill's validate_qoder_plugin.py is NOT the host.
  It rejects array-valued `agents`, which is exactly the shape the host's schema
  requires (".md" paths), so a package can be green there and be refused here with the
  generic "扩展内容与当前版本不兼容" toast.

  Discovery: set $env:QODER_EXE to the Qoder executable if auto-discovery misses it.
#>
param([string]$Target)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $Target) { $Target = $root }

$exe = $env:QODER_EXE
$roots = @($env:ProgramFiles, ${env:ProgramFiles(x86)}, 'D:\Qoder CN', (Join-Path $env:LOCALAPPDATA 'Programs')) |
  ForEach-Object { if ($_) { Join-Path $_ 'Qoder CN' } }
$roots = @($roots) + @('D:\Qoder CN', (Join-Path $env:LOCALAPPDATA 'Programs\Qoder CN'))
$runtime = $null
foreach ($c in ($roots | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique)) {
  if (-not $exe) {
    # The app launcher at the install root; the versioned copy under .qoder-versions works too.
    $exe = (Get-ChildItem -LiteralPath $c -Filter '*.exe' -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -notlike 'Uninstall*' } | Select-Object -First 1).FullName
  }
  $runtime = (Get-ChildItem -LiteralPath $c -Recurse -Filter 'qoder-worker-runtime*.mjs' -ErrorAction SilentlyContinue |
    Sort-Object FullName -Descending | Select-Object -First 1).FullName
  if ($exe -and $runtime) { break }
}
if (-not $exe) { throw 'Qoder executable not found; set $env:QODER_EXE' }
if (-not $runtime) { throw "qoder-worker-runtime*.mjs not found near $exe" }

$tmp = $null
if ($Target -like '*.zip') {
  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("qoder-plugin-validate-" + [Guid]::NewGuid().ToString('N').Substring(0, 8))
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($Target, $tmp)
  $Target = $tmp
}

$env:ELECTRON_RUN_AS_NODE = '1'
try {
  & $exe $runtime 'plugins' 'validate' $Target '--json' 2>&1 | ForEach-Object { "$_" }
  exit $LASTEXITCODE
} finally {
  Remove-Item Env:ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue
  if ($tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }
}
