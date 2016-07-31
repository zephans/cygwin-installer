@echo off
set SCRIPTVER=2016.07.30
set SCRIPTPATH=%~dp0
set SCRIPTNAME=%~nx0
set SCRIPTCHANGE=%~t0
set SCRIPT
set "title=%ScriptName% (v%SCRIPTVER%)"
TITLE %title%
COLOR 0E

echo.
:HEADER
echo ----------------------------
echo - cygwin-installer.bat v%SCRIPTVER%- unattended/simplified Cygwin install script
echo - SUMMARY: 
echo -    1. Customizable Cygwin setup settings for personal or team installations.
echo -    2. Creates list of Cygwin packages to preinstall.
echo -    3. Gets latest setup.exe from official https://cygwin.com/ site.
echo -    3. Installs Cygwin with custom list of packages 
echo -    4. Configures new Cygwin installation
echo -          a. SSH_KEYGEN {if no default private/public key pair present}
echo -          b. Cygwin Settings
echo -          c. Team Settings {copied from a team fileshare}
echo - 
echo - IMPORTANT KNOWN ISSUES:
echo - ALPHA - UNDER CONSTRUCTION.  Still debugging script execution for primary use case
echo - a. Script assumes clean install. Cygwin uninstall is non-trivial. YMMV.
echo - b. Running specific sections {SSH_KEYGEN,TEAM_CONFIG} is an untested design that needs work.
echo - c. Limited error handling - Port script to PowerShell before investing in  robustness.
echo -    Source, history, and issue list: https://github.com/zephans/cygwin-installer
echo -----------------------------
echo.
echo ---------------------------------------
echo ** STAGE 1 : Preparing Cygwin install settings...

:TEAM_CONFIG_SETTINGS
	rem Team configuration file location and source reference
	rem TODO: Set Team=self for easy single user install
	set TEAM_CONFIG_PATH=.
	rem A shared team path will be a fileshare like \\TeamServer\CygwinFileshare
	set TEAM_CONFIG_FILE=TEAM_CONFIG.sh
	set TEAM_CONFIG_SOURCEREF=TEAM_CONFIG.sourceref
	IF /I "TEAM_CONFIG_PATH"=="\\TeamServer\CygwinFileshare" (
		echo ** ERROR: TEAM_CONFIG_PATH must be customized.
	)
	rem TODO: Confirm each file exists before proceeding... but bad fileshare will make this check too slow.


:SCRIPT_SETTINGS
	set DEBUG=TRUE
	if /I "%DEBUG%"=="TRUE" echo DEBUG output enabled. PROCESSOR_ARCHITEW6432=%PROCESSOR_ARCHITEW6432%  (blank=x86, amd64=64-bit)
	set QUIET=FALSE
	set INSTALL_CYGWIN=TRUE
	set CONFIG_TEAM=TRUE
	set KEGEN=TRUE


:CYGWIN_SETUP_SETTINGS
	rem CYGWIN install location, home, bitness, etc.
	rem Cygwin setup command: setup-%CPU%.exe %CYGWIN_OPTIONS% %CYGWIN_PACKAGE_SITE% %PACKAGES% 
	rem CPU=x86_64 for 64-bit Cygwin or CPU=x86 for 32-Bit
	rem cygwin.com default base dir: setup-x86_64.exe=C:\cygwin64 , setup-x86=C:\cygwin32
	rem Setup options available by running setup-x86_64.exe --help
	set CYGWIN_PACKAGE_SITE=http://mirrors.kernel.org/sourceware/cygwin/
    rem set CYGWIN_PACKAGE_SITE=ftp://mirror.switch.ch/mirror/cygwin/ 
	echo ** Cygwin package site: %CYGWIN_PACKAGE_SITE%
	echo ** TIP: If default broken then pick another from https://cygwin.com/mirrors.html
	echo.

	if /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" (
		set CYGWIN_BASE_PATH=C:\cygwin64
		set CPU=x86_64
	) else (
		set CYGWIN_BASE_PATH=C:\cygwin
		set CPU=x86
	)
	set CYGWIN_HOME=%CYGWIN_BASE_PATH%\home\%username%
	set CYGWIN_SETUP_SOURCE=https://cygwin.com/setup-%CPU%.exe
	set CYGWIN_OPTIONS=--no-admins --root %CYGWIN_BASE_PATH% --quiet-mode --disable-buggy-antivirus --local-package-dir %CYGWIN_BASE_PATH%\var\cache\apt\packages
	   rem --no-shortcuts 
	set DESKTOP_SHORTCUT=FALSE
	set STAGING_DIR=c:\downloads
	if not exist %STAGING_DIR% mkdir %STAGING_DIR%


	
