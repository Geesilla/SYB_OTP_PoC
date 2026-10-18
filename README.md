# SYB Journey Planner — OTP Proof of Concept

## Goal
Prove that OpenTripPlanner (OTP) can build a routable graph from a South Yorkshire BODS GTFS timetable plus OpenStreetMap street data, then return a plausible scheduled bus journey.

This is a **scheduled-routing-only first test**. It does not yet test live bus locations, fares, tram/rail, the website, or production hosting.

## Prerequisites
- Windows 10/11
- Docker Desktop running (Linux containers)
- Ideally 8 GB+ RAM available to Docker for the initial graph build; if memory is limited, start with a smaller extract/test feed.
- Internet access to download the two data files.

## 1. Get the input data
Put both files in the `data` folder:

1. **South Yorkshire/regional GTFS timetable from BODS** — download the appropriate regional GTFS archive from the official BODS data downloads portal. Keep it as a ZIP and rename it to `south-yorkshire.gtfs.zip` (do not unzip it).
2. **OpenStreetMap extract covering South Yorkshire** — download a suitable regional `.osm.pbf` extract from Geofabrik or another appropriate OSM source. Name it `south-yorkshire.osm.pbf`.

The GTFS archive must actually contain South Yorkshire routes/stops; renaming a file does not make it regional. If the BODS download is a national feed, it may be too large for a laptop PoC. Record the source URL and download date in `DATA-SOURCES.md`.

## 2. Check the folder
The structure should be:

```text
SYB_OTP_PoC/
  data/
    south-yorkshire.gtfs.zip
    south-yorkshire.osm.pbf
  DATA-SOURCES.md
  README.md
  build-graph.ps1
  start-otp.ps1
  stop-otp.ps1
```

OTP detects GTFS files by both the `.zip` extension and `gtfs` in the filename. It needs OSM street data as well as transit data to create a usable journey-planning graph.

## 3. Build the graph
Open PowerShell in this folder and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\build-graph.ps1
```

The first run downloads the OTP container image if it is not already present. Graph building can take several minutes and may use substantial RAM. The script saves the graph as `data/graph.obj`.

If it fails, save the full console output and inspect the graph-build report/logs before changing configuration. Do not proceed to live data until this step passes.

## 4. Start OTP

```powershell
.\start-otp.ps1
```

Then open **http://localhost:8080**. Use the built-in OTP interface to search between two known South Yorkshire bus stops at a date/time covered by the timetable.

To stop the server:

```powershell
.\stop-otp.ps1
```

## 5. Pass/fail criteria

**Pass** only if all are true:
- OTP builds and saves a graph without fatal errors.
- The graph includes South Yorkshire bus stops/routes from the chosen GTFS feed.
- A journey between two known stops returns at least one plausible scheduled itinerary.
- The itinerary's service date/time and route are consistent with the source timetable.

**Fail / investigate** if the graph has no transit stops, the feed is outside the region, the timetable is expired/not active for the selected date, or OTP cannot link transit stops to walkable streets. Capture the build log and the exact origin, destination and query time.

## 6. What we record for the feasibility gate
Fill in these fields after the run:
- GTFS source URL and download date:
- GTFS file size:
- OSM source URL and download date:
- OSM file size:
- PC RAM / Docker memory limit:
- Graph build duration:
- Graph size:
- Build warnings/errors:
- Origin stop:
- Destination stop:
- Query date/time:
- Itinerary returned (yes/no):
- Correct route and timing (yes/no/unknown):
- Approximate hands-on effort:

## 7. Next stage (not part of this first run)
Only after scheduled routing passes, test a sample BODS real-time feed and determine whether the format and trip identifiers match the static GTFS trips. A feed's update interval (for example, 10 seconds) is not the same thing as the permitted API polling frequency. Keep live-data requests out of this first test.

## Official references
- OTP container image and quick start: https://docs.opentripplanner.org/en/latest/Container-Image/
- OTP configuration and input-file conventions: https://docs.opentripplanner.org/en/latest/Configuration/
- BODS downloads portal: https://data.bus-data.dft.gov.uk/downloads/
- Geofabrik downloads: https://download.geofabrik.de/europe/great-britain.html
