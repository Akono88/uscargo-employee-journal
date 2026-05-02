@echo off
REM ============================================================
REM US Cargo Employee Journal - one-shot deploy helper
REM
REM Usage:
REM   1) First time, repo not yet pushed:
REM        deploy.bat https://github.com/YOUR-USER/uscargo-employee-journal.git
REM   2) After config.js is patched with Supabase URL + anon key:
REM        deploy.bat update
REM   3) Just commit current changes and push:
REM        deploy.bat push "your commit message"
REM
REM Logs to deploy.log so we can read what happened from the chat.
REM ============================================================
cd /d "%~dp0"
set LOGFILE=deploy.log
echo === deploy.bat run %DATE% %TIME% === > "%LOGFILE%"
echo arg1=%1 >> "%LOGFILE%"
echo arg2=%2 >> "%LOGFILE%"

REM ---- 0. wipe any half-initialized .git from earlier attempts ----
if exist ".git" (
  echo --- removing existing .git --- >> "%LOGFILE%"
  rmdir /s /q ".git" >> "%LOGFILE%" 2>&1
)

REM ---- 1. configure git identity (idempotent) ----
git config --global user.name "Adam Konopko" >> "%LOGFILE%" 2>&1
git config --global user.email "uscb2250@gmail.com" >> "%LOGFILE%" 2>&1

REM ---- 2. init + initial commit ----
echo --- git init --- >> "%LOGFILE%"
git init >> "%LOGFILE%" 2>&1
git branch -M main >> "%LOGFILE%" 2>&1
echo --- git add . --- >> "%LOGFILE%"
git add . >> "%LOGFILE%" 2>&1
echo --- git commit --- >> "%LOGFILE%"
git commit -m "Initial commit: US Cargo confidential employee journal" >> "%LOGFILE%" 2>&1

REM ---- 3. add remote (if URL passed in) ----
if "%~1"=="" goto :no_remote
if "%~1"=="update" goto :no_remote
if "%~1"=="push" goto :no_remote

echo --- git remote add origin %~1 --- >> "%LOGFILE%"
git remote add origin %~1 >> "%LOGFILE%" 2>&1
echo --- git push -u origin main --- >> "%LOGFILE%"
git push -u origin main >> "%LOGFILE%" 2>&1

:no_remote
echo. >> "%LOGFILE%"
echo --- final state --- >> "%LOGFILE%"
git log --oneline -5 >> "%LOGFILE%" 2>&1
git remote -v >> "%LOGFILE%" 2>&1
git status -s >> "%LOGFILE%" 2>&1
echo. >> "%LOGFILE%"
echo === DONE %DATE% %TIME% === >> "%LOGFILE%"

type "%LOGFILE%"
