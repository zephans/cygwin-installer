@echo off
set SCRIPTVER=2016.07.24
echo.
echo ----------------------------
echo - cygwin-installer.bat v%SCRIPTVER%- unattended/simplified Cygwin install script
echo - Gets latest setup .exe from official https://cygwin.com/ site.
echo - Then installs base packages and additional packages {edit top of batch as needed}
echo - Source and history on https://github.com/zephans/cygwin-installer
echo -----------------------------
echo.
echo ** Stage 1 - Preparing install settings.
rem Set CYGWIN_BASE variable to the installation directory.
    rem initial "cygwin-installer" script default was C:\Users\<username>\cygwin  a.k.a. CYGWIN_BASE=%USERPROFILE%\cygwin
    rem cygwin.com setup default is C:\cygwin64 {or C:\cygwin32}
@echo on
set CYGWIN_BASE=C:\cygwin64
set CPU=x86_64  ::rem Set CPU=x86_64 for 64-bit Cygwin or CPU=x86 
echo ** Setting cygwin_install.exe settings and default packages to install
   rem format of command is setup-%CPU% %CYGWIN_OPTIONS% %SITE% %PACKAGES% 
   rem FYI: setup options available by running setup-x86_64.exe --help
set CYGWIN_OPTIONS=--no-admins --root %CYGWIN_BASE% --quiet-mode --disable-buggy-antivirus --local-package-dir %CYGWIN_BASE%\var\cache\apt\packages
   rem --no-shortcuts 

@echo ** SITE: If default doesn't work then pick another site from https://cygwin.com/mirrors.html
set SITE=http://mirrors.kernel.org/sourceware/cygwin/
   rem set SITE=ftp://mirror.switch.ch/mirror/cygwin/ 

@echo ** PHASE 2: PACKAGES TO INSTALL ***
REM --------------------------------------------------------------
REM Common package groups for different types of work 
REM   -- PACKAGES grouping pattern from https://github.com/stephenmm/auto-install-cygwin
REM   -- TIP: any duplicates will be ignored
REM For a full package list see https://cygwin.com/packages/
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
REM vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
REM TODO -- Consolidate PACKAGES groups, then delete remarked blocks below.
REM packages from https://gist.github.com/wjrogers/1016065 
REM SET PACKAGES=mintty,wget,ctags,diffutils,git,git-completion,git-svn,mercurial
REM SET PACKAGES=%PACKAGES%,gcc-core,make,automake,autoconf,readline,libncursesw-devel,libiconv,zlib-devel,gettext
REM SET PACKAGES=%PACKAGES%,lua,python,ruby
REM SET PACKAGES=%PACKAGES%,vim
REM simplified setup command from same gist - setup -q -D -L -d -g -o -s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" -C Base -P %PACKAGES%

REM packages liked by migueigrinberg/cygwin-installer 
REM set PACKAGES=%PACKAGES% --packages dos2unix,ncurses,wget,gcc-g++,make,vim,git

REM packages from https://github.com/hasantahir/cygwin-auto-install
REM -- These are the packages we will install (in addition to the default packages)
REM SET PACKAGES=mintty,gcc-devel,gnuplot,make,automake,lapack,hdf5,guile,gsl-devel,indent,gmp,libunistring,pkg-config,ffi,bdw,libgc,libpng
REM -- These are necessary for apt-cyg install, do not change. Any duplicates will be ignored.
REM SET PACKAGES=%PACKAGES%,wget,tar,gawk,bzip2,subversion


REM packages from https://gist.github.com/mojmir-svoboda/02bb4b683ec14d9bb9c1 (getfile.vbs) fork of install.bat
REM	echo [INFO]: Cygwin setup installing base packages
REM	%PROGNAME% %OPTIONS% -s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%"
REM
REM	echo [INFO]: For more packages go to http://grasswiki.osgeo.org/wiki/Cygwin_Packages
REM
REM	rem -- These are the packages we will install (in addition to the default packages)
REM	set PACKAGES=mintty,wget,ctags,diffutils
REM	set PACKAGES=%PACKAGES%,gcc4,make,automake,autoconf,readline,libncursesw-devel,libiconv
REM	set PACKAGES=%PACKAGES%,colorgcc,colordiff,bvi,gawk
REM	set PACKAGES=%PACKAGES%,bc,gnuplot
REM	set PACKAGES=%PACKAGES%,inetutils,ncurses,openssh,openssl,vim,mc,multitail,dos2unix,irssi
REM
REM	echo [INFO]: Cygwin setup installing custom packages:
REM	echo %PACKAGES%
REM	%PROGNAME% %OPTIONS% -s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" -P %PACKAGES%

REM --------------------------------------------------------------
REM Common package groups for different types of work 
REM   -- pattern from https://github.com/stephenmm/auto-install-cygwin

REM C development: gcc4-core make readline
REM SET PACKAGES=-P gcc4-core,make,readline,binutils

REM General : diffutils ctags
REM SET PACKAGES=%PACKAGES%,diffutils,ctags

REM Packaging : cygport
REM SET PACKAGES=%PACKAGES%,cygport

