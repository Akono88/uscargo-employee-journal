@echo off
REM Auto-deploy: clean half-init, init, commit, add remote, push.
REM Logs everything to deploy.log so Claude can read what happened.
cd /d "%~dp0"
set LOGFILE=deploy.log
set REMOTE=https://github.com/Akono88/uscargo-employee-journal.git

echo === deploy_run.bat run %DATE% %TIME% === > "%LOGFILE%"
echo remote=%REMOTE% >> "%LOGFILE%"

if exist ".git" (
  echo --- removing existing .git --- >> "%LOGFILE%"
  rmdir /s /q ".git" >> "%LOGFILE%" 2>&1
)

git config --global user.name "Adam Konopko" >> "%LOGFILE%" 2>&1
git config --global user.email "uscb2250@gmail.com" >> "%LOGFILE%" 2>&1

echo --- git init --- >> "%LOGFILE%"
git init >> "%LOGFILE%" 2>&1
git branch -M main >> "%LOGFILE%" 2>&1

echo --- git add . --- >> "%LOGFILE%"
git add . >> "%LOGFILE%" 2>&1

echo --- git commit --- >> "%LOGFILE%"
git commit -m "Initial commit: US Cargo confidential employee journal" >> "%LOGFILE%" 2>&1

echo --- git remote add origin --- >> "%LOGFILE%"
git remote add origin %REMOTE% >> "%LOGFILE%" 2>&1

echo --- git push -u origin main --- >> "%LOGFILE%"
git push -u origin main >> "%LOGFILE%" 2>&1

echo. >> "%LOGFILE%"
echo --- final state --- >> "%LOGFILE%"
git log --oneline -5 >> "%LOGFILE%" 2>&1
git remote -v >> "%LOGFILE%" 2>&1
git status -s >> "%LOGFILE%" 2>&1

echo. >> "%LOGFILE%"
echo === DONE %DATE% %TIME% === >> "%LOGFILE%"

REM Don't keep the window open; we read deploy.log via the Read tool.