:STAGE_2
:PACKAGES_LIST
	@echo -------------------------------------------------
	@echo ** STAGE 2: Building list of packages to install with Cygwin... ***
	REM Common package groups for different types of work. Add/remove package list as needed.
	REM   -- PACKAGES grouping pattern from https://github.com/stephenmm/auto-install-cygwin
	REM   -- TIP: any duplicates will be ignored
	REM   -- Full package list: https://cygwin.com/packages/ 
	@echo   -- TIP: Don't get lost or install several GB for all.  
	@echo      Cygwin setup and apt-cyg can both add/update packages easily.
	set CATEGORIES=--categories Base 

	REM Networking : {required for SSH tunnels}
	SET PACKAGES=--packages openssh,openssl,corkscrew,autossh

	REM Development version control :
	SET PACKAGES=%PACKAGES%,git,git-completion,git-gui-gitk

	REM General :
	SET PACKAGES=%PACKAGES%,curl,wget,netcat
	SET PACKAGES=%PACKAGES%,awk,bash-completion,bzip2,coreutils,ctags,diffutils,gawk,grep,groff,login,sed,tar

	REM Editors :
	SET PACKAGES=%PACKAGES%,vim,vim-common,nano

	REM apt-cyg install dependencies, do not change -- from https://github.com/hasantahir/cygwin-auto-install
	SET PACKAGES=%PACKAGES%,wget,tar,gawk,bzip2,subversion

	@echo off
	echo.

	rem ---------------------------------
	rem No changes needed past this point!

:INPUT_VALIDATION
	echo ** Input validation...
	echo DEBUG: Skip check for existing Cygwin dir {assumes clean} & goto GET_CYGWIN
	if not exist %CYGWIN_BASE_PATH% goto GET_CYGWIN 
	   echo ERROR: The directory %CYGWIN_BASE_PATH% already exists.
	   echo This script is not designed or tested to install over an existing installation. 
	   REM TODO: fix and test script reinstall.
	   REM TODO: Add Cygwin uninstall notes here.
	   goto EXIT


:STAGE_3
:GET_CYGWIN
	IF /I "%INSTALL_CYGWIN%" NEQ "TRUE" GOTO STAGE_4
	echo ----------------------
	echo ** STAGE 3: INSTALL **
	echo Ready to install Cygwin %CPU% to folder %CYGWIN_BASE_PATH%
	if /I "%QUIET%" NEQ "TRUE" (
		echo CYGWIN_OPTIONS=
		echo %CYGWIN_OPTIONS%
		echo.
		echo CYGWIN_PACKAGE_SITE=%CYGWIN_PACKAGE_SITE%
		echo CATEGORIES=%CATEGORIES%
		echo PACKAGES=%PACKAGES%
		echo.
		echo Cygwin setup retrieval: (uses generated script)
		set DLOAD_SCRIPT=%TEMP%\download-{RANDOM-RANDOM-RANDOM-RANDOM}.vbs
		echo cscript /nologo %DLOAD_SCRIPT% %CYGWIN_SETUP_SOURCE% setup-%CPU%.exe
		echo.
		echo ## Cygwin install command: ##
		echo setup-%CPU% %CYGWIN_OPTIONS% --site %CYGWIN_PACKAGE_SITE% %CATEGORIES% %PACKAGES% 
		echo.
		echo Press Ctrl+C to exit or 
		pause
	)

	mkdir "%CYGWIN_BASE_PATH%"
	cd /d "%CYGWIN_BASE_PATH%"
	echo ** Creating script to get latest Cygwin setup file...
	rem Windows has no built-in wget or curl. Generate VBS script to get file from URL.
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
	echo *** Getting Cygwin setup-%CPU%.exe from %CYGWIN_SETUP_SOURCE% to "%STAGING_DIR%" ...
	cscript /nologo %DLOAD_SCRIPT% %CYGWIN_SETUP_SOURCE% %STAGING_DIR%\setup-%CPU%.exe
	IF %ERRORLEVEL% NEQ 0 (
		echo ** ERROR %ERRORLEVEL%: Download Cygwin setup failed.
		echo Rest of this script will likely fail miserably.
		echo press Ctrl+C to break or & pause
	)
	echo ** Download completed. 
	echo.

