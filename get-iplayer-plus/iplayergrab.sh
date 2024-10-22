#!/bin/bash

search_term=$1
output=$2



get_iplayer --type tv "Top of the Pops" --get --atomicparsley /usr/bin/atomicparsley --output "/mnt/media/libraries/tv/Top of the Pops/" --raw

get_iplayer --type tv "The Old Grey Whistle Test" --get --atomicparsley /usr/bin/atomicparsley --output "/mnt/media/libraries/tv/The Old Grey Whistle Test/" --raw
