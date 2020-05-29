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
		#Pulls all the names from the HTML from the alt tag and puts them first into a file, then into an array. 	
		curl -s https://www.ecu.edu.au/service-centres/MACSC/gallery/gallery.php?folder=152 | grep -oe 'alt="DSC0[0-9]*"' | sed 's/alt=//g; s/"//g' > thumbs.txt
		readarray -t nameArr < ./thumbs.txt
	
	else
		readarray -t nameArr < ./thumbs.txt
	fi



}

#Function for downloading a particular image
function specifiedImage() {
	
	#Tries the wget command. If it succeeds the thumbnail is downloaded. If it fails, the thumbnail doesn't exist. Thus the user is told
	if wget -P ./downloaded "https://secure.ecu.edu.au/service-centres/MACSC/gallery/152/$1.jpg" 1> /dev/null 2> /dev/null ; then
		
		#THIS IS WHERE THE ISSUE RESIDES!!!!
		#I want to get the header information with curl, filter the Content-Length (The size of the file) from the curl command, substitute "Content-Length" with "Downloaded <Thumbnail Name> with size:", then using awk to divide the byte size into KBs
		#WHAT ACTUALLY HAPPENS 
		#As far as I can tell this is correct. But it will always display a size of 10846 even when the size of the file isn't.
		curl -sI "https://secure.ecu.edu.au/service-centres/gallery/152/$1.jpg" | grep -oE "Content-Length: [0-9]*" | sed "s/Content-Length/Downloaded $1 with size: /" | awk '{ print $1, $2, $3, $4, $5, $6/1024, "KB"}' 
	else
		echo "Specified thumbnail doesn't exist"
	fi
}

#Function to download all the images
function downloadAll() {
	
	#Substitutes a name from the array into the url to download the image
	for thumbName in ${nameArr[*]}
	do
		#The downloading of the images works fine.
		wget -P ./downloaded "https://secure.ecu.edu.au/service-centres/MACSC/gallery/152/$thumbName.jpg" 1> /dev/null 2> /dev/null
		
		#THIS HAS THE SAME ISSUE AS THE PREVIOUS FUNCTION
		#JUST AN ALTERNATE ATTEMPT TO SOLVE
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

#Create the directory to save the thumbnails to
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

				#Ensures the thumbnail is correct
				if echo ${nameArr[*]} | grep -wo "$startThumb" > /dev/null; then
					
					read -p "Specify how many thumbnails to download: " numThumbs
					
					#Ensures the input is an integer
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