:CYGWIN_SETUP
	echo Installing Cygwin...
	IF NOT EXIST "%STAGING_DIR%\setup-%CPU%" (
		echo ** FATAL ERROR: file not found: "%STAGING_DIR%\setup-%CPU%"
		echo ** exiting script
		goto exit
	)
	
	IF /I "%DEBUG%"=="TRUE" echo DEBUG: breakpoint pause set here & pause
	call "%STAGING_DIR%\setup-%CPU%" %CYGWIN_OPTIONS% --site %CYGWIN_PACKAGE_SITE% %CATEGORIES% %PACKAGES% 
	rem original command: setup-%CPU% --no-admin --root %CYGWIN_BASE_PATH% --quiet-mode --no-shortcuts --site ftp://mirror.switch.ch/mirror/cygwin/ --categories Base -l %CYGWIN_BASE_PATH%\var\cache\apt\packages --packages dos2unix,ncurses,wget,gcc-g++,make,vim,git
	
	if /I "%DESKTOP_SHORTCUT%"=="TRUE" (
		echo Create desktop shortcut
		set SHORTCUT_SCRIPT=%TEMP%\shortcut-%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs
		echo Set oWS = WScript.CreateObject("WScript.Shell")                    >  "%SHORTCUT_SCRIPT%"
		echo sLinkFile = "%USERPROFILE%\Desktop\Cygwin.lnk"                     >> "%SHORTCUT_SCRIPT%"
		echo Set oLink = oWS.CreateShortcut(sLinkFile)                          >> "%SHORTCUT_SCRIPT%"
		echo oLink.TargetPath = "%CYGWIN_BASE_PATH%\bin\mintty.exe"             >> "%SHORTCUT_SCRIPT%"
		echo oLink.Arguments = "-"                                              >> "%SHORTCUT_SCRIPT%"
		echo oLink.Save                                                         >> "%SHORTCUT_SCRIPT%"
		cscript /nologo "%SHORTCUT_SCRIPT%"
	)
	
	echo ** Cygwin setup program done with select packages preinstalled.
	echo.
	echo.

:STAGE_4	
:CYG_CONFIG
	echo ----------------------------------------------
	echo ** STAGE 4: Configure Cygwin/bash ... **
	echo.

:STAGE_4a
:BASE_CONFIG
	echo ** Installing apt-cyg so you can manage/patch packages within a cygwin prompt...
	%CYGWIN_BASE_PATH%\bin\wget -O /bin/apt-cyg https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
	%CYGWIN_BASE_PATH%\bin\chmod +x /bin/apt-cyg
	echo.
	echo ** Creating home directory...
	"%CYGWIN_BASE_PATH%\bin\bash" --login -c echo "Creating home directory..."
	rem TODO: delete homedir confirmation once confirmed reliable.
	IF /I "%DEBUG%"=="TRUE" (
		echo DEBUG: confirming home dir was created...
		IF NOT EXIST %CYGWIN_HOME% echo WARNING: %CYGWIN_HOME% not found
		pause
	)
	
