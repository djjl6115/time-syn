@echo off
rem �����ϰ� Ÿ�Ӽ����� ����ȭ ������ �����մϴ�.
rem ������ git�� �̿��ؼ� �߰�����
@echo Time-sync v0.1 Copyright 2020 Hong-Hyun

:: BatchGotAdmin 
:------------------------------------- 
REM --> Check for permissions 
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" 
REM --> If error flag set, we do not have admin. 
if '%errorlevel%' NEQ '0' ( 
	echo Requesting administrative privileges... 
	goto UACPrompt 
) else ( goto gotAdmin ) 

:UACPrompt 
	echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs" 
	set params = %*:"="" 
	echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" 

	"%temp%\getadmin.vbs" 
	del "%temp%\getadmin.vbs" 
	exit /B 

:gotAdmin 
	pushd "%CD%" 
	CD /D "%~dp0"

if '%errorlevel%' NEQ '0' ( 
	echo fail reg
	goto fail
)
rem w32time ���� ����
net start w32time 

rem ���ý� �ڵ�����
sc triggerinfo w32time start/networkon stop/networkoff
if '%errorlevel%' NEQ '0' ( 
	echo fail2
	goto fail
)

rem �ð�����ȭ ���� ���� ������Ʈ
echo 1���� 2�� �� �����ϼ���
set /p hong=��ȣ ���� 
if '%hong%' == '1' (
	set abc=time.bora.net
	pause
)
if '%hong%' == '2' (
	set abc=time.nist.gov
	pause
)

w32tm /config /manualpeerlist:%abc% /syncfromflags:manual /update
if '%errorlevel%' NEQ '0' ( 
	echo fail3
	goto fail
)
rem �ð�����ȭ �ǽ�
w32tm /resync

rem ���� ���ǹ� ����
if '%errorlevel%' NEQ '0' ( 
	echo fail4
	goto fail
) else ( goto success ) 

:success

echo time sync success
w32tm /query /status | findstr ���е�
pause
exit

:fail
echo time sync fail
pause
exit
