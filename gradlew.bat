@echo off
setlocal
set GRADLE_VERSION=8.13
set CACHE_ROOT=%USERPROFILE%\.gradle\wedding-wrapper\%GRADLE_VERSION%
set GRADLE_HOME=%CACHE_ROOT%\gradle-%GRADLE_VERSION%
if not exist "%GRADLE_HOME%\bin\gradle.bat" (
  if not exist "%CACHE_ROOT%" mkdir "%CACHE_ROOT%"
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip'; $z='%CACHE_ROOT%\gradle-%GRADLE_VERSION%-bin.zip'; if (!(Test-Path $z)) { Invoke-WebRequest -Uri $u -OutFile $z }; Expand-Archive -Force $z '%CACHE_ROOT%'"
)
call "%GRADLE_HOME%\bin\gradle.bat" %*
