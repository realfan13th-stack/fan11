# 修复 GitHub hosts - 需要管理员权限
$hostsPath = "$env:windir\System32\drivers\etc\hosts"
$content = Get-Content $hostsPath -Raw

# 替换 github.com 为真实 IP
$content = $content -replace '127\.0\.0\.1 github\.com\b', '20.205.243.166 github.com'
$content = $content -replace '127\.0\.0\.1 api\.github\.com', '#127.0.0.1 api.github.com'
$content = $content -replace '127\.0\.0\.1 pages\.github\.com', '#127.0.0.1 pages.github.com'
$content = $content -replace '127\.0\.0\.1 gist\.github\.com', '#127.0.0.1 gist.github.com'
$content = $content -replace '127\.0\.0\.1 raw\.github\.com', '#127.0.0.1 raw.github.com'
$content = $content -replace '127\.0\.0\.1 github\.io\b', '185.199.108.153 github.io'
$content = $content -replace '127\.0\.0\.1 www\.github\.io', '185.199.108.153 www.github.io'

[System.IO.File]::WriteAllText($hostsPath, $content, [System.Text.Encoding]::UTF8)

# 刷新 DNS
ipconfig /flushdns | Out-Null

Write-Host "hosts 已修复！" -ForegroundColor Green
Write-Host "github.com -> 20.205.243.166" -ForegroundColor Yellow
Write-Host ""
Write-Host "按任意键关闭..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
