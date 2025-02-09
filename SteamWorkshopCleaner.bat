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
:: ��ϵ��ʽ��
:: Website: https://github.com/skxxxkx666

@echo off
setlocal enabledelayedexpansion

:: У����ƣ����ű���ͷ�Ƿ������Ȩ����
findstr /i "Copyright (c) 2025 skxxxkx666" "%~f0" >nul
if %errorlevel% neq 0 (
    echo �˽ű��ѱ��۸ģ���ӹٷ�������ȡԭʼ�汾��
    pause
    exit /b
)

:: ���Steam�Ƿ���������
tasklist | findstr /i "steam.exe" >nul
if %errorlevel%==0 (
    echo ��⵽Steam�ͻ����������У�
    echo Ϊ�˱����ļ���ռ�ã����ȹر�Steam�ͻ��ˡ�
    echo.
    echo �Ƿ�Ҫǿ����ֹSteam�ͻ��ˣ�^(Y/N^)
    set /p KillSteam=
    
    if /i "%KillSteam%"=="Y" (
        echo ������ֹSteam�ͻ��˼�����ؽ���...
        
        :: ��ֹSteam������
        taskkill /f /im steam.exe >nul 2>&1
        if %errorlevel%==0 (
            echo Steam�������ѳɹ���ֹ��
        ) else (
            echo ��ֹSteam������ʧ�ܣ����ֶ��رպ����ԣ�
        )
        
        :: ��ֹSteam����ӽ���
        taskkill /f /im steamwebhelper.exe >nul 2>&1
        taskkill /f /im steamservice.exe >nul 2>&1
        taskkill /f /im steamerrorreporter.exe >nul 2>&1
        
        echo �ѳ�����ֹ����Steam��ؽ��̡�
        echo ����������⣬���ֶ��ر�Steam�ͻ��ˡ�
        pause
        exit /b
    ) else (
        echo ���ֶ��ر�Steam�ͻ��˺��������нű���
        pause
        exit /b
    )
)

:: �Զ���ȡSteam��װ·��
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Valve\Steam" /v "InstallPath" 2^>nul') do (
    set "SteamPath=%%b"
)

:: ���δ�ҵ�Steam·�������Դ�32λע����в���
if not defined SteamPath (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Valve\Steam" /v "InstallPath" 2^>nul') do (
        set "SteamPath=%%b"
    )
)

:: ����Ƿ�ɹ��ҵ�Steam·��
if not defined SteamPath (
    echo �޷��Զ��ҵ�Steam��װ·�������ֶ���鲢�޸Ľű���
    pause
    exit /b
)

:: ���ù���Ŀ¼
set "ContentDir=%SteamPath%\steamapps\workshop\content\730"
set "AcfFile=%SteamPath%\steamapps\workshop\appworkshop_730.acf"

:: ���contentĿ¼�Ƿ����
if not exist "%ContentDir%" (
    echo δ�ҵ����⹤������Ŀ¼����ȷ��·���Ƿ���ȷ��
    pause
    exit /b
)

:: ���acf�ļ��Ƿ����
if not exist "%AcfFile%" (
    echo δ�ҵ�appworkshop_730.acf�ļ�����ȷ��·���Ƿ���ȷ��
    pause
    exit /b
)

:: �Զ��г����е�ͼ��ź�����
echo ����ɨ���ͼ�б����Ժ�...
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
                echo [!MapCount!] ���: !FolderName! ����: %%a
                set "MapList[!MapCount!]=!FolderName!"
            )
        )
    ) else (
        if exist "!PreviewImage!" (
            echo [!MapCount!] ���: !FolderName! ���ޱ�����Ϣ������Ԥ��ͼƬ��
        ) else (
            echo [!MapCount!] ���: !FolderName! ���ޱ�����Ϣ����Ԥ��ͼƬ��
        )
        set "MapList[!MapCount!]=!FolderName!"
    )
)

:: ���û���ҵ��κε�ͼ
if %MapCount%==0 (
    echo δ�ҵ��κε�ͼ�ļ��У�
    pause
    exit /b
)

:: ��ʾ�û�ѡ�����
:SelectAction
echo.
echo ��ѡ�������
echo 1. ��������ͼ
echo 2. �������е�ͼ
echo 3. �鿴��ͼ���飨Ԥ��ͼƬ���⹤��ҳ�棩
echo 0. ȡ������
set /p ActionChoice=

:: ��������Ƿ�Ϊ�ջ���Ч
if "%ActionChoice%"=="" (
    echo ������Ч�����������룡
    goto SelectAction
)

