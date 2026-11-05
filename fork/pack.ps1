<#
.SYNOPSIS
    Packs this branch (integration) as Avalonia.AvaloniaEdit <BaseVersion>-fork.<N> into a folder feed.

.DESCRIPTION
    N is the commit count of the branch, so every new commit (a merged topic branch, an upstream merge) packs a
    higher version. The working tree must be clean, so a package always matches a commit.

.PARAMETER Output
    The folder feed to pack into.

.PARAMETER BaseVersion
    The next upstream version: 12.0.1 while upstream's last release is 12.0.0. Raise it after an upstream release,
    so these builds sort above that release.
#>
param(
    [Parameter(Mandatory)][string]$Output,
    [string]$BaseVersion = '12.0.1'
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$branch = git -C $repo rev-parse --abbrev-ref HEAD
if ($branch -ne 'integration') { throw "Pack from the integration branch (this clone is on $branch)." }
if (git -C $repo status --porcelain) { throw 'Commit or discard the changes first: a package must match a commit.' }

$count = git -C $repo rev-list --count HEAD
$version = "$BaseVersion-fork.$count"

git -C $repo submodule update --init
if ($LASTEXITCODE) { throw 'git submodule update failed.' }
New-Item -ItemType Directory -Force $Output | Out-Null
$Output = (Resolve-Path $Output).Path

# Run from outside the clone: its global.json pins one exact SDK, and any .NET 10 or later SDK builds the library.
# ContinuousIntegrationBuild maps source paths to /_/, so no local folder names end up in the package.
Push-Location ([IO.Path]::GetTempPath())
try {
    dotnet pack (Join-Path $repo 'src\AvaloniaEdit\AvaloniaEdit.csproj') -c Release -o $Output `
        "-p:Version=$version" -p:ContinuousIntegrationBuild=true
    if ($LASTEXITCODE) { throw 'dotnet pack failed.' }
}
finally {
    Pop-Location
}

"Packed Avalonia.AvaloniaEdit $version into $Output"
