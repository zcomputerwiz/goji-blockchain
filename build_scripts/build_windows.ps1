# $env:path should contain a path to editbin.exe and signtool.exe

$ErrorActionPreference = "Stop"

mkdir build_scripts\win_build
Set-Location -Path ".\build_scripts\win_build" -PassThru

git status

Write-Output "   ---"
Write-Output "curl miniupnpc"
Write-Output "   ---"
Invoke-WebRequest -Uri "https://pypi.chia.net/simple/miniupnpc/miniupnpc-2.2.2-cp39-cp39-win_amd64.whl" -OutFile "miniupnpc-2.2.2-cp39-cp39-win_amd64.whl"
Write-Output "Using win_amd64 python 3.9 wheel from https://github.com/miniupnp/miniupnp/pull/475 (2.2.0-RC1)"
Write-Output "Actual build from https://github.com/miniupnp/miniupnp/commit/7783ac1545f70e3341da5866069bde88244dd848"
If ($LastExitCode -gt 0){
    Throw "Failed to download miniupnpc!"
}
else
{
    Set-Location -Path - -PassThru
    Write-Output "miniupnpc download successful."
}

Write-Output "   ---"
Write-Output "Create venv - python3.9 is required in PATH"
Write-Output "   ---"
python -m venv venv
. .\venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install wheel pep517
pip install pywin32
pip install pyinstaller==4.5
pip install setuptools_scm

Write-Output "   ---"
Write-Output "Get _INSTALLER_VERSION"
# The environment variable _INSTALLER_VERSION needs to be defined
$env:_INSTALLER_VERSION = python .\build_scripts\installer-version.py -win

if (-not (Test-Path env:_INSTALLER_VERSION)) {
  $env:_INSTALLER_VERSION = '0.0.0'
  Write-Output "WARNING: No environment variable _INSTALLER_VERSION set. Using 0.0.0"
  }
Write-Output " Version is: $env:_INSTALLER_VERSION"
Write-Output "   ---"

Write-Output "Checking if madmax exists"
Write-Output "   ---"
if (Test-Path -Path .\madmax\) {
    Write-Output "   madmax exists, moving to expected directory"
    mv .\madmax\ .\venv\lib\site-packages\
}

Write-Output "Checking if bladebit exists"
Write-Output "   ---"
if (Test-Path -Path .\bladebit\) {
    Write-Output "   bladebit exists, moving to expected directory"
    mv .\bladebit\ .\venv\lib\site-packages\
}

Write-Output "   ---"
Write-Output "Build chia-blockchain wheels"
Write-Output "   ---"
pip wheel --use-pep517 --extra-index-url https://pypi.chia.net/simple/ -f . --wheel-dir=.\build_scripts\win_build .

Write-Output "   ---"
Write-Output "Install chia-blockchain wheels into venv with pip"
Write-Output "   ---"

Write-Output "pip install miniupnpc"
Set-Location -Path ".\build_scripts" -PassThru
pip install --no-index --find-links=.\win_build\ miniupnpc
# Write-Output "pip install setproctitle"
# pip install setproctitle==1.2.2

Write-Output "pip install -blockchain"
pip install --no-index --find-links=.\win_build\ -blockchain

Write-Output "   ---"
Write-Output "Use pyinstaller to create  .exe's"
Write-Output "   ---"
$SPEC_FILE = (python -c 'import ; print(.PYINSTALLER_SPEC_PATH)') -join "`n"
pyinstaller --log-level INFO $SPEC_FILE

Write-Output "   ---"
Write-Output "Copy  executables to -blockchain-gui\"
Write-Output "   ---"
Copy-Item "dist\daemon" -Destination "..\-blockchain-gui\" -Recurse
Set-Location -Path "..\-blockchain-gui" -PassThru

git status

Write-Output "   ---"
Write-Output "Prepare Electron packager"
Write-Output "   ---"
$Env:NODE_OPTIONS = "--max-old-space-size=3000"
npm install --save-dev electron-winstaller
npm install -g electron-packager
npm install
npm audit fix

git status

Write-Output "   ---"
Write-Output "Electron package Windows Installer"
Write-Output "   ---"
npm run build
If ($LastExitCode -gt 0){
    Throw "npm run build failed!"
}

Write-Output "   ---"
Write-Output "Increase the stack for  command for ( plots create) chiapos limitations"
# editbin.exe needs to be in the path
editbin.exe /STACK:8000000 daemon\.exe
Write-Output "   ---"

$packageVersion = "$env:_INSTALLER_VERSION"
$packageName = "-$packageVersion"

Write-Output "packageName is $packageName"

Write-Output "   ---"
Write-Output "fix version in package.json"
choco install jq
cp package.json package.json.orig
jq --arg VER "$env:_INSTALLER_VERSION" '.version=$VER' package.json > temp.json
rm package.json
mv temp.json package.json
Write-Output "   ---"

Write-Output "   ---"
Write-Output "electron-packager"
electron-packager .  --asar.unpack="**\daemon\**" --overwrite --icon=.\src\assets\img\.ico --app-version=$packageVersion
Write-Output "   ---"

Write-Output "   ---"
Write-Output "node winstaller.js"
node winstaller.js
Write-Output "   ---"

git status

If ($env:HAS_SECRET) {
   Write-Output "   ---"
   Write-Output "Add timestamp and verify signature"
   Write-Output "   ---"
   signtool.exe timestamp /v /t http://timestamp.comodoca.com/ .\release-builds\windows-installer\Setup-$packageVersion.exe
   signtool.exe verify /v /pa .\release-builds\windows-installer\Setup-$packageVersion.exe
   }   Else    {
   Write-Output "Skipping timestamp and verify signatures - no authorization to install certificates"
}

git status

Write-Output "   ---"
Write-Output "Windows Installer complete"
Write-Output "   ---"
