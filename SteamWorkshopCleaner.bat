:: Copyright (c) 2025 skxxxkx666. All rights reserved.
::
:: MIT License
::
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
::
:: The above copyright notice and this permission notice shall be included in all
:: copies or substantial portions of the Software.
::
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
:: SOFTWARE.
::
:: 联系方式：
:: Website: https://github.com/skxxxkx666

@echo off
setlocal enabledelayedexpansion

:: 校验机制：检查脚本开头是否包含版权声明
findstr /i "Copyright (c) 2025 skxxxkx666" "%~f0" >nul
if %errorlevel% neq 0 (
    echo 此脚本已被篡改，请从官方渠道获取原始版本！
    pause
    exit /b
)

:: 检测Steam是否正在运行
tasklist | findstr /i "steam.exe" >nul
if %errorlevel%==0 (
    echo 检测到Steam客户端正在运行！
    echo 为了避免文件被占用，请先关闭Steam客户端。
    echo.
    echo 是否要强制终止Steam客户端？^(Y/N^)
    set /p KillSteam=
    
    if /i "%KillSteam%"=="Y" (
        echo 正在终止Steam客户端及其相关进程...
        
        :: 终止Steam主进程
        taskkill /f /im steam.exe >nul 2>&1
        if %errorlevel%==0 (
            echo Steam主进程已成功终止。
        ) else (
            echo 终止Steam主进程失败，请手动关闭后再试！
        )
        
        :: 终止Steam相关子进程
        taskkill /f /im steamwebhelper.exe >nul 2>&1
        taskkill /f /im steamservice.exe >nul 2>&1
        taskkill /f /im steamerrorreporter.exe >nul 2>&1
        
        echo 已尝试终止所有Steam相关进程。
        echo 如果仍有问题，请手动关闭Steam客户端。
        pause
        exit /b
    ) else (
        echo 请手动关闭Steam客户端后重新运行脚本。
        pause
        exit /b
    )
)

:: 自动获取Steam安装路径
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Valve\Steam" /v "InstallPath" 2^>nul') do (
    set "SteamPath=%%b"
)

:: 如果未找到Steam路径，尝试从32位注册表中查找
if not defined SteamPath (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Valve\Steam" /v "InstallPath" 2^>nul') do (
        set "SteamPath=%%b"
    )
)

:: 检查是否成功找到Steam路径
if not defined SteamPath (
    echo 无法自动找到Steam安装路径，请手动检查并修改脚本！
    pause
    exit /b
)

:: 设置工作目录
set "ContentDir=%SteamPath%\steamapps\workshop\content\730"
set "AcfFile=%SteamPath%\steamapps\workshop\appworkshop_730.acf"

:: 检查content目录是否存在
if not exist "%ContentDir%" (
    echo 未找到创意工坊内容目录，请确认路径是否正确！
    pause
    exit /b
)

:: 检查acf文件是否存在
if not exist "%AcfFile%" (
    echo 未找到appworkshop_730.acf文件，请确认路径是否正确！
    pause
    exit /b
)

:: 自动列出所有地图编号和名称
echo 正在扫描地图列表，请稍候...
set /a MapCount=0
for /d %%i in ("%ContentDir%\*") do (
    set /a MapCount+=1
    set "FolderName=%%~nxi"
    set "PublishData=%%i\publish_data"
    set "PreviewImage=%%i\preview.jpg"
    
    if exist "!PublishData!" (
        for /f "usebackq tokens=*" %%a in ("!PublishData!") do (
            echo %%a | findstr /i "title" >nul
            if !errorlevel! equ 0 (
                echo [!MapCount!] 编号: !FolderName! 名称: %%a
                set "MapList[!MapCount!]=!FolderName!"
            )
        )
    ) else (
        if exist "!PreviewImage!" (
            echo [!MapCount!] 编号: !FolderName! （无标题信息，但有预览图片）
        ) else (
            echo [!MapCount!] 编号: !FolderName! （无标题信息且无预览图片）
        )
        set "MapList[!MapCount!]=!FolderName!"
    )
)

:: 如果没有找到任何地图
if %MapCount%==0 (
    echo 未找到任何地图文件夹！
    pause
    exit /b
)

:: 提示用户选择操作
:SelectAction
echo.
echo 请选择操作：
echo 1. 清理单个地图
echo 2. 清理所有地图
echo 3. 查看地图详情（预览图片或创意工坊页面）
echo 0. 取消操作
set /p ActionChoice=

:: 检查输入是否为空或无效
if "%ActionChoice%"=="" (
    echo 输入无效，请重新输入！
    goto SelectAction
)

