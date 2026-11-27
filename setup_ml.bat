@echo off
setlocal
cd /d "%~dp0"
if not defined DEBUG set "DEBUG=True"
set "PYTHON="
if exist ".venv\Scripts\python.exe" (
  ".venv\Scripts\python.exe" --version >nul 2>nul
  if not errorlevel 1 set "PYTHON=.venv\Scripts\python.exe"
)
if not defined PYTHON (
  where py >nul 2>nul
  if not errorlevel 1 (
    py -3.13 -m venv --clear .venv
    if errorlevel 1 goto :error
  ) else (
    python -m venv --clear .venv
    if errorlevel 1 goto :error
  )
  set "PYTHON=.venv\Scripts\python.exe"
)
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
