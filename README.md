# Mediaslave

## Overview

A bundle of utilities to help automate, download, transcode and monitor media as part of your burgeoning media server. This repo began life as a couple of shell scripts used to move media files from one directory to another. They've now expanded into a set of utilities that I use when working on my own or other people's media servers.

## Main Functions

### Real Debrid Blackhole

A Docker container that watches a bind-mounted directory and automatically downloads any torrentfiles added to the directory using Real Debrid's torrent download facility through their API. If using Radarr or Sonarr, you can use this container as a blackhole destination for downloaded torrents. Torrent files will be automatically processed once downloaded, and moved to their permanent destination. **Full documentation will be added to the sub-directory README.md file in due course**.

### Get-iPlayer Plus

A set of scripts that make use of the ``get_iplayer`` cli tool to automate the downloading, tagging, transcoding and relocating of files from the BBC's iPlayer website.

### AV1encode

A fully-automated bulk transcoding script set. Although there are many different tools that attempt the same thing or something very similar, I found that there was a management overhead in organising media so that it could be transcoded efficiently. The core script uses Jellyfin's custom ``ffmpeg`` binary, ``libsvtav1`` AV1 codec and ``libopus`` audio library to transcode media files into ultra-slim, high quality files. Working with libraries of tens of thousands of files in some cases, the script can transcode files according to wide range of filters, presets and other options.

Although fully functional and extremely useful in their own right, there are a number of other scripts that are used to gain insight into the overall state of the library, the progress that's been made transcoding files, various stats and also helper scripts to automate the movement of files into their correct locations.

### AV1encode Script Details (in alphabetical order)

#### alphacount.sh

Counts the number of directories and files in a directory, and groups them by the first letter of the directory name. Lists AV1 transcoded files, non-transcoded files, duplicated files and totals for each character prefix as well as for the whole directory. 

Was written specifically to work with the directory structure of a movie library and needs adapting to work with TV libraries' season subdirs.

```bash
./alphacount.sh /mnt/media/libraries/movies --show-converted
1: 17/22            a: 327/387          j: 107/144          s: 18/505
2: 13/13            b: 329/375          k: 59/74            t: 146/1217
3: 3/11             c: 63/250           l: 173/208          u: 0/50
4: 2/5              d: 72/287           m: 276/338          v: 7/40
5: 0/3              e: 107/131          n: 89/103           w: 98/164
6: 1/4              f: 139/190          o: 52/97            x: 7/15
7: 2/2              g: 142/170          p: 195/246          y: 23/23
8: 1/3              h: 67/210           q: 9/9              z: 20/25
9: 5/5              i: 41/175           r: 36/205           non-alphanumeric: /6

Directories containing AV1 mp4 files: 2646/5712 (46%)
```

#### av1encode.sh

A fully-automated bulk transcoding script. Allows for various filters, presets and other options, and can be run on multiple nodes simultaneously to create AV1-encoded video files.

Requires a suitable build of ``ffmpeg``. The script calls Jellyfin's custom binary as ``ffmpeg-av1``. Other dependencies include ``libsvtav1`` and ``libopus``.

##### Usage

```bash
av1encode generate <dir>            # Generates master file list based on env vars"
av1encode convert [--starts-with=x] # Converts from master file list with optional prefix filter"
av1encode convertfile <file>        # Converts a single file"
av1encode convertdir <directory>    # Converts all unconverted video files found in the specified directory."
```

##### Example Job Output

```bash
Processing file 12/36
Receiving file /mnt/media/libraries/tv/Top of the Pops/Season 33/Top of the Pops - 1996-07-19 m00239nb original.ts
sending incremental file list
Top of the Pops - 1996-07-19 m00239nb original.ts
          1.15G 100%  109.85MB/s    0:00:09 (xfr#1, to-chk=0/1)
Encoding with progress bar...
394MiB 0:03:50 [1.32MiB/s] [==============>                             ]  36% ETA 0:06:05
```

#### countagain.sh

Generates bulk conversion stats and provides lists of files in CSV format.

```bash
countagain /mnt/media/libraries/movies /mnt/media                                                             ✔  48s

-------------------------------------------------------
  MOVIES:
  Total Dirs:                  5915
  Empty Dirs:                  768

  Total video files            5087
  Unconverted files:           2320
  AV1 converted files:         2767     54.39%

  Initial Library Size:        10,400,000 MB
  Last Library Size:            7,250,041 MB
  Current Library Size:         7,157,360 MB
  Difference vs Initial:        3,242,639 MB 31.18 smaller%
  Difference vs Last:              92,681 MB  1.28 smaller%

  Converted file list:         countagain_av1converted_files.csv
  Unconverted file list:       countagain_unconverted_files.csv
  All files list:              countagain_allmovies.csv
  Empty dir list:              countagain_empty_dirs.csv
-------------------------------------------------------
```

#### crossmove.sh

Cross-references files in a directory with the transcode log CSV file, and moves the files to the correct location.

#### hardlinkreplace.sh

Was used for a specific use case. Deletes hard links without removing files and then creates new hard links in the target directory.

#### jellydirformatter.sh

Comprehensive directory formatting script used to organise media files for Jellyfin, but is platform agnostic.

#### vidcheck.sh

Checks the integrity of video files with ffmpeg.
