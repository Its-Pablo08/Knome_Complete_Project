@echo off
echo ==============================================
echo Terminating hung worker process and restarting IIS...
echo ==============================================
taskkill /F /IM w3wp.exe
iisreset /restart
echo ==============================================
echo Finished! Press any key or close this window.
pause
