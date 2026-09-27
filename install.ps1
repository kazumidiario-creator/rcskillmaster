# install.ps1 - cria junctions das skills deste pacote nas pastas que Claude Code e Codex leem.
# Uso (de qualquer pasta):
#   powershell -ExecutionPolicy Bypass -File <clone>\install.ps1 [-Only claude|codex] [-Skill a,b] [-Exclude a,b] [-Project <pasta do projeto>] [-ForceGuide]
# -Project copia templates\SKILLS.md para <projeto>\.ai\SKILLS.md se ainda nao existir (e o guia que o rcskillmaster le); -ForceGuide sobrescreve.
# Nao precisa de administrador (junction, nao symlink). Pasta ou link que ja existe no destino e deixado em paz.
# Os links apontam para ESTE clone: nao apague nem mova a pasta depois de instalar.
param(
    [ValidateSet('all', 'claude', 'codex')] [string]$Only = 'all',
    [string[]]$Skill = @(),
    [string[]]$Exclude = @(),
    [string]$Project = '',
    [switch]$ForceGuide
)
$ErrorActionPreference = 'Stop'
$raiz = $PSScriptRoot
if (-not $raiz) { throw 'Execute o install.ps1 como arquivo (powershell -File install.ps1), nao por dot-source nem iex.' }
$pastaSkills = Join-Path $raiz 'skills'
$skills = @(Get-ChildItem -LiteralPath $pastaSkills -Directory)
if ($skills.Count -eq 0) { throw "nenhuma skill em $pastaSkills" }
# -File entrega 'a,b' como uma string so: dividir por virgula
$Skill   = @($Skill   | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$Exclude = @($Exclude | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$nomes = @($skills | ForEach-Object { $_.Name })
foreach ($lista in @(@{n='-Skill'; v=$Skill}, @{n='-Exclude'; v=$Exclude})) {
    $faltando = @($lista.v | Where-Object { $_ -notin $nomes })
    if ($faltando.Count -gt 0) { throw "$($lista.n): skill nao encontrada em skills\: $($faltando -join ', ')" }
}
if ($Skill.Count -gt 0)   { $skills = @($skills | Where-Object { $_.Name -in $Skill }) }
if ($Exclude.Count -gt 0) { $skills = @($skills | Where-Object { $_.Name -notin $Exclude }) }
if ($skills.Count -eq 0) { throw 'a combinacao de -Skill e -Exclude nao deixou nenhuma skill' }
$home_ = if ($env:USERPROFILE) { $env:USERPROFILE } else { [Environment]::GetFolderPath('UserProfile') }
$destinos = @()
if ($Only -in 'all', 'claude') { $destinos += (Join-Path $home_ '.claude\skills') }
if ($Only -in 'all', 'codex')  { $destinos += (Join-Path $home_ '.agents\skills'); $destinos += (Join-Path $home_ '.codex\skills') }

$criadas = 0; $mantidas = 0
foreach ($destino in $destinos) {
    New-Item -ItemType Directory -Force -Path $destino | Out-Null
    foreach ($s in $skills) {
        $alvo = Join-Path $destino $s.Name
        if (Test-Path -LiteralPath $alvo) { Write-Warning "ja existe, deixado em paz: $alvo"; $mantidas++; continue }
        $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
        $saida = cmd /c mklink /J "$alvo" "$($s.FullName)" 2>&1
        $codigo = $LASTEXITCODE
        $ErrorActionPreference = $prev
        if ($codigo -ne 0) { throw "mklink falhou em ${alvo}: $saida" }
        Write-Host "junction: $alvo -> $($s.FullName)"; $criadas++
    }
}

if ($Project) {
    if (-not (Test-Path -LiteralPath $Project -PathType Container)) { throw "pasta do projeto nao existe: $Project" }
    $guia = Join-Path (Resolve-Path -LiteralPath $Project).Path '.ai\SKILLS.md'
    if ((Test-Path -LiteralPath $guia) -and -not $ForceGuide) { Write-Warning "guia ja existe, nao sobrescrevo (use -ForceGuide para trocar): $guia" }
    else {
        New-Item -ItemType Directory -Force -Path (Split-Path $guia) | Out-Null
        Copy-Item -LiteralPath (Join-Path $raiz 'templates\SKILLS.md') -Destination $guia -Force
        Write-Host "guia $(if ($ForceGuide) { 'sobrescrito' } else { 'criado' }): $guia (revise as fichas: apague as das skills que voce nao instalou)"
    }
}
Write-Host "Pronto: $criadas links criados, $mantidas ja existiam. Os links apontam para $pastaSkills (nao apague nem mova o clone)."
Write-Host "Abra uma sessao nova do Claude Code ou do Codex na raiz do projeto e confira com /rcskillmaster (Claude) ou `$rcskillmaster (Codex)."
