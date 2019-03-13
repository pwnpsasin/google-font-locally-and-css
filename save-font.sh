#!/bin/bash

##
## Google Font - save to disk locally and prepare css file
## @2019 Pawel Sasin

## Requirements: npm install uglifycss -g, curl with ssl, sed, awk, md5sum

## All params
#  COLLECTION="100 100i 200 200i 300 300i 400 400i 500 500i 600 600i 700 700i 800 800i 900 900"
#  FAMILY="cyrillic,cyrillic-ext,greek,greek-ext,latin-ext,vietnamese"
#  FONT="Fira+Sans"


## For example:
## <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Fira+Sans:300,300i,400,500,600&subset=latin-ext">

COLLECTION="300 300i 400 500 600 700"
FAMILY="latin-ext"
FONT="Fira+Sans"


######## ========================================================================================= #######

rm ./*.tmp
rm ./*.css

if [ -d ./tmp ]; then
    rm -rf ./tmp
fi

if [ -d ./fnt ]; then
    rm -rf ./fnt
fi


if [ ! -d ./tmp ]; then
    mkdir ./tmp
fi

if [ ! -d ./fnt ]; then
    mkdir ./fnt
fi


## SVG
AGENT="Mozilla/4.0 (iPad; CPU OS_4_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko)"
for s in $COLLECTION; do
   curl -A "$AGENT" "https://fonts.googleapis.com/css?family=$FONT:$s&amp;subset=$FAMILY" -o ./tmp/tmp-svg-$s.css
done;

## EOT
AGENT="IE9"
for s in $COLLECTION; do
   curl -A "$AGENT" "https://fonts.googleapis.com/css?family=$FONT:$s&amp;subset=$FAMILY" -o ./tmp/tmp-eot-$s.css
done;

## TTF
AGENT="Android 4"
for s in $COLLECTION; do
   curl -A "$AGENT" "https://fonts.googleapis.com/css?family=$FONT:$s&amp;subset=$FAMILY" -o ./tmp/tmp-ttf-$s.css
done;


## WOFF2
AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.119 Safari/537.36"
for s in $COLLECTION; do
   curl -A "$AGENT" "https://fonts.googleapis.com/css?family=$FONT:$s&amp;subset=$FAMILY" -o ./tmp/tmp-woff2-$s.css
done;

## WOFF
AGENT="Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0"
for s in $COLLECTION; do
   curl -A "$AGENT" "https://fonts.googleapis.com/css?family=$FONT:$s&amp;subset=$FAMILY" -o ./tmp/tmp-woff-$s.css
done;


 cat ./tmp/tmp-*.css | egrep -o "https://.*" | sed "s/) format('/ /" | sed "s/');//"  | sed 's/);//g' | awk '{print $1}'   > links.tmp;
 : > md5links.tmp; for i in $(cat links.tmp); do M=$(echo $i | md5sum| sed 's/-//' | sed 's/ //g'); echo $i $M.fnt >> md5links.tmp; done;

 while IFS='' read -r line || [[ -n "$line" ]]; do
   LINK=$(echo $line | awk '{print $1}')
   NAME=$(echo $line | awk '{print $2}')
   echo $LINK $NAME
   curl -o ./fnt/$NAME $LINK
done < md5links.tmp;

cat ./tmp/* > font.css;

sed -i "s,@font-face {,@font-face {\n  font-display: swap;,g" font.css;


while IFS='' read -r line || [[ -n "$line" ]]; do
  LINK=$(echo $line | awk '{print $1}')
  NAME=$(echo $line | awk '{print $2}')
  echo $LINK $NAME
  sed -i "s,$LINK,'fnt/$NAME',g" font.css
done < md5links.tmp;

uglifycss font.css --output font.min.css;
