# windowsで開発サーバーを起動するためのスクリプト

Set-Location $PSScriptRoot

gem list foreman -i --silent | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing foreman..."
    gem install foreman
}

if (-not $Env:PORT) {
    $Env:PORT = "3000"
}

$Env:RUBY_DEBUG_OPEN = "true"
$Env:RUBY_DEBUG_LAZY = "true"

foreman start -f Procfile.windows $args
