$ErrorActionPreference = 'Stop'
$dataDir = Join-Path $PSScriptRoot 'data'
$graph = Join-Path $dataDir 'graph.obj'
if (!(Test-Path $graph)) { throw "No graph.obj found in data. Run .\build-graph.ps1 first." }

# Remove a previous container with the same name, if present.
docker rm -f syb-otp-poc 2>$null | Out-Null
Write-Host 'Starting OTP on http://localhost:8080 ...' -ForegroundColor Cyan
docker run -d --name syb-otp-poc -p 8080:8080 `
  -e JAVA_TOOL_OPTIONS='-Xmx4G' `
  -v "${dataDir}:/var/opentripplanner" `
  docker.io/opentripplanner/opentripplanner:latest `
    --load --serve 
if ($LASTEXITCODE -ne 0) { throw "OTP failed to start. Check Docker logs with: docker logs syb-otp-poc" }
Write-Host 'Container started. Allow a short time for startup, then open http://localhost:8080' -ForegroundColor Green
Write-Host 'If the page does not load, run: docker logs --tail 100 syb-otp-poc'
