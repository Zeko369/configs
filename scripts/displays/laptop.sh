#!/bin/sh

LIST="$(displayplacer list)"

if [[ "$LIST" == *"2A9F7159-CE93-954E-0857-D6964E3302DB"* ]]; then
  displayplacer "id:2A9F7159-CE93-954E-0857-D6964E3302DB res:3840x1600 hz:120 color_depth:7 scaling:off origin:(0,0) degree:0" "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1280x800 hz:60 color_depth:8 scaling:on origin:(1236,1600) degree:0"
else
  displayplacer "id:58A2CDA4-CD64-CCFA-0857-D6964E3302DB res:3440x1440 hz:165 color_depth:7 scaling:off origin:(0,0) degree:0" "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1280x800 hz:60 color_depth:8 scaling:on origin:(1055,1440) degree:0"
fi
