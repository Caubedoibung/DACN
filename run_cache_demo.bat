@echo off
echo ========================================
echo   CACHE DEMO - MOCK MODE
echo ========================================
echo.
echo Server should be running on port 8000!
echo Press Ctrl+C if server is not running.
echo.
timeout /t 3
python D:\App\new\test_cache_demo.py
echo.
echo ========================================
echo Demo completed! Check results above.
echo ========================================
pause
