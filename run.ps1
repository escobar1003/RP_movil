$gameDir = "C:\Users\jeimy\Juego"
Write-Host "Iniciando servidor del juego..." -ForegroundColor Green
Start-Process -WindowStyle Hidden powershell -ArgumentList "-NoExit", "cd '$gameDir'; npm run dev -- --host"

Start-Sleep -Seconds 3

$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -ne 'Loopback Pseudo-Interface 1' -and $_.IPAddress -like '192.*' }).IPAddress | Select-Object -First 1
if (-not $ip) { $ip = "192.168.20.106" }

Write-Host "IP detectada: $ip" -ForegroundColor Cyan
Write-Host "Ejecutando Flutter..." -ForegroundColor Green
flutter run -d 97afb09a --dart-define=GAME_URL=http://$($ip):5173/
