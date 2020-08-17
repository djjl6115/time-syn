@echo off
rem 간단하게 타임서버와 동기화 설정을 수행합니다.
rem 오늘은 git을 이용해서 추가했음
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
rem w32time 서비스 시작
net start w32time 

rem 부팅시 자동시작
sc triggerinfo w32time start/networkon stop/networkoff
if '%errorlevel%' NEQ '0' ( 
	echo fail2
	goto fail
)

rem 시간동기화 서버 설정 업데이트
echo 1번과 2번 중 설정하세요
set /p hong=번호 선택 
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
rem 시간동기화 실시
w32tm /resync

rem 최종 조건문 실행
if '%errorlevel%' NEQ '0' ( 
	echo fail4
	goto fail
) else ( goto success ) 

:success

echo time sync success
w32tm /query /status | findstr 정밀도
pause
exit

:fail
echo time sync fail
pause
exit
