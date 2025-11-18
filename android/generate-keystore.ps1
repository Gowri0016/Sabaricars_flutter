#!/usr/bin/env pwsh
# Keystore Generation Script for Sabari Cars Android App
# This script helps generate a secure digital signing key for Google Play Store submission
#
# Usage: Run this script from the android/ directory
# Example: cd android && pwsh generate-keystore.ps1

Write-Host ""
Write-Host "========================================"
Write-Host "Sabari Cars - Keystore Generation"
Write-Host "========================================"
Write-Host ""

# Check if keytool is available
try {
    $null = keytool -help 2>$null
} catch {
    Write-Host "ERROR: keytool not found. Please ensure Java Development Kit (JDK) is installed." -ForegroundColor Red
    Write-Host "Download JDK from: https://www.oracle.com/java/technologies/downloads/" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
    exit 1
}

# Create keystore directory if it doesn't exist
$keystoreDir = "keystore"
if (-not (Test-Path $keystoreDir)) {
    New-Item -ItemType Directory -Path $keystoreDir | Out-Null
    Write-Host "Created keystore directory"
}

# Generate keystore
Write-Host ""
Write-Host "Generating keystore file..."
Write-Host "Please provide the following information when prompted:"
Write-Host ""

$keystorePath = Join-Path $keystoreDir "sabaricars.jks"
$alias = "sabaricars_key"

& keytool -genkey -v -keystore $keystorePath -keyalg RSA -keysize 2048 -validity 10950 -alias $alias

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Failed to generate keystore file." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================"
Write-Host "Keystore generated successfully!" -ForegroundColor Green
Write-Host "========================================"
Write-Host ""
Write-Host "Location: $keystorePath"
Write-Host ""
Write-Host "IMPORTANT SECURITY REMINDERS:"
Write-Host "1. Store the keystore file securely - do NOT share it publicly"
Write-Host "2. Remember the passwords you entered - you'll need them for releases"
Write-Host "3. DO NOT commit key.properties to version control"
Write-Host "4. The .gitignore already protects sensitive files"
Write-Host "5. Keep backups of your keystore in a secure location"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Update android/key.properties with your passwords"
Write-Host "2. Run: flutter build apk --release  (for APK)"
Write-Host "   or: flutter build appbundle --release  (for Play Store)"
Write-Host ""
Read-Host "Press Enter to exit"