if "%ActionChoice%"=="0" (
    echo 操作已取消。
    pause
    exit /b
)

if "%ActionChoice%"=="1" (
    goto CleanSingleMap
)

if "%ActionChoice%"=="2" (
    goto CleanAllMaps
)

if "%ActionChoice%"=="3" (
    goto ViewMapDetails
)

echo 输入无效，请重新输入！
goto SelectAction

:: 清理单个地图
:CleanSingleMap
echo.
echo 请输入要清理的地图序号（例如：1, 2, 3...），或输入 0 取消操作：
set /p MapIndex=

:: 检查输入是否为空或无效
if "%MapIndex%"=="" (
    echo 输入无效，请重新输入！
    goto CleanSingleMap
)

if "%MapIndex%"=="0" (
    echo 操作已取消。
    pause
    exit /b
)

:: 检查输入是否超出范围
if %MapIndex% lss 1 if %MapIndex% gtr %MapCount% (
    echo 输入的序号无效，请重新输入！
    goto CleanSingleMap
)

:: 获取用户选择的地图编号
for /f "tokens=2 delims==" %%a in ('set MapList[%MapIndex%]') do (
    set "MapID=%%a"
)

:: 删除地图文件夹
echo 正在删除地图文件夹：%ContentDir%\%MapID%
rmdir /s /q "%ContentDir%\%MapID%"
if errorlevel 1 (
    echo 删除地图文件夹失败，请检查权限或文件是否被占用！
    pause
    exit /b
)

:: 删除acf文件中的相关字段
echo 正在清理acf文件中的相关字段...
(
    findstr /v /c:"\"%MapID%\"" "%AcfFile%"
) > "%AcfFile%.tmp"
move /y "%AcfFile%.tmp" "%AcfFile%" >nul
if errorlevel 1 (
    echo 清理acf文件失败，请检查权限或文件是否被占用！
    pause
    exit /b
)

echo 地图编号 %MapID% 已成功清理！
pause
exit /b

:: 清理所有地图
:CleanAllMaps
echo.
echo 警告：此操作将清理所有地图文件夹和相关记录！
echo 是否继续？^(Y/N^)
set /p Confirm=

if /i "%Confirm%"=="Y" (
    echo 正在清理所有地图文件夹...
    for /d %%i in ("%ContentDir%\*") do (
        set "FolderName=%%~nxi"
        echo 正在删除地图文件夹：%%i
        rmdir /s /q "%%i"
        if errorlevel 1 (
            echo 删除地图文件夹 %%i 失败，请检查权限或文件是否被占用！
        )
    )

    echo 正在清理acf文件中的所有相关字段...
    (
        findstr /v /r /c:"\"[0-9][0-9]*\"" "%AcfFile%"
    ) > "%AcfFile%.tmp"
    move /y "%AcfFile%.tmp" "%AcfFile%" >nul
    if errorlevel 1 (
        echo 清理acf文件失败，请检查权限或文件是否被占用！
        pause
        exit /b
    )

    echo 所有地图已成功清理！
    pause
    exit /b
)

if /i "%Confirm%"=="N" (
    echo 操作已取消。
    pause
    exit /b
)

echo 输入无效，请重新输入！
goto CleanAllMaps

:: 查看地图详情
:ViewMapDetails
echo.
echo 请输入要查看的地图序号（例如：1, 2, 3...），或输入 0 返回：
set /p MapIndex=

:: 检查输入是否为空或无效
if "%MapIndex%"=="" (
    echo 输入无效，请重新输入！
    goto ViewMapDetails
)

if "%MapIndex%"=="0" (
    goto SelectAction
)

:: 检查输入是否超出范围
if %MapIndex% lss 1 if %MapIndex% gtr %MapCount% (
    echo 输入的序号无效，请重新输入！
    goto ViewMapDetails
)

:: 获取用户选择的地图编号
for /f "tokens=2 delims==" %%a in ('set MapList[%MapIndex%]') do (
    set "MapID=%%a"
)

:: 检查是否有预览图片
set "PreviewImage=%ContentDir%\%MapID%\preview.jpg"
if exist "%PreviewImage%" (
    echo 正在打开预览图片...
    start "" "%PreviewImage%"
) else (
    echo 该地图没有预览图片。
)

:: 提供跳转到创意工坊页面的选项
echo 是否要跳转到该地图的创意工坊页面？(Y/N)
set /p OpenWorkshop=
if /i "%OpenWorkshop%"=="Y" (
    echo 正在跳转到创意工坊页面...
    start https://steamcommunity.com/sharedfiles/filedetails/?id=%MapID%
)

goto ViewMapDetails