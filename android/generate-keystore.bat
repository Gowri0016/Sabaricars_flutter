@echo off
REM Keystore Generation Script for Sabari Cars Android App
REM This script helps generate a secure digital signing key for Google Play Store submission

echo.
echo ========================================
echo Sabari Cars - Keystore Generation
echo ========================================
echo.

REM Check if keytool is available
keytool -help >nul 2>&1
if errorlevel 1 (
    echo ERROR: keytool not found. Please ensure Java Development Kit (JDK) is installed.
    echo Download JDK from: https://www.oracle.com/java/technologies/downloads/
    pause
    exit /b 1
)

REM Create keystore directory if it doesn't exist
if not exist keystore (
    mkdir keystore
    echo Created keystore directory
)

REM Generate keystore
echo.
echo Generating keystore file...
echo Please provide the following information when prompted:
echo.

keytool -genkey -v -keystore keystore/sabaricars.jks -keyalg RSA -keysize 2048 -validity 10950 -alias sabaricars_key

if errorlevel 1 (
    echo.
    echo ERROR: Failed to generate keystore file.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Keystore generated successfully!
echo ========================================
echo.
echo Location: android/keystore/sabaricars.jks
echo.
echo IMPORTANT SECURITY REMINDERS:
echo 1. Store the keystore file securely - do NOT share it publicly
echo 2. Remember the passwords you entered - you'll need them for releases
echo 3. DO NOT commit key.properties to version control
echo 4. The .gitignore already protects sensitive files
echo 5. Keep backups of your keystore in a secure location
echo.
echo Next steps:
echo 1. Update android/key.properties with your passwords
echo 2. Run: flutter build apk --release  (for APK)
echo    or: flutter build appbundle --release  (for Play Store)
echo.
pause