:STAGE_4b
:SSH_KEYGEN
	echo ----------------------------------------------
	echo ** SSH_KEYGEN : Generate private/public key pair for authentication...
	echo
	IF NOT EXIST "%CYGWIN_HOME%\.ssh\id_rsa" (
		echo ** Generating your SSH private/public key pair...
		echo ** IMPORTANT: Save the passphrase you choose to your password manager before proceeding. 
		echo ** WARNING: Nobody can recover your private key passphrase if it gets lost.
		%CYGWIN_BASE_PATH%\bin\bash.exe --login -i -c '/usr/bin/ssh-keygen -t rsa -b 2048'
		
		IF EXIST "%TEAM_CONFIG_PATH%\pubkeys" (
			echo ** uploading "%CYGWIN_HOME%\.ssh\id_rsa.pub" to "%TEAM_CONFIG_PATH%\pubkeys"...
			xcopy "%CYGWIN_HOME%\.ssh\id_rsa.pub" "%TEAM_CONFIG_PATH%\pubkeys\id_rsa.%username%.pub" /Q
		)
	) else (
		echo ** WARNING: "%CYGWIN_HOME%\.ssh\id_rsa" already present. 
		echo    Skipped generating key pair.
	)
		
	rem TODO: Research need/benefit of adding %CYGWIN_BASE_PATH%\bin\bash.exe --login -i -c '/usr/bin/ssh-host-config --yes'
	
	echo ** KEYGEN done.
	echo.

:STAGE_4c
:TEAM_CONFIG
	IF /I "%CONFIG_TEAM%" NEQ "TRUE" goto stage_6
	echo ------------------------------------------------
	echo -- STAGE 4c: Adding team configuration settings ...
	rem %CYGWIN_BASE_PATH%\bin\bash.exe --login -i -c '/usr/bin/mkpasswd --local > /etc/passwd'
	rem %CYGWIN_BASE_PATH%\bin\bash.exe --login -i -c '/usr/bin/mkgroup --local > /etc/group'

	echo ** Copying team .ssh/config template from %TEAM_CONFIG_PATH%\ssh  ...
	IF EXIST "%CYGWIN_HOME%\.ssh\config" (
		move "%CYGWIN_HOME%\.ssh\config" "%CYGWIN_HOME%\.ssh\config.old"
		echo ** WARNING ** .ssh\config file already exists. Moved to config.old in case you had old config to preserve or merge.
	)
	xcopy %TEAM_CONFIG_PATH%\ssh\config %CYGWIN_HOME%\.ssh\config /Q

	
	echo ** Copying %TEAM_CONFIG_PATH% files to %CYGWIN_HOME%
	xcopy "%TEAM_CONFIG_PATH%\*.*" %CYGWIN_HOME% /q
	rem IDEA: Copy team settings to /etc rather than user's home folder, then check home folder for override to team defaults.
	rem IDEA: map to team-wide common folder replication rather than pushing separate copies to maintain.
	rem IDEA: Adapt Dropbox folder mappings used in <https://github.com/stephenmm/auto-install-cygwin> to leverage file replication service such as dropbox, OneDrive, or a SharePoint offline folder for both team and personal settings to sync Cygwin settings across all user's computers.
	echo ** Appending source reference to %CYGWIN_HOME%\.bash_profile...
	if (find /C "%TEAM_CONFIG_FILE%" %CYGWIN_HOME%\.bash_profile) LEQ 0 (
		echo Appending .source %TEAM_CONFIG_FILE% to end of .bash_profile...
		type %TEAM_CONFIG_SOURCEREF% >> %CYGWIN_HOME%\.bash_profile
	) ELSE (
		echo FYI: %TEAM_CONFIG_FILE% already referenced in .bash_profile.
	)
		

	echo Team configuration completed.
	echo.

:STAGE_6
:CLEANUP
	echo.
	echo ** STAGE 6: Cleanup and misc. options...
	IF EXIST "%DLOAD_SCRIPT%" del "%DLOAD_SCRIPT%"
	IF EXIST "%SHORTCUT_SCRIPT%" del "%SHORTCUT_SCRIPT%"
	set CYGWIN_BASE_PATH=
	set CPU=
	set DLOAD_SCRIPT=
	set SHORTCUT_SCRIPT=
	rem TODO: Clear all batch variables  or move scope via setlocal 
	rem       so running batch script again doesn't re-use any previous settings.
	
	
:EXIT
echo Install-Cygwin script end.
echo IMPORTANT: Review above commands and results and report any errors.
IF /I "%QUIET%" NEQ "TRUE" pause
