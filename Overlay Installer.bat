@echo off

set "sourcePluginFolder=%~dp0\sos bakkesmod plugin"
set "sourceSettingsFolder=%sourcePluginFolder%\settings"

set "destinationPluginFolder=%APPDATA%\bakkesmod\bakkesmod\plugins"
set "destinationSettingsFolder=%destinationPluginFolder%\settings"

set "destinationDataFolder=%APPDATA%\bakkesmod\bakkesmod\data"
set "destinationRCONConfigFile=%destinationDataFolder%\rcon_commands.cfg"

set "destinationCfgFolder=%APPDATA%\bakkesmod\bakkesmod\cfg"
set "destinationConfigFile=%destinationCfgFolder%\config.cfg"
set "destinationPluginsFile=%destinationCfgFolder%\plugins.cfg"

rem Check if the destination plugin folder exists
if not exist "%destinationPluginFolder%" (
    echo ERROR: Destination plugin folder does not exist: %destinationPluginFolder%
    echo ERROR: Please make sure BakkesMod is installed correctly.
    echo AUTOMATIC INSTALLATION FAILED
    pause
    exit /b
)

rem Check if the destination settings folder exists
if not exist "%destinationSettingsFolder%" (
    echo ERROR: Destination settings folder does not exist: %destinationSettingsFolder%
    echo ERROR: Please make sure BakkesMod is installed correctly.
    echo AUTOMATIC INSTALLATION FAILED
    pause
    exit /b
)

rem Copy SOS.dll to the destination plugin folder
copy /Y "%sourcePluginFolder%\SOS.dll" "%destinationPluginFolder%" >NUL

rem Copy sos.set to the destination settings folder
copy /Y "%sourceSettingsFolder%\sos.set" "%destinationSettingsFolder%" >NUL

echo SOS.dll and sos.set have been set.



rem Check if the destination data folder exists
if not exist "%destinationDataFolder%" (
    echo ERROR: Destination data folder does not exist: %destinationDataFolder%
    echo ERROR: Please make sure bakkesmod is installed correctly.
    echo AUTOMATIC INSTALLATION FAILED
    pause
    exit /b
)

rem Check if the config file exists
if not exist "%destinationRCONConfigFile%" (
    echo ERROR: RCONConfig file does not exist: %destinationRCONConfigFile%
    echo ERROR: Please make sure bakkesmod is installed correctly.
    echo AUTOMATIC INSTALLATION FAILED
    pause
    exit /b
)


echo.>> "%destinationRCONConfigFile%"
rem Check if each required line exists in the config file
for %%L in (
    ws_inventory
    sendback
    rcon_password
    plugin
    cl_settings_refreshplugins
    rcon_refresh_allowed
    replay_gui
) do (
    REM findstr /x /c:"%%L" "%destinationRCONConfigFile%" > nul
    findstr /c:"%%L" "%destinationRCONConfigFile%" > nul
    if errorlevel 1 (
        echo %%L>> "%destinationRCONConfigFile%"
    )
)
    

echo The rcon_command.cfg file has been updated with the required lines.



rem Check if the destination cfg folder exists
if not exist "%destinationCfgFolder%" (
    echo ERROR: Destination cfg folder does not exist: %destinationCfgFolder%
    echo ERROR: Please make sure bakkesmod is installed correctly.
    echo AUTOMATIC INSTALLATION FAILED
    pause
    exit /b
)
   
REM Check if the config file exists
if not exist "%destinationConfigFile%" (
    echo ERROR: Config file does not exist: %destinationConfigFile%
    echo ERROR: Please make sure bakkesmod is installed correctly.
    echo AUTOMATIC INSTALLATION FAILED
    pause
    exit /b
)

    
set "tempFile=%TEMP%\tempfile.txt"
set "rconEnabledLine=rcon_enabled "1""
rem Check if the file contains the rcon_enabled line
findstr /b /c:"rcon_enabled" "%destinationConfigFile%" > nul
if errorlevel 1 (
    echo rcon_enabled line not found in the file.
    echo Adding the line: %rconEnabledLine%
    echo %rconEnabledLine%>> "%destinationConfigFile%"
) else (
    echo Replace the existing rcon_enabled line with the desired value
    findstr /v /c:"rcon_enabled" "%destinationConfigFile%" > "%tempFile%"
    echo %rconEnabledLine%>> "%tempFile%"
    move /y "%tempFile%" "%destinationConfigFile%" > nul
)

