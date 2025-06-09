@echo off
chcp 936 >nul
setlocal enabledelayedexpansion

:: 校园网登录脚本 - Windows版.bat
:: 版权所有 (c) 2025 JM14128
:: 本程序使用 GNU 通用公共许可证第三版（GPL-3.0）授权发布。
:: 您可以自由使用、复制、修改和分发本脚本，
:: 但必须保留本版权声明和许可证信息，禁止未经授权的商业用途。

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║            校园网登录脚本 - Windows版                ║
echo ║    版权所有 (c) 2025 JM14128。仅供学习交流使用。     ║
echo ║       禁止未经授权的商业用途，违者自负法律责任。     ║
echo ╚══════════════════════════════════════════════════════╝
echo.

title 校园网登录脚本

setlocal enabledelayedexpansion

set "user_file=users.txt"
set "pw_file=enc.txt"
set "last_file=last_user.txt"

:: 先检测是否联网（判断已登录）
echo 正在检测网络状态...
curl -s --head --connect-timeout 3 http://www.baidu.com | findstr /r /c:"HTTP/[0-9]\.[0-9] 200" >nul
if %errorlevel%==0 (
    echo 当前已连接校园网，无需登录！
    echo.
    echo 【按回车键退出程序...】
    pause >nul
    exit /b
)


echo [未登录] 检测到网络未连接，准备登录校园网...
echo.


:: 读取上次登录用户
if exist "%last_file%" (
    set /p last_user=<"%last_file%"
    echo 将在 5 秒内自动使用上次配置 [%last_user%] 登录，按Y立即登录，按N取消并进入菜单...
    choice /t 5 /d Y /n >nul
    if errorlevel 2 goto main_menu

    set "target_user="
    for /f "tokens=1,2,3 delims=," %%a in (%user_file%) do (
        if "%%a"=="%last_user%" set "target_user=%%a,%%b,%%c"
    )
    if defined target_user (
        for /f "tokens=1,2,3 delims=," %%a in ("!target_user!") do (
            set "user=%%a"
            set "operator=%%b"
            set "encpass=%%c"
        )
        goto login
    ) else (
        echo 上次用户记录无效，进入菜单...
        pause
        goto main_menu
    )
)


:main_menu
cls
echo ===== 校园网多用户登录系统 =====
if not exist %user_file% (
    echo [提示] 当前无任何账户，请添加：
    goto add_user
)

:: 列出用户
set /a idx=0
for /f "tokens=1,2,3 delims=," %%a in (%user_file%) do (
    set /a idx+=1
    set "show_operator=%%b"
    if "%%b"=="@unicom" set "show_operator=中国联通"
    if "%%b"=="@cmcc" set "show_operator=中国移动"
    if "%%b"=="@telecom" set "show_operator=中国电信"
    if "%%b"=="" set "show_operator=无锡学院"
    echo  !idx!. 学号：%%a  运营商：!show_operator!
    set "user[!idx!]=%%a,%%b,%%c"
)

echo.
echo 输入数字选择登录账户
echo N = 新建用户    D = 删除用户    Q = 退出
set /p choice=你的选择：

if /i "%choice%"=="N" goto add_user
if /i "%choice%"=="D" goto delete_user
if /i "%choice%"=="Q" exit

:: 用户选择登录
set /a num_choice=%choice% 2>nul
if "!user[%num_choice%]!"=="" (
    echo 无效选择
    pause
    goto main_menu
)

for /f "tokens=1,2,3 delims=," %%a in ("!user[%num_choice%]!") do (
    set "user=%%a"
    set "operator=%%b"
    set "encpass=%%c"
)

:: 保存上次用户
echo %user% > %last_file%

:login
:: 转换运营商为中文名
set "show_operator=%operator%"
if "%operator%"=="@unicom" set "show_operator=中国联通"
if "%operator%"=="@cmcc" set "show_operator=中国移动"
if "%operator%"=="@telecom" set "show_operator=中国电信"
if "%operator%"=="" set "show_operator=无锡学院"

cls
echo 正在登录 %user%（%show_operator%）...

:: 解密密码
echo %encpass% > %pw_file%
certutil -decode %pw_file% decoded_pw.txt >nul

:: 使用 PowerShell 去掉所有换行和空格
for /f "delims=" %%p in ('powershell -nologo -command "Get-Content decoded_pw.txt | Select-Object -First 1 | ForEach-Object { $_.Trim() }"') do (
    set "password=%%p"
)
del %pw_file% >nul
del decoded_pw.txt >nul


setlocal enabledelayedexpansion

set "account=%user%%operator%"
curl -s "http://10.1.99.100:801/eportal/portal/login?callback=dr1003&login_method=1&user_account=,1,%account%&user_password=%password%&wlan_user_ip=&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1.3&terminal_type=1&lang=zh-cn&v=6727&lang=zh" > result.txt

:: 由 PowerShell 读取 result.txt 判断是否含“协议认证成功”，并打印提示+内容
powershell -Command ^
  "$content = Get-Content -Raw -Path 'result.txt';" ^
  "if ($content -like '*协议认证成功*') {" ^
  "  Write-Host '%user%（%show_operator%） 登录成功！' -ForegroundColor Green;" ^
  "} else {" ^
  "  Write-Host '%user%（%show_operator%） 登录失败，请检查账号或网络！' -ForegroundColor Red;" ^
  "};" ^
  "Write-Host '--- 网关返回内容 ---';" ^
  "Write-Host $content;"

del result.txt

echo.
echo 【按回车键返回菜单...】
pause >nul
goto main_menu


:add_user
echo.
set /p user=请输入学号：

echo 请选择运营商：
echo   1. 中国联通
echo   2. 中国移动
echo   3. 中国电信
echo   4. 无锡学院
set /p op_choice=请输入数字：

if "%op_choice%"=="1" set "operator=@unicom"
if "%op_choice%"=="2" set "operator=@cmcc"
if "%op_choice%"=="3" set "operator=@telecom"
if "%op_choice%"=="4" set "operator="

set /p password=请输入密码：

:: 加密密码
echo %password% > pw_raw.txt
certutil -encode pw_raw.txt pw_enc.txt >nul
set "encpass="
for /f "skip=1 tokens=* delims=" %%p in (pw_enc.txt) do (
    if not defined encpass set "encpass=%%p"
)
del pw_raw.txt >nul
del pw_enc.txt >nul

:: 保存用户
echo %user%,%operator%,%encpass%>>%user_file%
echo [用户已添加成功！]
pause
goto main_menu

:delete_user
cls
echo [删除用户]
set /a idx=0
for /f "tokens=1,2,3 delims=," %%a in (%user_file%) do (
    set /a idx+=1
    echo   !idx!. 学号：%%a  运营商：%%b
    set "user[!idx!]=%%a,%%b,%%c"
)

echo.
set /p del_idx=输入编号删除：

if "!user[%del_idx%]!"=="" (
    echo 编号无效
    pause
    goto main_menu
)

:: 删除并更新文件
set /a line=0
> tmp.txt (
    for /f "tokens=1,2,3 delims=," %%a in (%user_file%) do (
        set /a line+=1
        if not "!line!"=="%del_idx%" echo %%a,%%b,%%c
    )
)
move /y tmp.txt %user_file% >nul
echo 已删除第 %del_idx% 个用户
pause
goto main_menu
