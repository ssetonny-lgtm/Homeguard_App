@echo off
REM Build the Flutter web app and deploy it to Firebase Hosting.
REM Usage: deploy.bat [firebase-account-email]
cd /d "%~dp0"
set PROJECT=home-guard-app-51db9
set ACCOUNT_ARGS=
if not "%~1"=="" set ACCOUNT_ARGS=--account %~1

call flutter pub get || exit /b 1
call flutter build web --release || exit /b 1
call firebase deploy --only hosting --project %PROJECT% %ACCOUNT_ARGS% || exit /b 1

echo Live at https://%PROJECT%.web.app
