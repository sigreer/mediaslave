# get_iplayer Documentation

## sigreer's 2024 Edition

[Original documentation](https://github.com/get-iplayer/get_iplayer/wiki/documentation) | [Project Repo](https://github.com/get-iplayer/get_iplayer)

## Usage

 ```bash
# List All Programmes:
get_iplayer [--type=<TYPE>] ".*"

# Search Programmes:
get_iplayer [--type=<TYPE>] <REGEX>

# Record Programmes by Search:
get_iplayer [--type=<TYPE>] <REGEX> --get

# Record Programmes by Index:
get_iplayer <INDEX> --get

# Record Programmes by URL:
get_iplayer "<URL>"

# Record Programmes by PID:
get_iplayer --pid=<PID>

# Update get_iplayer cache:
get_iplayer --refresh [--type=<TYPE>]

# Basic Help:
get_iplayer --basic-help
```

### Search Options

| Option | Description |
| ---------- | ------------------------------------------------------------------------------------------------ |
| ``--available-before <hours>`` |                         Limit search to programmes that became available before \<hours\> hours ago |
| ``--available-since <hours>`` | Limit search to programmes that have become available in the last \<hours\> hours |
| ``--before <hours>`` | Limit search to programmes added to the cache before \<hours\> hours ago |
| ``--category <string>`` | Narrow search to matched categories (comma-separated regex list).  Defaults to substring match.  Only works with --history. |
| ``--channel <string>`` | Narrow search to matched channel(s) (comma-separated regex list).  Defaults to substring match. |
| ``--exclude <string>`` | Narrow search to exclude matched programme names (comma-separated regex list).  Defaults to substring match. |
| ``--exclude-category <string>`` | Narrow search to exclude matched categories (comma-separated regex list).  Defaults to substring match.  Only works with --history. |
| ``--exclude-channel <string>`` | Narrow search to exclude matched channel(s) (comma-separated regex list).  Defaults to substring match. |
| ``--expires-after <hours>`` | Limit search to programmes that will expire after \<hours\> hours from now |
| ``--expires-before <hours>`` | Limit search to programmes that will expire before \<hours\> hours from now |
| ``--fields <field1>,<field2>,...`` | Searches only in the specified fields. The fields are concatenated with spaces in the order specified and the search term is applied to the resulting string. |
| ``--future`` | Additionally search future programme schedule if it has been indexed (refresh cache with: ``--refresh`` ``--refresh-future``). |
| ``--history`` | Search recordings history (requires search term) |
| ``--long, -l`` | Additionally search in programme descriptions and episode names (same as ``--fields=name,episode,desc``) |
| ``--search <search term>`` | GetOpt compliant way of specifying search args |
| ``--since <hours>`` | Limit search to programmes added to the cache in the last \<hours\> hours |
| ``--type <type>,<type>,...`` | Only search in these types of programmes: ``tv``,``radio``,``all`` (``tv`` is default) |

### Display Options

| Option | Description |
| ---------- | ------------------------------------------------------------------------------------------------ |
| ``--conditions`` | Shows GPLv3 conditions |
| ``--debug`` | Debug output (very verbose and rarely useful) |
| ``--dump-options`` | Dumps all options with their internal option key names |
| ``--help, -h`` | Intermediate help text |
| ``--helpbasic, --usage`` | Basic help text |
| ``--helplong`` | Advanced help text |
| ``--hide`` | Hide previously recorded programmes |
| ``--info, -i`` | Show full programme metadata and availability of streams and subtitles (max 40 matches) |
| ``--list <element>`` | Show a list of distinct element values (with counts) for the selected programme type(s) and exit.  Valid elements are: ``channel`` |
| ``--listformat <format>`` | Display search results with a custom format. Use substitution parameters in format string (see docs for list). |
| ``--long, -l`` | Show extended programme info |
| ``--manpage <file>`` | Create man page based on current help text |
| ``--nocopyright`` | Don't display copyright header |
| ``--page <number>`` | Page number to display for multipage output |
| ``--pagesize <number>`` | Number of matches displayed on a page for multipage output |
| ``--quiet, -q`` | Reduce logging output |
| ``--series`` | Display programme series names only with number of episodes |
| ``--show-cache-age`` | Display the age of the selected programme caches then exit |
| ``--show-options`` | Show options which are set and where they are defined |
| ``--silent`` | No logging output except PVR download report.  Cannot be saved in preferences or PVR searches |
| ``--sort <fieldname>`` | Field to use to sort displayed matches |
| ``--sortreverse`` | Reverse order of sorted matches |
| ``--streaminfo`` | Returns all of the media stream URLs of the programme(s) |
| ``--terse`` | Only show terse programme info (does not affect searching) |
| ``--tree`` | Display programme listings in a tree view |
| ``--verbose, -v`` | Show additional output (useful for diagnosing problems) |
| ``--warranty`` | Displays warranty section of GPLv3 |
| ``-V`` | Show ``get_iplayer`` version and exit. |

### Recording Options

| Option | Description |
| ---------- | ------------------------------------------------------------------------------------------------ |
| ``--attempts <number>`` | Number of attempts to make or resume a failed connection.  ``--attempts`` is applied per-stream. Programmes have multiple streams available for each recording quality. |
| ``--audio-only`` | Only download audio stream for TV programme. Produces .m4a file. Implies ``--force``. |
| ``--download-abort-onfail`` | Exit immediately if any stream fails to download. Use to avoid repeated failed download attempts if connection is dropped or access is blocked. |
| ``--exclude-format <format>,<format>,...`` | Comma-separated list of media stream formats to ignore when recording. Valid values: hls,dash. |
| ``--exclude-supplier <supplier>,<supplier>,...`` | Comma-separated list of media stream suppliers (CDNs) to skip. Possible values: akamai,limelight,bidi,cloudfront. Synonym: --exclude-cdn. |
| ``--force`` | Ignore programme history (unsets --hide option also). |
| ``--get, -g`` | Start recording matching programmes. Search terms required. |
| ``--hash`` | Show recording progress as hashes |
| ``--include-format <format>,<format>,...`` | Comma-separated list of media stream to use when recording. Overrides --exclude-format. Valid values: hls,dash |
| ``--include-supplier <supplier>,<supplier>,...`` | Comma-separated list of media stream suppliers (CDNs) to use if not included by default or if previously excluded by --exclude-supplier. Possible values: akamai,limelight,bidi,cloudfront. Synonym: --include-cdn. |
| ``--log-progress`` | Force HLS/DASH download progress display to be captured when screen output is redirected to file.  Progress display is normally omitted unless writing to terminal. |
| ``--mark-downloaded`` | Mark programmes in search results or specified with --pid/--url as downloaded by inserting records in download history. |
| ``--no-merge-versions`` | Do not merge programme versions with same name and duration. |
| ``--no-proxy`` | Ignore --proxy setting in preferences and/or http_proxy environment variable. |
| ``--no-resume`` | Do not resume partial HLS/DASH downloads. |
| ``--no-verify`` | Do not verify size of downloaded HLS/DASH file segments or file resize upon resume. |
| ``--overwrite`` | Overwrite recordings if they already exist |
| ``--partial-proxy`` | Only uses web proxy where absolutely required (try this extra option if your proxy fails). |
| ``--pid <pid>,<pid>,...`` | Record arbitrary PIDs that do not necessarily appear in the index. |
| ``--pid-index`` | Update (if necessary) and use programme index cache with ``--pid``. Cache is not searched for programme by default with ``--pid``. Synonym: ``--pid-refresh``. |
| ``--pid-recursive`` | Record all related episodes if value of ``--pid`` is a series or brand PID.  Requires ``--pid``. |
| ``--pid-recursive-list`` | If value of ``--pid`` is a series or brand PID, list available episodes but do not download. Implies ``--pid-recursive``. Requires ``--pid``. |
| ``--pid-recursive-type <type>`` | Download only programmes of ``<type>`` (``radio`` or ``tv``) with ``--pid-recursive``. Requires ``--pid-recursive``. |
| ``--proxy, -p <url>`` | Web proxy URL, e.g., ``http://username:password@server:port`` or ``http://server:port``.  Value of ``http_proxy`` environment variable (if present) will be used unless ``--proxy`` is specified. Used for both HTTP and HTTPS. Overridden by ``--no-proxy``. |
| ``--quality <quality>,<quality>,...`` | TV and radio recording quality preference.  See ``--tv-quality`` and ``--radio-quality`` for available values and defaults. Default: default for programme type. |
| ``--radio-quality <quality>,<quality>,...`` | Radio recording quality preference (overrides ``--quality``): ``high,std,med,low,default`` (Aliases: ``320k,128k,96k,48k``). Comma-delimited list in descending order of preference. Default: ``high,std,med,low``. |
| ``--start <secs\|hh:mm:ss>`` | Recording/streaming start offset (actual start may be several seconds earlier for HLS and DASH streams) |
| ``--stop <secs\|hh:mm:ss>`` | Recording/streaming stop offset (actual stop may be several seconds later for HLS and DASH streams) |
| ``--subtitles-required`` | Do not download TV programme if subtitles are not available. |
| ``--test, -t`` | Test only - no recording (only shows search results with ``--pvr`` and ``--pid-recursive``) |
| ``--tv-lower-bitrate``, ``--tvlbr`` | Prefer 25fps (or lower-bitrate 50fps) streams for TV programmes if available. |
| ``--tv-quality <quality>,<quality>,...`` | TV recording quality preference (overrides ``--quality``): ``fhd,hd,sd,web,mobile,default`` (Aliases: ``1080p,720p,540p,396p,288p``). Comma-delimited list in descending order of preference. Default: ``hd,sd,web,mobile`` |
| ``--url <url>,<url>,...`` | Record the PIDs contained in the specified iPlayer episode URLs. Alias for ``--pid``. |
| ``--versions <versions>`` | Version of programme to record. List is processed from left to right and first version found is downloaded. Example: ``--versions=audiodescribed,default`` will prefer audio-described programmes if available. Versions: ``default``, ``audiodescribed``, ``signed``, ``combined``. Default: ``default``. |

### Output Options

| Option | Description |
| ---------- | ------------------------------------------------------------------------------------------------ |
| ``--command, -c <command>`` | User command to run after successful recording of programme. Use substitution parameters in command string (see docs for list). |
| ``--command-radio <command>`` | User command to run after successful recording of radio programme. Use substitution parameters in command string (see docs for list). Overrides ``--command``. |
| ``--command-tv <command>`` | User command to run after successful recording of TV programme. Use substitution parameters in command string (see docs for list). Overrides --command. |
| ``--credits`` | Download programme credits, if available. |
| ``--credits-only`` | Only download programme credits, if available. |
| ``--cuesheet`` | Create cue sheet (.cue file) for programme, if data available. Radio programmes only. Cue sheet will be very inaccurate and will required further editing. Cue sheet may require addition of UTF-8 BOM (byte-order mark) for some applications to identify encoding. |
| ``--cuesheet-offset [-]<offset>`` | Offset track times in cue sheet and track list by the specified number of seconds. Synonym: --tracklist-offset |
| ``--cuesheet-only`` | Only create cue sheet (.cue file) for programme, if data available. Radio programmes only. |
| ``--file-prefix <format>`` | The filename prefix template (excluding dir and extension). Use substitution parameters in template (see docs for list). Default: \<name\> - \<episode\> \<pid\> \<version\> |
| ``--limitprefixlength <length>`` | The maximum length for a file prefix.  Defaults to 240 to allow space within standard 256 limit. |
| ``--metadata`` | Create metadata info file after recording. Valid values: generic,json. XML generated for 'generic', JSON for 'json'. If no value specified, 'generic' is used. |
| ``--metadata-only`` | Create specified metadata info file without any recording or streaming. |
| ``--mpeg-ts`` | Ensure raw audio and video files are re-muxed into MPEG-TS file regardless of stream format. Overrides --raw. |
| ``--no-metadata`` | Do not create metadata info file after recording (overrides --metadata). |
| ``--no-sanitise`` | Do not sanitise output file and directory names. Implies --whitespace. Invalid characters for Windows ("*:<>?\|) and macOS (:) will be removed. |
| ``--output, -o <dir>`` | Recording output directory |
| ``--output-radio <dir>`` | Output directory for radio recordings (overrides --output) |
| ``--output-tv <dir>`` | Output directory for tv recordings (overrides --output) |
| ``--raw`` | Don't remux or change the recording in any way.  Saves output file in native container format (HLS->MPEG-TS, DASH->MP4) |
| ``--subdir, -s`` | Save recorded files into subdirectory of output directory.  Default: same name as programme (see --subdir-format). |
| ``--subdir-format <format>`` | The format to be used for subdirectory naming.  Use substitution parameters in format string (see docs for list). |
| ``--suboffset <offset>`` | Offset the subtitle timestamps by the specified number of milliseconds.  Requires --subtitles. |
| ``--subs-embed`` | Embed soft subtitles in MP4 output file. Ignored with --audio-only and --ffmpeg-obsolete. Requires --subtitles. Implies --subs-mono. |
| ``--subs-mono`` | Create monochrome titles, with leading hyphen used to denote change of speaker. Requires --subtitles. Not required with --subs-embed. |
| ``--subs-raw`` | Additionally save the raw subtitles file.  Requires --subtitles. |
| ``--subtitles`` | Download subtitles into srt/SubRip format if available and supported |
| ``--subtitles-only`` | Only download the subtitles, not the programme |
| ``--tag-only`` | Only update the programme metadata tag and not download the programme. Use with --history or --tag-only-filename. |
| ``--tag-only-filename <filename>`` | Add metadata tags to specified file (ignored unless used with --tag-only) |
| ``--thumb`` | Download thumbnail image if available |
| ``--thumb-ext <ext>`` | Thumbnail filename extension to use |
| ``--thumbnail-only`` | Only download thumbnail image if available, not the programme |
| ``--thumbnail-series`` | Force use of series/brand thumbnail (series preferred) instead of episode thumbnail |
| ``--thumbnail-size <width>`` | Thumbnail size to use for the current recording and metadata. Specify width: 192,256,384,448,512,640,704,832,960,1280,1920. Invalid values will be mapped to nearest available. Default: 1920 (1280 with --thumbnail-square) |
| ``--thumbnail-square`` | Download square version of thumbnail image. Limits --thumbnail-size to 1280 |
| ``--tracklist`` | Create track list of music played in programme, if data available. Track times and durations may be missing or incorrect. |
| ``--tracklist-only`` | Only create track list of music played in programme, if data available. |
| ``--whitespace, -w`` | Keep whitespace in file and directory names.  Default behaviour is to replace whitespace with underscores. |

### PVR Options

| Option | Description |
|--|--|
| ``--comment <string>`` | Adds a comment to a PVR search |
| ``--pvr <search name>`` | Runs the PVR using all saved PVR searches (intended to be run periodically, e.g., from cron or Task Manager). The list can be limited by adding a regex to the command. Synonyms: --pvrrun, --pvr-run |
| ``--pvr-add <search name>`` | Save the named PVR search with the specified search terms. Search terms required unless --pid specified. Synonyms: --pvradd |
| ``--pvr-del <search name>`` | Remove the named search from the PVR searches. Synonyms: --pvrdel |
| ``--pvr-disable <search name>`` | Disable (not delete) a named PVR search. Synonyms: --pvrdisable |
| ``--pvr-enable <search name>`` | Enable a previously disabled named PVR search. Synonyms: --pvrenable |
| ``--pvr-exclude <string>`` | Exclude the PVR searches to run by search name (comma-separated regex list). Defaults to substring match. Synonyms: --pvrexclude |
| ``--pvr-list`` | Show the PVR search list. Synonyms: --pvrlist |
| ``--pvr-queue`` | Add currently matched programmes to queue for later one-off recording using the --pvr option. Search terms required unless --pid specified. Synonyms: --pvrqueue |
| ``--pvr-scheduler <seconds>`` | Runs the PVR using all saved PVR searches every \<seconds\>. Synonyms: --pvrscheduler |
| ``--pvr-series`` | Create PVR search for each unique series name in search results. Search terms required. Synonyms: --pvrseries |
| ``--pvr-single <search name>`` | Runs a named PVR search. Synonyms: --pvrsingle |

### Config Options

| Option | Description |
|--|--|
| ``--cache-rebuild`` | Rebuild cache with full 30-day programme index. Use --refresh-limit to restrict cache window. |
| ``--expiry, -e <secs>`` | Cache expiry in seconds (default 4hrs) |
| ``--limit-matches <number>`` | Limits the number of matching results for any search (and for every PVR search) |
| ``--prefs-add`` | Add/Change specified saved user or preset options |
| ``--prefs-clear`` | Remove *ALL* saved user or preset options |
| ``--prefs-del`` | Remove specified saved user or preset options |
| ``--prefs-show`` | Show saved user or preset options |
| ``--preset, -z <name>`` | Use specified user options preset |
| ``--preset-list`` | Show all valid presets |
| ``--profile-dir <dir>`` | Override the user profile directory |
| ``--refresh`` | Refresh cache |
| ``--refresh-abort-onerror`` | Abort cache refresh for programme type if data for any channel fails to download.  Use --refresh-exclude to temporarily skip failing channels. |
| ``--refresh-exclude <channel>,<channel>,...`` | Exclude matched channel(s) when refreshing cache (comma-separated regex list).  Defaults to substring match.  Overrides --refresh-include-groups[-{tv,radio}] status for specified channel(s) |
| ``--refresh-exclude-groups <group>,<group>,...`` | Exclude channel groups when refreshing radio or TV cache (comma-separated values).  Valid values: 'national', 'regional', 'local' |
| ``--refresh-exclude-groups-radio <group>,<group>,...`` | Exclude channel groups when refreshing radio cache (comma-separated values).  Valid values: 'national', 'regional', 'local' |
| ``--refresh-exclude-groups-tv <group>,<group>,...`` | Exclude channel groups when refreshing TV cache (comma-separated values).  Valid values: 'national', 'regional', 'local' |
| ``--refresh-future`` | Obtain future programme schedule when refreshing cache |
| ``--refresh-include <channel>,<channel>,...`` | Include matched channel(s) when refreshing cache (comma-separated regex list).  Defaults to substring match.  Overrides --refresh-exclude-groups[-{tv,radio}] status for specified channel(s) |
| ``--refresh-include-groups <group>,<group>,...`` | Include channel groups when refreshing radio or TV cache (comma-separated values).  Valid values: 'national', 'regional', 'local' |
| ``--refresh-include-groups-radio <group>,<group>,...`` | Include channel groups when refreshing radio cache (comma-separated values).  Valid values: 'national', 'regional', 'local' |
| ``--refresh-include-groups-tv <group>,<group>,...`` | Include channel groups when refreshing TV cache (comma-separated values).  Valid values: 'national', 'regional', 'local' |
| ``--refresh-limit <days>`` | Minimum number of days of programmes to cache. Default: 7 Min: 1 Max: 30 |
| ``--refresh-limit-radio <days>`` | Number of days of radio programmes to cache. Default: 7 Min: 1 Max: 30 |
| ``--refresh-limit-tv <days>`` | Number of days of TV programmes to cache. Default: 7 Min: 1 Max: 30 |
| ``--skipdeleted`` | Skip the download of metadata/thumbs/subs if the media file no longer exists.  Use with --history & --metadataonly/subsonly/thumbonly. |
| ``--webrequest <urlencoded string>`` | Specify all options as a urlencoded string of "name=val&name=val&..." |

### External Program Options

| Option | Description |
|--|--|
| ``--atomicparsley <path>`` | Location of AtomicParsley binary |
| ``--ffmpeg <path>`` | Location of ffmpeg binary. Assumed to be ffmpeg 3.0 or higher unless --ffmpeg-obsolete is specified. |
| ``--ffmpeg-force`` | Bypass version checks and assume ffmpeg is version 3.0 or higher |
| ``--ffmpeg-loglevel <level>`` | Set logging level for ffmpeg. Overridden by --quiet and --silent. Default: 'fatal' |
| ``--ffmpeg-obsolete`` | Indicates you are using an obsolete version of ffmpeg (<1.0) that may not support certain options. Without this option, MP4 conversion may fail with obsolete versions of ffmpeg. |

### Tagging Options

| Option | Description |
| -- | ---- |
| ``--no-artwork`` | Do not embed thumbnail image in output file. Also removes existing artwork. All other metadata values will be written. |
| ``--no-tag`` | Do not tag downloaded programmes. |
| ``--tag-credits`` | Add programme credits (if available) to long description field. |
| ``--tag-encoding <name>`` | (Windows only) Single-byte character encoding for non-ASCII characters in metadata tags. Encoding name must be known to Perl Encode module. Unicode (UTF\* or UCS\*) character encodings are not supported. Default: active code page or cp1252 (Windows code page 1252) |
| ``--tag-format-show`` | Format template for programme name in tag metadata. Use substitution parameters in template (see docs for list). Default: \<name\> |
| ``--tag-format-title`` | Format template for episode title in tag metadata. Use substitution parameters in template (see docs for list). Default: \<episodeshort\> |
| ``--tag-isodate`` | Use ISO8601 dates (YYYY-MM-DD) in album/show names and track titles |
| ``--tag-no-unicode`` | (Windows only) Do not attempt to perform Unicode tagging and use single-byte character encoding instead (see --tag-encoding) |
| ``--tag-podcast`` | Tag downloaded radio and tv programmes as iTunes podcasts (incompatible with Music/Podcasts/TV apps on macOS 10.15 and higher) |
| ``--tag-podcast-radio`` | Tag only downloaded radio programmes as iTunes podcasts (incompatible with Music/Podcasts/TV apps on macOS 10.15 and higher) |
| ``--tag-podcast-tv`` | Tag only downloaded tv programmes as iTunes podcasts (incompatible with Music/Podcasts/TV apps on macOS 10.15 and higher) |
| ``--tag-tracklist`` | Add track list of music played in programme (if available) to lyrics field. |

### Misc Options

| Option | Description |
| -- | ---- |
| ``--encoding-console-in <name>`` | Character encoding for standard input (currently unused).  Encoding name must be known to Perl Encode module.  Default (only if auto-detect fails): Linux/Unix/macOS = UTF-8, Windows = cp850 |
| ``--encoding-console-out <name>`` | Character encoding used to encode search results and other output.  Encoding name must be known to Perl Encode module.  Default (only if auto-detect fails): Linux/Unix/macOS = UTF-8, Windows = cp850 |
| ``--encoding-locale <name>`` | Character encoding used to decode command-line arguments.  Encoding name must be known to Perl Encode module.  Default (only if auto-detect fails): Linux/Unix/OSX = UTF-8, Windows = cp1252 |
| ``--encoding-locale-fs <name>`` | Character encoding used to encode file and directory names.  Encoding name must be known to Perl Encode module.  Default (only if auto-detect fails): Linux/Unix/macOS = UTF-8, Windows = cp1252 |
| ``--encoding-webrequest <name>`` | Character encoding used to encode commands sent from Web PVR.  Encoding name must be known to Perl Encode module.  Default = UTF-8 |
| ``--index-maxconn <number>`` | Maximum number of connections to use for concurrent programme indexing.  Default: 5 Min: 1 Max: 10 |
| ``--release-check`` | Forces check for new release if used on command line. Checks for new release weekly if saved in preferences. |
| ``--throttle <Mb/s>`` | Bandwidth limit (in Mb/s) for media file download. Default: unlimited. Synonym: --bw |

### Deprecated Options

| Option | Description |
| -- | ---- |
| ``--no-index-concurrent`` | Do not use concurrent indexing to update programme cache.  Cache updates will be very slow. |

#### Terms and conditions

> Copyright (C) 2008-2010 Phil Lewis, 2010- get_iplayer contributors
> This program comes with ABSOLUTELY NO WARRANTY; for details use --warranty.
> This is free software, and you are welcome to redistribute it under certain
> conditions; use ``--conditions`` for details.
