#!/bin/csh

cat <<EOD | ../fly -q -o test.gif
new
size 256,256
fill 1,1,255,255,255
arc 128,128,180,180,0,360,0,0,0
fill 128,128,255,255,0
arc 128,128,120,120,0,180,0,0,0
arc 96,96,10,10,0,360,0,0,0
arc 160,96,10,10,0,360,0,0,0
fill 96,96,0,0,0
fill 160,96,0,0,0
EOD