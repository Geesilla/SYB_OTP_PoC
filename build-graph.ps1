$ErrorActionPreference = 'Stop'
$dataDir = Join-Path $PSScriptRoot 'data'
$gtfs = Join-Path $dataDir 'itm_yorkshire_gtfs.zip'
$osm = Join-Path $dataDir 'south-yorkshire-261015.osm.pbf'

if (!(Test-Path $gtfs)) { throw "Missing $gtfs. Download the BODS GTFS archive and save it with this filename." }
if (!(Test-Path $osm)) { throw "Missing $osm. Download an OSM .pbf extract covering South Yorkshire and save it with this filename." }

# OTP expects GTFS and OSM input files in /var/opentripplanner.
# A 6 GB Java heap is a starting point, not a guarantee; lower it if Docker has less memory available.
Write-Host 'Building OTP graph. This may take several minutes and use substantial memory.' -ForegroundColor Cyan
docker run --rm `
  -e JAVA_TOOL_OPTIONS='-Xmx6G' `
  -v "${dataDir}:/var/opentripplanner" `
  docker.io/opentripplanner/opentripplanner:latest `
  --build --save 
if ($LASTEXITCODE -ne 0) { throw "OTP graph build failed with exit code $LASTEXITCODE. Save the full output for diagnosis." }
Write-Host 'Graph build command completed. Check that data/graph.obj exists before starting OTP.' -ForegroundColor Green