REM Packages : Taken from a previous HUGE cygwin install
REM SET PACKAGES=%PACKAGES%,X-start-menu-icons,_update-info-dir,alternatives,^
REM base-cygwin,base-files,bash,bzip2,coreutils,crypt,csih,ctags,^
REM cygrunsrv,cygutils,cygwin,cygwin-doc,dash,dbus,diffutils,dos2unix,editrights,^
REM file,findutils,font-adobe-dpi75,font-alias,font-encodings,font-misc-misc,fontconfig,^
REM gamin,gawk,gettext,gnome-icon-theme,grep,groff,gsettings-desktop-schemas,gvim,gzip,^
REM hicolor-icon-theme,ipc-utils,kbproto,less,^
REM libGL1,libICE6,libSM6,libX11-devel,libX11-xcb-devel,libX11-xcb1,libX11_6,libXau-devel,libXau6,libXaw7,libXcomposite1,libXcursor1,libXdamage1,libXdmcp-devel,libXdmcp6,libXext6,libXfixes3,libXft2,libXi6,libXinerama1,libXmu6,libXmuu1,libXpm4,libXrandr2,libXrender1,libXt6,libapr1,libaprutil1,libatk1.0_0,libattr1,libblkid1,libbz2_1,libcairo2,libdatrie1,libdb4.5,libdbus1_3,libedit0,libexpat1,libfam0,libffi4,libfontconfig1,libfontenc1,libfreetype6,libgcc1,libgcrypt11,libgdbm4,libgdk_pixbuf2.0_0,libglib2.0_0,libgmp3,libgnutls26,libgpg-error0,libgtk2.0_0,libiconv2,libidn11,libintl8,libjasper1,libjbig2,libjpeg7,libjpeg8,liblzma5,liblzo2_2,libncurses10,libncursesw10,libneon27,libopenldap2_3_0,libopenssl098,libpango1.0_0,libpcre0,libpixman1_0,libpng14,libpopt0,libpq5,libproxy1,libpthread-stubs,libreadline7,libsasl2,libserf0_1,libserf1_0,libsigsegv2,libsqlite3_0,libssp0,libstdc++6,libtasn1_3,libthai0,libtiff5,libuuid1,libwrap0,libxcb-devel,libxcb-glx0,libxcb-render0,libxcb-shm0,libxcb1,libxkbfile1,libxml2,^
REM login,luit,man,minires,mintty,mkfontdir,mkfontscale,nano,openssh,pbzip2,perl,rebase,run,sed,shared-mime-info,subversion,^
REM tar,tcltk,terminfo,texinfo,tzcode,util-linux,vim-common,wget,which,^
REM x11perf,xauth,xcursor-themes,xinit,xkbcomp,xkeyboard-config,xmodmap,xorg-server,xproto,xrdb,xterm,xxd,xz,zlib,zlib-devel,zlib
REM ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set DESKTOP_SHORTCUT=TRUE

rem---------------------------------
rem No changes needed past this point!

if not exist %CYGWIN_BASE% goto install
   echo The directory %CYGWIN_BASE% already exists.
   echo This script is not designed or tested to install over an existing installation. 
   echo {TODO - fix/test script reinstall.}
   goto exit

echo ** PHASE 3:install **
echo About to install Cygwin %CPU% to folder %CYGWIN_BASE%
echo    CYGWIN_OPTIONS=%CYGWIN_OPTIONS%
echo    SITE=%SITE%
echo    CATEGORIES=%CATEGORIES%
echo    PACKAGES=%PACKAGES%
echo.
echo Press Ctrl+C to exit or & pause

mkdir "%CYGWIN_BASE%"
cd /d %CYGWIN_BASE%

echo Getting Cygwin setup-%CPU%.exe...
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

cscript /nologo %DLOAD_SCRIPT% https://cygwin.com/setup-%CPU%.exe setup-%CPU%.exe
echo.
echo ** Installing base cygwin...
setup-%CPU% %CYGWIN_OPTIONS% --site %SITE% %CATEGORIES% %PACKAGES% 
rem original command: setup-%CPU% --no-admin --root %CYGWIN_BASE% --quiet-mode --no-shortcuts --site ftp://mirror.switch.ch/mirror/cygwin/ --categories Base -l %CYGWIN_BASE%\var\cache\apt\packages --packages dos2unix,ncurses,wget,gcc-g++,make,vim,git

echo.
echo ** PHASE 4: Cygwin/bash configuration... **
echo ** Installing apt-cyg package manager {support getting package updates from a cygwin prompt}...
%CYGWIN_BASE%\bin\wget -O /bin/apt-cyg https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
%CYGWIN_BASE%\bin\chmod +x /bin/apt-cyg
echo.
echo Creating home directory...
"%CYGWIN_BASE%\bin\bash" --login -c echo "Creating home directory..."
echo.
echo Appending .source rsstfsconfig.sh

rem TODO: map to team-wide common folder replication rather than separate copies to maintain.
rem IDEA: Adapt Dropbox folder mappings used in <https://github.com/stephenmm/auto-install-cygwin> to use "OneDrive - Philips" or a SharePoint offline folder.

echo.
echo ** PHASE 5: Cleanup and misc. options...
if /I "%DESKTOP_SHORTCUT%"="TRUE" (
    echo Create desktop shortcut
    set SHORTCUT_SCRIPT=%TEMP%\shortcut-%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs
    echo Set oWS = WScript.CreateObject("WScript.Shell")                    >  "%SHORTCUT_SCRIPT%"
    echo sLinkFile = "%USERPROFILE%\Desktop\Cygwin.lnk"                     >> "%SHORTCUT_SCRIPT%"
    echo Set oLink = oWS.CreateShortcut(sLinkFile)                          >> "%SHORTCUT_SCRIPT%"
    echo oLink.TargetPath = "%CYGWIN_BASE%\bin\mintty.exe"                  >> "%SHORTCUT_SCRIPT%"
    echo oLink.Arguments = "-"                                              >> "%SHORTCUT_SCRIPT%"
    echo oLink.Save                                                         >> "%SHORTCUT_SCRIPT%"
    cscript /nologo "%SHORTCUT_SCRIPT%"
)
del "%DLOAD_SCRIPT%"
del "%SHORTCUT_SCRIPT%"
set CYGWIN_BASE=
set CPU=
set DLOAD_SCRIPT=
set SHORTCUT_SCRIPT=

echo Cygwin is now installed!

:exit
pause
