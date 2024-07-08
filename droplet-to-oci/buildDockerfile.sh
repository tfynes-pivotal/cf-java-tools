#!/bin/sh

DIRECTORY=./temp
STAGINGINFO=$DIRECTORY/staging_info.yml
DROPLET=""
REQUIRED_FLAG_COUNT=0
REQUIRED_FLAG_COUNTER=1

usage() {
    echo "Usage: $0 -d <droplet>"
    echo "-d: Specify the full path of the droplet"
    exit 1
}

# Parse the options/flags
while getopts ":d:" opt; do
  case $opt in
    d)
      DROPLET="$OPTARG"
      ((REQUIRED_FLAG_COUNT++))
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

if [ $REQUIRED_FLAG_COUNTER != $REQUIRED_FLAG_COUNT ]; then
    usage
fi

if [ -f "$DROPLET" ]; then

    rm -rf $DIRECTORY
    mkdir $DIRECTORY
    cd $DIRECTORY 
    # Extracting droplet archive
    echo "Extracting droplet archive"
    tar zxf ${DROPLET}
    cd ..
else
    echo "File $DROPLET does not exist."
    exit 0
fi

# Building Dockerfile...
echo "Building Dockerfile..."
cat > ./Dockerfile << EOF
FROM paketobuildpacks/run-jammy-base:latest

EOF

echo "ENV CF_INSTANCE_GUID=17800b52-2857-4b1c-7428-e2fc" >> ./Dockerfile
echo "ENV CF_INSTANCE_INDEX=0" >> ./Dockerfile

# Check if the directory exists
if [ -d "$DIRECTORY" ]; then  
    # Loop through the contents of the directory and add to the Dockerfile
    echo "Loop through the contents of the directory and add to the Dockerfile"
    for entry in "$DIRECTORY"/*; do
        echo "ADD $entry /home/vcap/$(basename $entry)" >> ./Dockerfile
    done
else
    echo "Directory $DIRECTORY does not exist."
fi

APPNAME=$(yq e '.start_command' $STAGINGINFO | xargs basename)
APPNAME=$(basename $APPNAME)
# echo "ENTRYPOINT [ \"/home/vcap/app/$APPNAME\" ]" >> ./Dockerfile
echo "ENTRYPOINT [\"sh\", \"-c\", \"echo $CF_INSTANCE_GUID && echo $CF_INSTANCE_INDEX && exec /home/vcap/app/$APPNAME\" ]" >> ./Dockerfile

echo "Built Dockerfile for: $(echo $APPNAME | awk -F. '{print $NF}')"

