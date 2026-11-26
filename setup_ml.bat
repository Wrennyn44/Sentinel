@echo off
setlocal
cd /d "%~dp0"
set "PYTHON=python"
if not exist ".venv\Scripts\python.exe" (
  where py >nul 2>nul
  if not errorlevel 1 (
    py -m venv .venv
    if errorlevel 1 goto :error
  )
)
if exist ".venv\Scripts\python.exe" set "PYTHON=.venv\Scripts\python.exe"
echo Installing ML dependencies...
"%PYTHON%" -m pip install -r requirements.txt
if errorlevel 1 goto :error
echo.
echo Training incident classifier...
"%PYTHON%" core\ml\train_model.py
if errorlevel 1 goto :error
echo.
echo Checking Django project...
"%PYTHON%" manage.py check
if errorlevel 1 goto :error
echo.
echo ML setup completed successfully.
echo Start the server with: "%PYTHON%" manage.py runserver
pause
exit /b 0
:error
echo.
echo ML setup failed. Read the error above.
pause
exit /b 1
