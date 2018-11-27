@echo off

setlocal enabledelayedexpansion

set "home=%~dp0"
set "patcher=%home%\xdelta.exe"
set "patch=%home%\diffs"

set md5.v9.steam.ronin=805f8cc409a98ed97144f79f9caafbe5
set md5.v9.steam.data=8fbcb0bc91ce203aec5725b2d4da6142
set md5.v8.gog.ronin=ffcd651454cbcf7a274b4008f3f11b89
set md5.v8.gog.data=6aa4da645344d852b6ca63b8dc686a3b

if "%~1" == "" (
	echo.No arguments provided! Please drag your RONIN folder onto this batch file.
	pause > nul
	echo.
	exit /b
)





echo.
echo.:::: RONIN v.9 to GOG v.8 Downgrader
echo.::

call :findFiles "%1\ronin.exe","%1\data.win","%patch%\xdelta.exe","%patch%\ronin.xdelta","%patch%\data.xdelta"

call :patch "%~1\ronin.exe"
call :patch "%~1\data.win"

echo.::
echo.:: Finished
echo.::
echo.::::

pause > nul

echo.

exit /b



:findFiles

echo.:: Finding files...

for /f "tokens=1* delims=," %%a in ("%*") do (
	if not exist %%a (
		echo.::
		echo.::::
		echo.
		echo.Couldn't find %%a! Aborting patch
		pause > nul
		echo.
		exit /b
	)
)

goto:eof




:getMD5

set n=0

for /f "tokens=1* delims=" %%a in ('certutil -hashfile "%~1" MD5') do (
	if !n! == 1 set "r=%%a"
	set /a n+=1
)

set %2=%r: =%

goto:eof




:patch

call :getFileVersion "%~1" version

if "!version!" == "steam_v9" (
	echo.:: Patching %~nx1...
	"%patcher%" -d -s "%~1" "%patch%\%~n1_!version!.xdelta" "%home%\%~nx1"
	move /y "%home%\%~nx1" "%1" > nul
	goto:eof
)

if "!version!" == "gog_v8" (
	echo.:: Skipping %~nx1, already GOG v8...
	goto:eof
)

if "!version!" == "unknown" (
	echo.:: Skipping %~nx1, can't determine version...
	goto:eof
)

goto:eof




:getFileVersion

call :getMD5 "%~1" md5

set "%2=unknown"

if /i "%~n1" == "ronin" (
	if "!md5!" == "%md5.v9.steam.ronin%" set "%2=steam_v9"
	if "!md5!" == "%md5.v8.gog.ronin%" set "%2=gog_v8"
	goto:eof
)

if /i "%~n1" == "data" (
	if "!md5!" == "%md5.v9.steam.data%" set "%2=steam_v9"
	if "!md5!" == "%md5.v8.gog.data%" set "%2=gog_v8"
	goto:eof
)

set "%2=error"

goto:eof