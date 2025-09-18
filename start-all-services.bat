@echo off
echo Starting EazyBank Microservices...
echo.

echo Checking Maven setup...
mvn -version
if %ERRORLEVEL% neq 0 (
    echo ERROR: Maven not found in PATH. Please ensure Maven is properly installed and configured.
    pause
    exit /b 1
)

echo.
echo Building all services first...
mvn clean package -DskipTests
if %ERRORLEVEL% neq 0 (
    echo ERROR: Build failed. Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo Starting Accounts Service on port 8080...
start "Accounts Service" cmd /c "cd accounts && mvn spring-boot:run"

timeout /t 3 /nobreak >nul

echo Starting Cards Service on port 9000...
start "Cards Service" cmd /c "cd cards && mvn spring-boot:run"

timeout /t 3 /nobreak >nul

echo Starting Loans Service on port 8090...
start "Loans Service" cmd /c "cd loans && mvn spring-boot:run"

echo.
echo All microservices are starting up...
echo Check the individual command windows for startup progress.
echo.
echo Services will be available at:
echo - Accounts: http://localhost:8080
echo - Cards: http://localhost:9000
echo - Loans: http://localhost:8090
echo.
echo Swagger UI will be available at:
echo - Accounts: http://localhost:8080/swagger-ui.html
echo - Cards: http://localhost:9000/swagger-ui.html
echo - Loans: http://localhost:8090/swagger-ui.html
echo.
pause
