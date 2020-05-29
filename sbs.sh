#!/bin/bash
#Write a script which downloads the thumbnails from:
#https://www.ecu.edu.au/service-centres/MACSC/gallery/gallery.php?folder=152

#The URLs are the same, with only the number of the images differing E.g.
#https://secure.ecu.edu.au/service-centres/MACSC/gallery/152/DSC01695.jpg
#https://secure.ecu.edu.au/service-centres/MACSC/gallery/152/DSC01657.jpg

#Required Functionality:
#1.	Download a specific thumbnail i.e. DSC01556
#2.	Download ALL thumbnails
#3.	Download images in a range (Last 4 digits of the filename)
#4.	Download a specified number of images


function getThumbs() {
#Function to get thumbnail names
	if [[ !  -f thumbs ]]; then
		
		curl -s https://www.ecu.edu.au/service-centres/MACSC/gallery/gallery.php?folder=152 | grep -oe 'alt="DSC0[0-9]*"' | sed 's/alt=//g; s/"//g' > thumbs.txt
		readarray -t nameArr < ./thumbs.txt
	
	else
		readarray -t nameArr < ./thumbs.txt
	fi



}

function specifiedImage() {
	
	if wget -P ./downloaded "https://secure.ecu.edu.au/service-centres/MACSC/gallery/152/$1.jpg" 1> /dev/null 2> /dev/null ; then
		curl -sI "https://secure.ecu.edu.au/service-centres/gallery/152/$1.jpg" | grep -oE "Content-Length: [0-9]*" | sed "s/Content-Length/Downloaded $1 with size: /" | awk '{ print $1, $2, $3, $4, $5, $6/1024, "KB"}' 
	else
		echo "Specified thumbnail doesn't exist"
	fi
}


function downloadAll() {

	for thumbName in ${nameArr[*]}
	do
		wget -P ./downloaded "https://secure.ecu.edu.au/service-centres/MACSC/gallery/152/$thumbName.jpg" 1> /dev/null 2> /dev/null

		curl -I "https://secure.ecu.edu.au/service-centres/MACSC/gallery/152/$thumbName.jpg"
		size="$(curl -sI "https://secure.ecu.edu.au/service-centres/gallery/152/$thumbName.jpg" | grep -oE "Content-Length: [0-9]*" | sed "s/Content-Length: //")"
		echo -e "Downloaded $thumbName with a size of $size\n"
	
	done
}


function downloadRange () {

	echo "Download Range called" 

}

function downloadSpecRandom() {

	:

} 
echo -e "SBS: ECU gallery 152 Thumbnail downloader\n"

if [[ ! -d ./downloaded ]]; then

	mkdir ./downloaded
fi

while true
do
	#main menu
	echo "What would you like to do: "
	echo "1. Download a specific thumbnail"
	echo "2. Download all thumbnails"
	echo "3. Download a range of thumbnails"
	echo "4. Download a specified number of random thumbnails"
	echo "E(x)it"
	read -p ">>" choice

	#case statement for user choice

	case $choice in
		"1") 
			read -p "Specify a thumbnail to download: " thumb
			specifiedImage $thumb
			;;
		"2")
			getThumbs
			downloadAll $nameArr
			;;
		"3")
			getThumbs
			while true
			do 
				read -p "Input a starting thumbnail: " startThumb

				if echo ${nameArr[*]} | grep -wo "$startThumb" > /dev/null; then
					
					read -p "Specify how many thumbnails to download: " numThumbs

					if [[ $numThumbs =~ ^-?[0-9]+$ ]]; then 
					
						downloadRange $startThumb $numThumbs

					else
						echo "The number of thumbnails needs to be an integer"
						continue
					fi
				else
					echo "Invalid thumbnail"
				fi
			done
			;;
		"4")
			:
			;;
		"x")
			exit 0
			;;

	esac

				



done
