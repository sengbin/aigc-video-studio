# 构建 VS Code 扩展；正式打包时将用户手册 Skill 一并打包。
param(
    [switch]$CompileOnly
)

$ErrorActionPreference = 'Stop'
$manualSkillDirectory = Join-Path $PSScriptRoot 'docs\aigc-video-studio-user-manual'
$manualSkillArchive = Join-Path $PSScriptRoot 'resources\aigc-video-studio-user-manual.zip'

Push-Location $PSScriptRoot
try {
    npm install
    if ($LASTEXITCODE -ne 0) {
        throw "依赖安装失败，退出代码：$LASTEXITCODE。"
    }

    $generatedDirectories = @('out')
    foreach ($directory in $generatedDirectories) {
        $directoryPath = Join-Path $PSScriptRoot $directory
        if (Test-Path -LiteralPath $directoryPath) {
            Remove-Item -LiteralPath $directoryPath -Recurse -Force
        }
    }

    Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.vsix' -File |
        Remove-Item -Force

    if ($CompileOnly) {
        npm run compile
        if ($LASTEXITCODE -ne 0) {
            throw "编译失败，退出代码：$LASTEXITCODE。"
        }
    }
    else {
        $manualSkillFile = Join-Path $manualSkillDirectory 'SKILL.md'
        if (-not (Test-Path -LiteralPath $manualSkillFile -PathType Leaf)) {
            throw "未找到用户使用手册 Skill 文件：$manualSkillFile"
        }

        # docs 会被扩展忽略，因此将 Skill 内容压缩到会随扩展打包的 resources 目录。
        Compress-Archive -Path (Join-Path $manualSkillDirectory '*') -DestinationPath $manualSkillArchive -Force

        npm run package
        if ($LASTEXITCODE -ne 0) {
            throw "扩展打包失败，退出代码：$LASTEXITCODE。"
        }
    }

}
finally {
    Pop-Location
}