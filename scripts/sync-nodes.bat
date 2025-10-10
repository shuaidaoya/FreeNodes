@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: FreeNodes - 节点同步脚本 (Windows版本)
:: 用于手动同步Gist中的节点文件到本地仓库

echo 🚀 FreeNodes 节点同步脚本 (Windows)
echo ================================

:: 检查curl是否可用
curl --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: curl 命令未找到，请先安装 curl
    echo 💡 提示: Windows 10/11 通常已内置 curl
    pause
    exit /b 1
)

:: 配置变量
set "GIST_BASE_URL=https://gist.githubusercontent.com/shuaidaoya/9e5cf2749c0ce79932dd9229d9b4162b/raw/45a4616a347cf5998fd9ef83d41d8a91ff314bc6"
set "NODES_DIR=nodes"

:: 创建节点目录
echo 📁 创建节点目录...
if not exist "%NODES_DIR%" mkdir "%NODES_DIR%"
echo ✅ 节点目录创建完成: %NODES_DIR%

:: 下载文件函数
echo.
echo 📥 开始下载节点文件...

:: 下载 all.yaml
echo 正在下载 all.yaml (完整 YAML 配置)...
curl -fsSL "%GIST_BASE_URL%/all.yaml" -o "%NODES_DIR%/all.yaml"
if errorlevel 1 (
    echo ❌ all.yaml 下载失败
) else (
    echo ✅ all.yaml 下载成功
)

:: 下载 base64.txt
echo 正在下载 base64.txt (Base64 编码列表)...
curl -fsSL "%GIST_BASE_URL%/base64.txt" -o "%NODES_DIR%/base64.txt"
if errorlevel 1 (
    echo ❌ base64.txt 下载失败
) else (
    echo ✅ base64.txt 下载成功
)

:: 下载 history.yaml
echo 正在下载 history.yaml (历史节点记录)...
curl -fsSL "%GIST_BASE_URL%/history.yaml" -o "%NODES_DIR%/history.yaml"
if errorlevel 1 (
    echo ❌ history.yaml 下载失败
) else (
    echo ✅ history.yaml 下载成功
)

:: 下载 mihomo.yaml
echo 正在下载 mihomo.yaml (Mihomo 专用配置)...
curl -fsSL "%GIST_BASE_URL%/mihomo.yaml" -o "%NODES_DIR%/mihomo.yaml"
if errorlevel 1 (
    echo ❌ mihomo.yaml 下载失败
) else (
    echo ✅ mihomo.yaml 下载成功
)

:: 统计节点数量
echo.
echo 📊 统计节点数量...
set "total_nodes=0"

if exist "%NODES_DIR%/all.yaml" (
    for /f %%i in ('findstr /c:"server:" "%NODES_DIR%/all.yaml" 2^>nul ^| find /c /v ""') do set "yaml_nodes=%%i"
    if not defined yaml_nodes set "yaml_nodes=0"
    set /a "total_nodes+=yaml_nodes"
    echo YAML 格式节点: !yaml_nodes! 个
)

if exist "%NODES_DIR%/base64.txt" (
    for /f %%i in ('find /c /v "" "%NODES_DIR%/base64.txt" 2^>nul') do set "base64_lines=%%i"
    if not defined base64_lines set "base64_lines=0"
    echo Base64 格式行数: !base64_lines! 行
)

:: 生成文件信息
echo.
echo 📝 生成文件信息...
set "readme_file=%NODES_DIR%/README.md"

echo # 📊 节点文件信息 > "%readme_file%"
echo. >> "%readme_file%"
echo **更新时间**: %date% %time% >> "%readme_file%"
echo. >> "%readme_file%"
echo ^| 文件名 ^| 描述 ^| 大小 ^| 状态 ^| >> "%readme_file%"
echo ^|--------^|------^|------^|------^| >> "%readme_file%"

:: 检查文件并添加到README
if exist "%NODES_DIR%/all.yaml" (
    for %%F in ("%NODES_DIR%/all.yaml") do set "size=%%~zF"
    echo ^| all.yaml ^| 完整 YAML 配置 ^| !size! bytes ^| ✅ 可用 ^| >> "%readme_file%"
)

if exist "%NODES_DIR%/base64.txt" (
    for %%F in ("%NODES_DIR%/base64.txt") do set "size=%%~zF"
    echo ^| base64.txt ^| Base64 编码列表 ^| !size! bytes ^| ✅ 可用 ^| >> "%readme_file%"
)

if exist "%NODES_DIR%/history.yaml" (
    for %%F in ("%NODES_DIR%/history.yaml") do set "size=%%~zF"
    echo ^| history.yaml ^| 历史节点记录 ^| !size! bytes ^| ✅ 可用 ^| >> "%readme_file%"
)

if exist "%NODES_DIR%/mihomo.yaml" (
    for %%F in ("%NODES_DIR%/mihomo.yaml") do set "size=%%~zF"
    echo ^| mihomo.yaml ^| Mihomo 专用配置 ^| !size! bytes ^| ✅ 可用 ^| >> "%readme_file%"
)

echo. >> "%readme_file%"
echo ^> 🔄 文件每日自动更新，确保节点的新鲜度和可用性 >> "%readme_file%"
echo ^> >> "%readme_file%"
echo ^> 📡 订阅链接请参考主 README.md 文件 >> "%readme_file%"

:: 显示结果
echo.
echo ================================
echo 🎉 节点同步完成！
echo 📊 节点总数: %total_nodes% 个
echo 📁 文件位置: %NODES_DIR%\
echo 📝 文件信息: %readme_file%
echo ================================
echo.
echo 💡 提示: 
echo    - 文件已保存到 %NODES_DIR% 目录
echo    - 可以直接使用这些文件或通过订阅链接使用
echo    - 如需最新文件，请重新运行此脚本
echo.

pause