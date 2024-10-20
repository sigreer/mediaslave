# mediaslave-scripts

## Overview

Various shell and python scripts for automating the management and transcoding of video files for media servers.

## Script Details

### alphacount.sh

Counts the number of directories and files in a directory, and groups them by the first letter of the directory name.

### av1encode.sh

A fully-automated bulk transcoding script. Allows for various filters, presets and other options, and can be run on multiple nodes simultaneously to create AV1-encoded video files.

Requires a suitable build of ``ffmpeg``. The script calls Jellyfin's custom binary as ``ffmpeg-av1``. Other dependencies include ``libsvtav1`` and ``libopus``.

### countagain.sh

Generates bulk conversion stats and provides lists of files in CSV format.

### crossmove.sh

Cross-references files in a directory with the transcode log CSV file, and moves the files to the correct location.

### hardlinkreplace.sh

Was used for a specific use case. Deletes hard links without removing files and then creates new hard links in the target directory.

### iplayergrab.sh

Uses get_iplayer to download TV shows, movies and radio shows from the BBC iPlayer website and manages the post-processing of the files.

### vidcheck.sh

Checks the integrity of video files with ffmpeg.
