  @echo off
  echo Change directory to src..
  cd %BUILD_MINIFY_TASK_PATH%
  echo Installing Node modules...
  call npm ci || exit /b 1
  echo Running Gulp task...
  call npx gulp min || exit /b 1
  echo Copying made min files...
  call xcopy wwwroot\js\*.min.js "%BUILD_DIR%\wwwroot\js" /e /i /y /q /v /r || exit /b 1
  call xcopy wwwroot\css\*.min.css "%BUILD_DIR%\wwwroot\css" /e /i /y /q /v /r || exit /b 1