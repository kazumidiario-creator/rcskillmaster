# uninstall.ps1 - remove SO os links (junctions) das skills deste pacote em ~\.claude\skills, ~\.agents\skills e ~\.codex\skills.
# Uso: powershell -ExecutionPolicy Bypass -File <clone>\uninstall.ps1 [-Project <pasta do projeto>]
# Nunca apaga pasta real: um destino que nao seja junction e deixado em paz, com aviso. -Project apaga tambem <projeto>\.ai\SKILLS.md.
param([string]$Project = '')
$ErrorActionPreference = 'Stop'
$raiz = $PSScriptRoot
if (-not $raiz) { throw 'Execute o uninstall.ps1 como arquivo (powershell -File uninstall.ps1).' }
$nomes = @(Get-ChildItem -LiteralPath (Join-Path $raiz 'skills') -Directory | ForEach-Object { $_.Name })
$home_ = if ($env:USERPROFILE) { $env:USERPROFILE } else { [Environment]::GetFolderPath('UserProfile') }
$removidos = 0
foreach ($destino in @((Join-Path $home_ '.claude\skills'), (Join-Path $home_ '.agents\skills'), (Join-Path $home_ '.codex\skills'))) {
    foreach ($n in $nomes) {
        $alvo = Join-Path $destino $n
        if (-not (Test-Path -LiteralPath $alvo)) { continue }
        $item = Get-Item -LiteralPath $alvo -Force
        if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { Write-Warning "nao e link, deixado em paz: $alvo"; continue }
        # rmdir do cmd remove a junction sem entrar nela; Remove-Item -Recurse seguiria o link e apagaria a origem
        $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
        $saida = cmd /c rmdir "$alvo" 2>&1
        $codigo = $LASTEXITCODE
        $ErrorActionPreference = $prev
        if ($codigo -ne 0) { throw "rmdir falhou em ${alvo}: $saida" }
        Write-Host "removido: $alvo"; $removidos++
    }
}
if ($Project) {
    $guia = Join-Path $Project '.ai\SKILLS.md'
    if (Test-Path -LiteralPath $guia) { Remove-Item -LiteralPath $guia; Write-Host "removido: $guia" }
}
Write-Host "Pronto: $removidos links removidos. O clone e as skills reais continuam onde estavam."
