@echo off
:: Check if K: drive exists
subst | find "K:" >nul

if %errorlevel% == 0 (
    :: If K: exists, delete it
    subst K: /D
    echo Virtual drive K: removed.
) else (
    :: If K: doesn't exist, create it
    subst K: .
    echo Virtual drive K: created
)

pause