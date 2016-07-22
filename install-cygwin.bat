@echo off

rem Set CYGWIN_BASE variable to the installation directory.
rem cygwin-installer default is C:\Users\<username>\cygwin
rem cygwin.com setup default is C:\cygwin64 {or C:\cygwin32}
rem set CYGWIN_BASE=%USERPROFILE%\cygwin
set CYGWIN_BASE=C:\cygwin64

rem Set CPU - x86 for 32-bit Cygwin, or x86_64 for 64-bit Cygwin
set CPU=x86_64

rem cygwin_install.exe settings and packages for install
rem format of command is setup-%CPU% %CYGWIN_OPTIONS% %SITE% %PACKAGES% 
set CYGWIN_OPTIONS=--no-admin --root %CYGWIN_BASE% --quiet-mode --no-shortcuts 
set SITE=--site ftp://mirror.switch.ch/mirror/cygwin/ 
set PACKAGES=--categories Base -l %CYGWIN_BASE%\var\cache\apt\packages 
set PACKAGES=%PACKAGES% --packages dos2unix,ncurses,wget,gcc-g++,make,vim,git

rem---------------------------------
rem No changes needed past this point!

if not exist %CYGWIN_BASE% goto install
   echo The directory %CYGWIN_BASE% already exists.
   echo Cannot install over an existing installation.
   goto exit

:install
echo About to install Cygwin %CPU% to folder %CYGWIN_BASE%
pause

mkdir "%CYGWIN_BASE%"
cd %CYGWIN_BASE%

rem Windows has no built-in wget or curl, so we generate a VBS script to do the same
set DLOAD_SCRIPT=%TEMP%\download-%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs
echo Option Explicit                                                    >  %DLOAD_SCRIPT%
echo Dim args, http, fileSystem, adoStream, url, target, status         >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo Set args = Wscript.Arguments                                       >> %DLOAD_SCRIPT%
echo Set http = CreateObject("WinHttp.WinHttpRequest.5.1")              >> %DLOAD_SCRIPT%
echo url = args(0)                                                      >> %DLOAD_SCRIPT%
echo target = args(1)                                                   >> %DLOAD_SCRIPT%
echo WScript.Echo "Getting '" ^& target ^& "' from '" ^& url ^& "'..."  >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo http.Open "GET", url, False                                        >> %DLOAD_SCRIPT%
echo http.Send                                                          >> %DLOAD_SCRIPT%
echo status = http.Status                                               >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo If status ^<^> 200 Then                                            >> %DLOAD_SCRIPT%
echo    WScript.Echo "FAILED to download: HTTP Status " ^& status       >> %DLOAD_SCRIPT%
echo    WScript.Quit 1                                                  >> %DLOAD_SCRIPT%
echo End If                                                             >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo Set adoStream = CreateObject("ADODB.Stream")                       >> %DLOAD_SCRIPT%
echo adoStream.Open                                                     >> %DLOAD_SCRIPT%
echo adoStream.Type = 1                                                 >> %DLOAD_SCRIPT%
echo adoStream.Write http.ResponseBody                                  >> %DLOAD_SCRIPT%
echo adoStream.Position = 0                                             >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo Set fileSystem = CreateObject("Scripting.FileSystemObject")        >> %DLOAD_SCRIPT%
echo If fileSystem.FileExists(target) Then fileSystem.DeleteFile target >> %DLOAD_SCRIPT%
echo adoStream.SaveToFile target                                        >> %DLOAD_SCRIPT%
echo adoStream.Close                                                    >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%

echo.
echo ** Installing base cygwin...
cscript /nologo %DLOAD_SCRIPT% https://cygwin.com/setup-%CPU%.exe setup-%CPU%.exe
setup-%CPU% %CYGWIN_OPTIONS% %SITE% %PACKAGES% 
rem original command: setup-%CPU% --no-admin --root %CYGWIN_BASE% --quiet-mode --no-shortcuts --site ftp://mirror.switch.ch/mirror/cygwin/ --categories Base -l %CYGWIN_BASE%\var\cache\apt\packages --packages dos2unix,ncurses,wget,gcc-g++,make,vim,git

rem Install apt-cyg package manager
%CYGWIN_BASE%\bin\wget -O /bin/apt-cyg https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
%CYGWIN_BASE%\bin\chmod +x /bin/apt-cyg

rem Create home directory
"%CYGWIN_BASE%\bin\bash" --login -c echo "Creating home directory..."

rem Create desktop shortcut
set SHORTCUT_SCRIPT=%TEMP%\shortcut-%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs
echo Set oWS = WScript.CreateObject("WScript.Shell")                    >  "%SHORTCUT_SCRIPT%"
echo sLinkFile = "%USERPROFILE%\Desktop\Cygwin.lnk"                     >> "%SHORTCUT_SCRIPT%"
echo Set oLink = oWS.CreateShortcut(sLinkFile)                          >> "%SHORTCUT_SCRIPT%"
echo oLink.TargetPath = "%CYGWIN_BASE%\bin\mintty.exe"                  >> "%SHORTCUT_SCRIPT%"
echo oLink.Arguments = "-"                                              >> "%SHORTCUT_SCRIPT%"
echo oLink.Save                                                         >> "%SHORTCUT_SCRIPT%"
cscript /nologo "%SHORTCUT_SCRIPT%"

rem Cleanup
del "%DLOAD_SCRIPT%"
del "%SHORTCUT_SCRIPT%"
set CYGWIN_BASE=
set CPU=
set DLOAD_SCRIPT=
set SHORTCUT_SCRIPT=

echo Cygwin is now installed!

:exit
pause
