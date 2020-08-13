@echo off
rem
rem 간단하게 타임서버와 동기화 설정을 수행합니다.
rem 오늘은 git을 이용해서 추가했음
@echo Time-sync v0.1 Copyright 2020 Hong-Hyun
@echo Current Time

@echo off
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

rem w32time 서비스 시작
net start w32time 

rem 부팅시 자동시작
sc triggerinfo w32time start /networkon stop /networkoff

rem Enabled 값을 0에서 1로 변경
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32TIME\TimeProviders\NtpServer" /v "Enabled" /t "REG_DWORD" /d "1" /f

rem 시간동기화 서버 설정 업데이트
w32tm /config /manualpeerlist:time.nist.gov,0x8 /syncfromflags:manual /update

rem w32tm 서비스 설정 값 확인
w32tm /dumpreg /subkey:Parameters

rem 시간동기화 실시
w32tm /resync
pause



