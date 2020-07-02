:: --------------------------------------------------------------------
:: Create, upload specification files with project
:: NOTE: Using local Nuspec.exe, NuspecPS1.exe versions.
:: 
:: Run this from your local VS .*proj directory
:: Script loads a version of Nuspec.exe from remote source if nuget is
:: not available to create the manifest file.
:: --------------------------------------------------------------------
@ECHO OFF
Setlocal EnableExtensions EnableDelayedExpansion
:: Switches RELEASES to Nuspec or NuspecPS1 - Alternative usage via ps script execution.
:: https://raw.githubusercontent.com/chrdek/Nuspecexec/master/Nuspec.ps1
:: https://github.com/chrdek/Nuspecexec/releases/download/1.1.8.10/Nuspec.exe
:: https://github.com/chrdek/Nuspecexec/releases/download/1.1.8.10/NuspecPS1.exe
Set projects=*.*proj
Set RELPS1=PS1
Set MASTER=Nuspecexec/master/Nuspec.ps1
Set RELEASE=releases/download/1.1.8.10/Nuspec

:: Check for proper file(s) in executing  folder.
dir %projects% | findstr /i "file not found" & IF %Errorlevel% NEQ 0 GOTO :REMOTEFETCH
:: & IF %Errorlevel% NEQ 0 EXIT /b !Errorlevel!

nuget.exe spec
IF %errorlevel% NEQ 0 (
    CALL :REMOTEFETCH
) ELSE (
    CALL :LOCALCREATE
)

:REMOTEFETCH
  :: Switch ON/OFF executable for PS1 usage ::NuspecPS1 ::Nuspec
  Set nuspecexe=Nuspec
  Set nuspecexeps1=%nuspecexe%%RELPS1%

  :: Direct create/run PS1 script
  Set nuspecps1=.\Nuspec.ps1

  @ECHO ON
  @ECHO.
  @ECHO.
  @ECHO EXE not present, retrieve/running remote source...
  @ECHO OFF
  Set remote="https://raw.githubusercontent.com/chrdek/!MASTER!"
  :: Set remotexecps1="https://github.com/chrdek/!RELEASE!!RELPS1!.exe"
  Set remotexec="https://github.com/chrdek/!RELEASE!.exe"

:: powershell -command "$(wget -Uri $([Uri]::new('%remote%'))).Content | Set-Content -Path %nuspecexe%.exe"
:: powershell -command "$(wget -Uri $([Uri]::new('http://raw.githubusercontent.com/chrdek/Nuspecexec/master/Nuspec.ps1'))).Content | Set-Content -Path %nuspecps1%"
powershell -command "$content=$(wget -Uri $([Uri]::new('http://raw.githubusercontent.com/chrdek/Nuspecexec/master/Nuspec.ps1'))).Content;($content -replace $content[0],'') | Set-Content -Path %nuspecps1%"
powershell -command ". %nuspecps1%" & GOTO :LOCALCREATE

IF %ErrorLevel% NEQ 0 (
  IF "%nuspecexe%" EQU "Nuspec" (
  @ECHO ON
  @ECHO.
  @ECHO Running from Nuspec executable: generating .nuspec with dll/dependency defs..
  powershell  -command "wget -Uri $([Uri]::new('%remotexec%'))" && %nuspecexe%
  )
  IF "%nuspecexeps1%" EQU "NuspecPS1" (
  @ECHO ON
  @ECHO.
  @ECHO Running from NuspecPS executable: generating .nuspec with dll/dependency defs..
  powershell -command "wget -Uri $([Uri]::new('%remotexecps1%'))" && %nuspecexeps1%
  )
  GOTO :LOCALCREATE
)

:: Script generates a temporary GUID to set as an Api Key, 
:: adds to the associated nuget host config list.
:LOCALCREATE
@ECHO OFF
:: xcopy %USERPROFILE%\Downloads\conn4\favicon.png .\ /F /J /I
xcopy %USERPROFILE%\Downloads\conn4\nuget.exe .\ /F /J /I
:: Alternative - FOR /F %%a IN ('Powershell.exe -Command "$([guid]::NewGuid().ToString())"') DO ( SET GUID=%%a )
FOR /F %%a IN ('powershell -command ("[Guid]::NewGuid()).Guid"') DO ( SET GUID=%%a )
 nuget.exe setApikey %GUID% -NonInteractive & nuget.exe pack .nuspec -IncludeReferencedProjects -properties Configuration=Release -Force
 nuget.exe push *.nupkg %GUID% -Source https://www.nuget.org/api/v2/package -Timeout 60
IF %ErrorLevel% NEQ 0 EXIT /b %ErrorLevel%

:: Additional GUIDs to use for nupkg generation.
:: Set GUID1=298621fd-a91a-420e-add4-f7de1b6e649a
:: Set GUID2=04300da2-7b2f-4c93-8162-bcfe5418359a
:: Set GUID3=a95ab8a0-33f3-4a61-a88a-dc3b68dcb74d
:: Set GUID4=9f8c2b79-a099-42c1-9593-fa46c258e4f3