#!/bin/bash

# Script version: 1.1.2

# TODO first of all: check if brew and all tools required are installed

# Check if optool is installed

OUTPUT=~/Desktop

if which optool >/dev/null; then
    #echo "optool is installed"
    echo
else
	echo "optool is NOT installed. Proceed with installation..."
  cd /usr/local/bin > /dev/null 2>&1
	sudo curl -OL https://github.com/alexzielenski/optool/releases/download/0.1/optool.zip > /dev/null 2>&1
	sudo unzip /usr/local/bin/optool.zip -d /usr/local/bin > /dev/null 2>&1
	sudo rm -rf optool.zip > /dev/null 2>&1
fi

# List all available apps:
echo "Only the following apps are *at the moment* supported:"
echo
echo
svn ls https://github.com/Sn0wCooder/Extensify-Exos/trunk | grep "/" | rev | cut -c2- | rev
echo
echo

# Initialization

echo "End directory: $OUTPUT"

TMPDIR=$(mktemp -d -t ci-XXXXXXXXXX)
cd $TMPDIR
#open $TMPDIR

echo "Insert here the decrypted IPA:"
read crackedipa

unzip `realpath "$crackedipa"` > /dev/null 2>&1

filename=$(basename Payload/*)
extension="${filename##*.}"
filename="${filename%.*}"

echo
echo
echo "Application selected: $filename"
echo
echo

# List exo(s)

echo "Choose the exo(s) you want:"
i=1
array=($(svn ls https://github.com/Sn0wCooder/Extensify-Exos/trunk/$filename | grep "/" | rev | cut -c2- | rev))
for (( length=1; length <= "${#array[@]}"; ++length )); do
    for (( start=0; start + length <= "${#array[@]}"; ++start )); do
        EXOS_AVAIL=$(echo "${array[@]:start:length}")
        echo "$i) $EXOS_AVAIL"
        echo $EXOS_AVAIL | tr " " "\n" >> $i
        ((i=i+1))
    done
done
last=$(( i - 1 ))
echo "$i) Exit"

# Now you have to choose the exo(s) you want:

OK=0
while [ $OK != 1 ]
do
  read opt
  case $opt in
    [1-$last] )
      OK=1
      echo "Good choice!"
      ;;
    $i )
      OK=1
      echo "Goodbye!"
      break
      ;;
    *)
      OK=0
      echo "Wrong choice. Retry."
      ;;
    esac
done

# Download exo(s) the user chose:

mkdir ToInject
cd ToInject

while read p; do
  echo "Downloading $p..."
  svn checkout https://github.com/Sn0wCooder/Extensify-Exos/trunk/$filename/$p > /dev/null 2>&1
  mv $p/* .
  rm -rf $p
done < ../$opt

# Inject dylib(s)

for DYLIB in ./*.dylib; do
  DYLIBNAME=$(basename $DYLIB)
  echo "Injecting $DYLIBNAME..."
  optool install -c load -p @executable_path/$DYLIBNAME -t ../Payload/*/$filename #> /dev/null 2>&1
done

# Move files

cd ..
mv ToInject/* Payload/*/

# Repack

echo "Repacking..."

exos=$(cat ./$opt)
exos=$(echo "${exos//$'\n'/_}")
zip -9qry "app.ipa" "Payload" > /dev/null 2>&1
BUNDLEVERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Payload/*/Info.plist)

newfilename=$filename-v$BUNDLEVERSION-$exos.ipa
newfilename=`echo $newfilename|tr '-' '_'`
mv app.ipa $OUTPUT/$newfilename

# Clean up
rm -rf $TMPDIR

echo "Finished!"
