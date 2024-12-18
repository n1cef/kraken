#!/bin/bash

# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken"

https://raw.githubusercontent.com/n1cef/kraken/refs/heads/master/pkgbuilds/nano/pkgbuild.kraken
# Function to download the package
get_package() {
    # Ensure the user provided a package name
    if [ -z "$1" ]; then
        echo "ERROR: You must specify a package name."
        return 1
    fi

    # Package name passed by user
    pkgname="$1"
    echo "packege name is $pkgname"

    # Check if the source directory exists, create if it doesn't
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Creating source directory $SOURCE_DIR"
        mkdir -p "$SOURCE_DIR"
    fi

    if [ ! -d "$SOURCE_DIR/$pkgname" ]; then 
           echo "creating  /sources/$pkgname  directory"
           mkdir -p "$SOURCE_DIR/$pkgname"
    fi
    # Search the repository for the PKGBUILD file corresponding to the package
    pkgbuild_url="${REPO_URL}/refs/heads/master/pkgbuilds/$pkgname/pkgbuild.kraken"

   
   

    
           echo "Fetching PKGBUILD for $pkgname from repo..."
    pkgbuild=$(wget -P $SOURCE_DIR/$pkgname  "$pkgbuild_url")

    
    
    
    
    source_url=$(awk '/^sources=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | sed -e '1d;$d' -e 's/[",]//g' | xargs -n1)

# Print each entry
echo "Extracted sources entries:"
for url in $source_url; do
    echo "$url"
    echo "Downloading source tarball from $url..."
    wget -q "$url" -P "$SOURCE_DIR/$pkgname"
done






 

    checksum=$(awk '/^sha1sums=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | sed -e '1d;$d' -e 's/[",]//g' | xargs -n1)


echo "Extracted sources entries:"
for sum in $checksum; do
    echo " sha1sums is $sum"
done



    


    #Check if the source URL and checksum were extracted
    if [ -z "$source_url" ] || [ -z "$checksum" ]; then
        echo "ERROR: Failed to extract source URL or checksum from PKGBUILD."
        return 1
    fi

    # Download the source tarball
    

    # Get the downloaded tarball filename
    tarball_name=$(basename "$source_url")
    echo "tarbll name is "
    # Verify the checksum of the downloaded file
    echo "Verifying checksum for $tarball_name..."
    downloaded_checksum=$(sha256sum "$SOURCE_DIR/$tarball_name" | awk '{print $1}')

    if [ "$downloaded_checksum" != "$checksum" ]; then
        echo "ERROR: Checksum verification failed for $tarball_name."
        return 1
    else
        echo "Checksum verification successful."
    fi

    # Successfully downloaded and verified the package
    echo "$pkgname package has been downloaded and verified."
}


case $1 in
    download)
        get_package $2
        ;;
    


    *)
        echo "Usage: $0 {download|checkdep|prepare|build|install} <package_name>"
        exit 1
        ;;
esac
