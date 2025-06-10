@REM Simple Windows batch script to apply Django migrations against a Python virtual environment.
@REM What: Attempts a dry run, if no errors occur migrations are made and applied at the global level.
@REM Usage: Add script to your django project root directory. Update the DEFAULT_VENV_PATH var. Run `.\apply_migrations.bat`
@REM Note: This script assumes you have a virtual environment set up and that the `manage.py` file is in the current directory.

@REM Why: Might be useful to you. Pull requests are welcome and future scope expansions may occur.
@REM Licensing: MIT License (MIT) - Copyright (c) 2025 Oniel Toledo - Do whatever you want with this code with the acknowledgment the author bears no responsibility for any occurrances caused by usage.

@echo off
setlocal

:: === Default virtual environment path ===
set "DEFAULT_VENV_PATH=C:\bus001\product\web_app\external\good_django_v1.1.4_test\good_django_v1.1.4\.venv"
@REM Alternative set based on path: set "DEFAULT_VENV_PATH=%MY_VENV_HOME%"

:: === Prompt for override ===
set "VENV_PATH="
set /p VENV_PATH=Enter virtual environment path (leave blank to use default: %DEFAULT_VENV_PATH%): 

if "%VENV_PATH%"=="" (
    set "VENV_PATH=%DEFAULT_VENV_PATH%"
)

:: === Activate the virtual environment ===
call "%VENV_PATH%\Scripts\activate.bat"
if errorlevel 1 (
    echo [ERROR] Failed to activate virtual environment at %VENV_PATH%
    exit /b 1
)

:: === Run dry-run makemigrations and capture output ===
echo Running dry-run makemigrations...
set "OUTPUT_FILE=%TEMP%\makemigrations_output.txt"
python manage.py makemigrations --check --dry-run > "%OUTPUT_FILE%" 2>&1

:: === Read output and check for "No changes detected" ===
set "NO_CHANGES=false"
for /f "delims=" %%A in (%OUTPUT_FILE%) do (
    echo %%A
    echo %%A | findstr /C:"No changes detected" >nul && set "NO_CHANGES=true"
)

if not "%NO_CHANGES%"=="true" (
    echo.
    echo [INFO] Changes detected or an error occurred during dry-run. Halting.
    exit /b 1
)

:: === Proceed with actual migration ===
echo.
echo [INFO] No changes detected. Proceeding with makemigrations and migrate...
python manage.py makemigrations
python manage.py migrate

:: === Clean up and finish ===
del "%OUTPUT_FILE%" >nul 2>&1
endlocal
pause
