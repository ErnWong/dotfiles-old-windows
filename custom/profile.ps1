$scoopdir = "$env:USERPROFILE\Scoop"

# Scoop shims
$env:PATH = "$scoopdir\shims;$env:PATH"

try {
    Get-command -Name "git" -ErrorAction Stop >$null
    Import-Module -Name "posh-git" -ErrorAction Stop >$null
    $gitStatus = $true
} catch {
    Write-Warning "Missing git support, install posh-git with 'Install-Module posh-git' and restart."
    $gitStatus = $false
}

function checkGit($Path) {
    if (Test-Path -Path (Join-Path $Path '.git/') ) {
        Write-VcsStatus
        return
    }
    $SplitPath = split-path $path
    if ($SplitPath) {
        checkGit($SplitPath)
    }
}

# Cmder prompt! and git status in git repos
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    $Host.UI.RawUI.ForegroundColor = "White"
    Write-Host $pwd.ProviderPath -NoNewLine -ForegroundColor Green
    if($gitStatus){
        checkGit($pwd.ProviderPath)
    }
    $global:LASTEXITCODE = $realLASTEXITCODE
    Write-Host "`n$([char]0x03BB)" -NoNewLine -ForegroundColor "DarkGray"
    return " "
}

# Start SSH agent via posh-git
if ($gitStatus) {
    Start-SshAgent -Quiet
}

# Teleport
Set-Location -Path $Env:USERPROFILE

# vim:ft=ps1