if "%ActionChoice%"=="0" (
    echo ������ȡ����
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

echo ������Ч�����������룡
goto SelectAction

:: ��������ͼ
:CleanSingleMap
echo.
echo ������Ҫ����ĵ�ͼ��ţ����磺1, 2, 3...���������� 0 ȡ��������
set /p MapIndex=

:: ��������Ƿ�Ϊ�ջ���Ч
if "%MapIndex%"=="" (
    echo ������Ч�����������룡
    goto CleanSingleMap
)

if "%MapIndex%"=="0" (
    echo ������ȡ����
    pause
    exit /b
)

:: ��������Ƿ񳬳���Χ
if %MapIndex% lss 1 if %MapIndex% gtr %MapCount% (
    echo ����������Ч�����������룡
    goto CleanSingleMap
)

:: ��ȡ�û�ѡ��ĵ�ͼ���
for /f "tokens=2 delims==" %%a in ('set MapList[%MapIndex%]') do (
    set "MapID=%%a"
)

:: ɾ����ͼ�ļ���
echo ����ɾ����ͼ�ļ��У�%ContentDir%\%MapID%
rmdir /s /q "%ContentDir%\%MapID%"
if errorlevel 1 (
    echo ɾ����ͼ�ļ���ʧ�ܣ�����Ȩ�޻��ļ��Ƿ�ռ�ã�
    pause
    exit /b
)

:: ɾ��acf�ļ��е�����ֶ�
echo ��������acf�ļ��е�����ֶ�...
(
    findstr /v /c:"\"%MapID%\"" "%AcfFile%"
) > "%AcfFile%.tmp"
move /y "%AcfFile%.tmp" "%AcfFile%" >nul
if errorlevel 1 (
    echo ����acf�ļ�ʧ�ܣ�����Ȩ�޻��ļ��Ƿ�ռ�ã�
    pause
    exit /b
)

echo ��ͼ��� %MapID% �ѳɹ�����
pause
exit /b

:: �������е�ͼ
:CleanAllMaps
echo.
echo ���棺�˲������������е�ͼ�ļ��к���ؼ�¼��
echo �Ƿ������^(Y/N^)
set /p Confirm=

if /i "%Confirm%"=="Y" (
    echo �����������е�ͼ�ļ���...
    for /d %%i in ("%ContentDir%\*") do (
        set "FolderName=%%~nxi"
        echo ����ɾ����ͼ�ļ��У�%%i
        rmdir /s /q "%%i"
        if errorlevel 1 (
            echo ɾ����ͼ�ļ��� %%i ʧ�ܣ�����Ȩ�޻��ļ��Ƿ�ռ�ã�
        )
    )

    echo ��������acf�ļ��е���������ֶ�...
    (
        findstr /v /r /c:"\"[0-9][0-9]*\"" "%AcfFile%"
    ) > "%AcfFile%.tmp"
    move /y "%AcfFile%.tmp" "%AcfFile%" >nul
    if errorlevel 1 (
        echo ����acf�ļ�ʧ�ܣ�����Ȩ�޻��ļ��Ƿ�ռ�ã�
        pause
        exit /b
    )

    echo ���е�ͼ�ѳɹ�����
    pause
    exit /b
)

if /i "%Confirm%"=="N" (
    echo ������ȡ����
    pause
    exit /b
)

echo ������Ч�����������룡
goto CleanAllMaps

:: �鿴��ͼ����
:ViewMapDetails
echo.
echo ������Ҫ�鿴�ĵ�ͼ��ţ����磺1, 2, 3...���������� 0 ���أ�
set /p MapIndex=

:: ��������Ƿ�Ϊ�ջ���Ч
if "%MapIndex%"=="" (
    echo ������Ч�����������룡
    goto ViewMapDetails
)

if "%MapIndex%"=="0" (
    goto SelectAction
)

:: ��������Ƿ񳬳���Χ
if %MapIndex% lss 1 if %MapIndex% gtr %MapCount% (
    echo ����������Ч�����������룡
    goto ViewMapDetails
)

:: ��ȡ�û�ѡ��ĵ�ͼ���
for /f "tokens=2 delims==" %%a in ('set MapList[%MapIndex%]') do (
    set "MapID=%%a"
)

:: ����Ƿ���Ԥ��ͼƬ
set "PreviewImage=%ContentDir%\%MapID%\preview.jpg"
if exist "%PreviewImage%" (
    echo ���ڴ�Ԥ��ͼƬ...
    start "" "%PreviewImage%"
) else (
    echo �õ�ͼû��Ԥ��ͼƬ��
)

:: �ṩ��ת�����⹤��ҳ���ѡ��
echo �Ƿ�Ҫ��ת���õ�ͼ�Ĵ��⹤��ҳ�棿(Y/N)
set /p OpenWorkshop=
if /i "%OpenWorkshop%"=="Y" (
    echo ������ת�����⹤��ҳ��...
    start https://steamcommunity.com/sharedfiles/filedetails/?id=%MapID%
)

goto ViewMapDetails