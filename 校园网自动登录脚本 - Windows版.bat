@echo off
chcp 936 >nul
setlocal enabledelayedexpansion

:: У԰����¼�ű� - Windows��.bat
:: ��Ȩ���� (c) 2025 JM14128
:: ������ʹ�� GNU ͨ�ù������֤�����棨GPL-3.0����Ȩ������
:: ����������ʹ�á����ơ��޸ĺͷַ����ű���
:: �����뱣������Ȩ���������֤��Ϣ����ֹδ����Ȩ����ҵ��;��

echo.
echo �X�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�[
echo �U            У԰����¼�ű� - Windows��                �U
echo �U    ��Ȩ���� (c) 2025 JM14128������ѧϰ����ʹ�á�     �U
echo �U       ��ֹδ����Ȩ����ҵ��;��Υ���Ը��������Ρ�     �U
echo �^�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�a
echo.

title У԰����¼�ű�

setlocal enabledelayedexpansion

set "user_file=users.txt"
set "pw_file=enc.txt"
set "last_file=last_user.txt"

:: �ȼ���Ƿ��������ж��ѵ�¼��
echo ���ڼ������״̬...
ping www.baidu.com -n 1 >nul
if %errorlevel%==0 (
    echo ��ǰ������У԰���������¼��
    echo.
    echo �����س����˳�����...��
    pause >nul
    exit /b
)

echo [δ��¼] ��⵽����δ���ӣ�׼����¼У԰��...
echo.

:: ����ʱ�Զ�ʹ���ϴ�����
if exist %last_file% (
    set /p last_user=<%last_file%
    echo ���� 5 �����Զ�ʹ���ϴ����� [%last_user%] ��¼���������ȡ��������˵�...
    choice /t 5 /d Y /n >nul
    if errorlevel 2 (
        goto main_menu
    )
    set "target_user="
    for /f "tokens=1,2,3 delims=," %%a in (%user_file%) do (
        set "line=%%a,%%b,%%c"
        if "%%a"=="%last_user%" set "target_user=!line!"
    )
    if defined target_user (
        for /f "tokens=1,2,3 delims=," %%a in ("!target_user!") do (
            set "user=%%a"
            set "operator=%%b"
            set "encpass=%%c"
        )
        goto login
    ) else (
        echo �ϴ��û���¼��Ч������˵�...
        pause
        goto main_menu
    )
)

:main_menu
cls
echo ===== У԰�����û���¼ϵͳ =====
if not exist %user_file% (
    echo [��ʾ] ��ǰ���κ��˻�������ӣ�
    goto add_user
)

:: �г��û�
set /a idx=0
for /f "tokens=1,2,3 delims=," %%a in (%user_file%) do (
    set /a idx+=1
    echo  !idx!. ѧ�ţ�%%a  ��Ӫ�̣�%%b
    set "user[!idx!]=%%a,%%b,%%c"
)

echo.
echo ��������ѡ���¼�˻�
echo N = �½��û�    D = ɾ���û�    Q = �˳�
set /p choice=���ѡ��

if /i "%choice%"=="N" goto add_user
if /i "%choice%"=="D" goto delete_user
if /i "%choice%"=="Q" exit

:: �û�ѡ���¼
set /a num_choice=%choice% 2>nul
if "!user[%num_choice%]!"=="" (
    echo ��Чѡ��
    pause
    goto main_menu
)

for /f "tokens=1,2,3 delims=," %%a in ("!user[%num_choice%]!") do (
    set "user=%%a"
    set "operator=%%b"
    set "encpass=%%c"
)

:: �����ϴ��û�
echo %user% > %last_file%

:login
cls
echo ���ڵ�¼ %user%%operator%...

:: ��������
echo %encpass% > %pw_file%
certutil -decode %pw_file% decoded_pw.txt >nul
set /p password=<decoded_pw.txt
del %pw_file% >nul
del decoded_pw.txt >nul

set "account=%user%%operator%"
curl -s "http://10.1.99.100:801/eportal/portal/login?callback=dr1003&login_method=1&user_account=,1,%account%&user_password=%password%&wlan_user_ip=&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1.3&terminal_type=1&lang=zh-cn&v=6727&lang=zh" > result.txt

set "result="
for /f "usebackq tokens=* delims=" %%r in ("result.txt") do set "result=%%r"
echo %result% | find /i "success" >nul
if %errorlevel%==0 (
    echo ��¼�ɹ���
) else (
    echo ��¼ʧ�ܣ������˺Ż����磡
)
del result.txt
echo.
echo �����س������ز˵�...��
pause >nul
goto main_menu

:add_user
echo.
set /p user=������ѧ�ţ�

echo ��ѡ����Ӫ�̣�
echo   1. ��ͨ
echo   2. �ƶ�
echo   3. ����
echo   4. ����ѧԺ
set /p op_choice=���������֣�

if "%op_choice%"=="1" set "operator=@unicom"
if "%op_choice%"=="2" set "operator=@cmcc"
if "%op_choice%"=="3" set "operator=@telecom"
if "%op_choice%"=="4" set "operator="

set /p password=���������룺

:: ��������
echo %password% > pw_raw.txt
certutil -encode pw_raw.txt pw_enc.txt >nul
set "encpass="
for /f "skip=1 tokens=* delims=" %%p in (pw_enc.txt) do (
    if not defined encpass set "encpass=%%p"
)
del pw_raw.txt >nul
del pw_enc.txt >nul

:: �����û�
echo %user%,%operator%,%encpass%>>%user_file%
echo [�û�����ӳɹ���]
pause
goto main_menu

:delete_user
cls
echo [ɾ���û�]
set /a idx=0
for /f "tokens=1,2,3 delims=," %%a in (%user_file%) do (
    set /a idx+=1
    echo   !idx!. ѧ�ţ�%%a  ��Ӫ�̣�%%b
    set "user[!idx!]=%%a,%%b,%%c"
)

echo.
set /p del_idx=������ɾ����

if "!user[%del_idx%]!"=="" (
    echo �����Ч
    pause
    goto main_menu
)

:: ɾ���������ļ�
set /a line=0
> tmp.txt (
    for /f "tokens=1,2,3 delims=," %%a in (%user_file%) do (
        set /a line+=1
        if not "!line!"=="%del_idx%" echo %%a,%%b,%%c
    )
)
move /y tmp.txt %user_file% >nul
echo ��ɾ���� %del_idx% ���û�
pause
goto main_menu
