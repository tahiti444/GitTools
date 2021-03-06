# functions:
# -------------------------------------

function Convert-UTF {
    # Writes a file in UTF8 with a parsed text variable
    param (
        [string]$MyPath,
        [string]$MyText
    )
    
    Write-Output $MyText > $MyPath
    $MyRawString = Get-Content -Raw $MyPath
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($MyPath, $MyRawString, $Utf8NoBomEncoding)
}

# Script
# -------------------------------------

# git ignore
Convert-UTF ".\.gitignore" ".env/*"
# git initialize
git init
# conda:
if (Test-Path -Path ".\env") {
    Write-Output "Path exists, skipping..."
} else {
    New-Item -Path ".\env\" -ItemType "Directory"
}
$StrConda = "name: .env`n`nchannels:`n  - defaults`n  - conda-forge`n`ndependencies:`n  - python=3.8`n  - black`n  - pre_commit"
Convert-UTF ".\env\export.yaml" $StrConda 
conda env update --prefix ".env/" --file "env/export.yaml"
while (!(Test-Path -Path ".\.env\")) {
    Write-Output "waiting for environment creation"
    Start-Sleep -Seconds 0.25
}
conda activate ./.env
conda env export > env/backup.yaml
# add pre-commit hooks
$StrBlack = "# See https://pre-commit.com for more information
# See https://pre-commit.com/hooks.html for more hooks
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v3.2.0
    hooks:
    -   id: trailing-whitespace
    -   id: check-added-large-files
-   repo: https://github.com/psf/black
    rev: 21.12b0
    hooks:
    -   id: black
"
Convert-UTF ".\.pre-commit-config.yaml" $StrBlack  
pre-commit install
# git add and commit
git add .
git commit -m "Start"
