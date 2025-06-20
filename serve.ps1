$port = 8000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Listening on http://localhost:$port"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    $filePath = Join-Path (Get-Location) $request.Url.LocalPath.TrimStart('/')
    
    if ($filePath -eq "") {
        $filePath = Join-Path (Get-Location) "index.html"
    }
    
    if (Test-Path $filePath) {
        $contentType = switch -regex ([System.IO.Path]::GetExtension($filePath)) {
            ".html" { "text/html" }
            ".css" { "text/css" }
            ".js" { "application/javascript" }
            ".png" { "image/png" }
            ".jpg" { "image/jpeg" }
            ".jpeg" { "image/jpeg" }
            ".gif" { "image/gif" }
            default { "application/octet-stream" }
        }
        
        $buffer = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentType = $contentType
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    } else {
        $response.StatusCode = 404
        $response.StatusDescription = "Not Found"
    }
    
    $response.Close()
}

$listener.Stop()
