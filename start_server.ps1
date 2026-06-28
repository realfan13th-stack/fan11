# 纯 TCP Socket HTTP 服务器 - 无需管理员权限、无需安装任何东西
$port = 8080
$folder = $PSScriptRoot
$ip = "0.0.0.0"

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($ip), $port)
$listener.Start()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  教师工作台 Web 服务器已启动" -ForegroundColor Green
Write-Host "  电脑访问: http://localhost:$port/schedule_v103.html" -ForegroundColor Yellow
Write-Host "  手机访问: http://192.168.50.153:$port/schedule_v103.html" -ForegroundColor Yellow
Write-Host "  按 Ctrl+C 停止服务器" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "如果手机打不开，可能是防火墙拦截了端口 $port" -ForegroundColor Magenta
Write-Host "请以管理员身份打开 PowerShell 并运行:" -ForegroundColor Magenta
Write-Host "  New-NetFirewallRule -DisplayName 'Schedule8080' -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow" -ForegroundColor White
Write-Host ""

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".json" = "application/json"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".woff" = "font/woff"
    ".woff2"= "font/woff2"
}

function Get-MimeType($ext) {
    $m = $mimeTypes[$ext.ToLower()]
    if ($m) { return $m }
    return "application/octet-stream"
}

$utf8 = [System.Text.Encoding]::UTF8

# 持续接受连接的主循环
while ($true) {
    try {
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream, $utf8)
        
        # 读取 HTTP 请求第一行
        $requestLine = $reader.ReadLine()
        if (-not $requestLine) { $client.Close(); continue }
        
        # 解析 GET /path HTTP/1.1
        $parts = $requestLine -split ' '
        $method = $parts[0]
        $rawPath = $parts[1]
        
        # 读取剩余头部（忽略）
        while ($true) {
            $line = $reader.ReadLine()
            if ($line -eq "" -or $line -eq $null) { break }
        }
        
        $localPath = $rawPath
        if ($localPath -eq "/") { $localPath = "/schedule_v103.html" }
        
        $filePath = Join-Path $folder $localPath.TrimStart("/")
        
        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath)
            $mime = Get-MimeType $ext
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            
            $header = "HTTP/1.1 200 OK`r`n" +
                      "Content-Type: $mime`r`n" +
                      "Content-Length: $($bytes.Length)`r`n" +
                      "Access-Control-Allow-Origin: *`r`n" +
                      "Cache-Control: no-cache`r`n" +
                      "Connection: close`r`n`r`n"
            
            $headerBytes = $utf8.GetBytes($header)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            $stream.Write($bytes, 0, $bytes.Length)
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 200 $localPath" -ForegroundColor Green
        } else {
            $body = "<h1>404 Not Found</h1><p>$localPath</p>"
            $bodyBytes = $utf8.GetBytes($body)
            $header = "HTTP/1.1 404 Not Found`r`n" +
                      "Content-Type: text/html; charset=utf-8`r`n" +
                      "Content-Length: $($bodyBytes.Length)`r`n" +
                      "Connection: close`r`n`r`n"
            
            $headerBytes = $utf8.GetBytes($header)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            $stream.Write($bodyBytes, 0, $bodyBytes.Length)
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 404 $localPath" -ForegroundColor Red
        }
        
        $stream.Flush()
        $stream.Close()
        $client.Close()
    } catch {
        if ($_.Exception.Message -match "interrupted") { break }
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

$listener.Stop()