set "rconLogLine=rcon_log "0""
rem Check if the file contains the rcon_log line
findstr /b /c:"rcon_log" "%destinationConfigFile%" > nul
if errorlevel 1 (
    echo rcon_log line not found in the file.
    echo Adding the line: %rconLogLine%
    echo %rconLogLine%>> "%destinationConfigFile%"
) else (
    echo Replace the existing rcon_log line with the desired value
    findstr /v /c:"rcon_log" "%destinationConfigFile%" > "%tempFile%"
    echo %rconLogLine%>> "%tempFile%"
    move /y "%tempFile%" "%destinationConfigFile%" > nul
)

set "rconPasswordLine=rcon_password "STANDARDPASSWORD""
rem Check if the file contains the rcon_password line
findstr /b /c:"rcon_password" "%destinationConfigFile%" > nul
if errorlevel 1 (
    echo rcon_password line not found in the file.
    echo Adding the line: %rconPasswordLine%
    echo %rconPasswordLine%>> "%destinationConfigFile%"
) else (
    echo Replace the existing rcon_password line with the desired value
    findstr /v /c:"rcon_password" "%destinationConfigFile%" > "%tempFile%"
    echo %rconPasswordLine%>> "%tempFile%"
    move /y "%tempFile%" "%destinationConfigFile%" > nul
)

set "rconPortLine=rcon_port "9002""
rem Check if the file contains the rcon_port line
findstr /b /c:"rcon_port" "%destinationConfigFile%" > nul
if errorlevel 1 (
    echo rcon_port line not found in the file.
    echo Adding the line: %rconPortLine%
    echo %rconPortLine%>> "%destinationConfigFile%"
) else (
    echo Replace the existing rcon_port line with the desired value
    findstr /v /c:"rcon_port" "%destinationConfigFile%" > "%tempFile%"
    echo %rconPortLine%>> "%tempFile%"
    move /y "%tempFile%" "%destinationConfigFile%" > nul
)

set "rconTimeoutLine=rcon_timeout "5""
rem Check if the file contains the rcon_timeout line
findstr /b /c:"rcon_timeout" "%destinationConfigFile%" > nul
if errorlevel 1 (
    echo rcon_timeout line not found in the file.
    echo Adding the line: %rconTimeoutLine%
    echo %rconTimeoutLine%>> "%destinationConfigFile%"
) else (
    echo Replace the existing rcon_timeout line with the desired value
    findstr /v /c:"rcon_timeout" "%destinationConfigFile%" > "%tempFile%"
    echo %rconTimeoutLine%>> "%tempFile%"
    move /y "%tempFile%" "%destinationConfigFile%" > nul
)


rem Check if the config file exists
if not exist "%destinationPluginsFile%" (
    echo ERROR: Plugins file does not exist: %destinationPluginsFile%
    echo ERROR: Please make sure bakkesmod is installed correctly.
    echo AUTOMATIC INSTALLATION FAILED
    pause
    exit /b
)


echo.>> "%destinationPluginsFile%"
rem Check if each required line exists in the config file
findstr /c:"plugin load rconplugin" "%destinationPluginsFile%" > nul
if errorlevel 1 (
    echo plugin load rconplugin>> "%destinationPluginsFile%"
)
findstr /c:"plugin load sos" "%destinationPluginsFile%" > nul
if errorlevel 1 (
    echo plugin load sos>> "%destinationPluginsFile%"
)

   
echo The plugins.cfg file has been updated with the required lines.

    
echo.
echo SUCCESSFULLY INSTALLED
echo SUCCESSFULLY INSTALLED
echo SUCCESSFULLY INSTALLED
echo.

pause