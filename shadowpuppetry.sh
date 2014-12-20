#!/bin/bash

# local vars to pass into the file
# # $5 for not live data mode?
# $1 name of personae,
# $2 ranked or unranked (concatenate with $1 and directory structure to access the correct txt file)
# $3 = var for cx
# $4 = googleapis KEY

# functions
shuffle() {
   local i tmpdata size max rand

   # $RANDOM % (i+1) is biased because of the limited range of $RANDOM
   # Compensate by using a range which is a multiple of the array size.
   size=${#queries[*]}
   max=$(( 32768 / size * size ))

   for ((i=size-1; i>0; i--)); do
      while (( (rand=$RANDOM) >= max )); do :; done
      rand=$(( rand % (i+1) ))
      tmpdata=${queries[i]} queries[i]=${queries[rand]} queries[rand]=$tmpdata
   done
}

date=`date +%s` #acquire epoch time for use concatenated to arguments, for archiving purposes
mkdir "archive/$1_$date" # make directory where this iteration of the shadow will be archived

mkdir "tmpdata"

readarray -t queries < resrc/$1/$2.txt # -t = Exclude newline.

shuffle

# pick first ten after shuffle and add to an array

nuqueries=()

#variables needed to access Google API

if [[ -z $3 || -z $4  ]];
	then

	# default API credential credentials
	echo "no API variables passed as arguments"
	cx=''
	key=''
else
	echo "please ensure correct parameters passed for API access"
	cx=$3
	key=$4
fi

# for i in {1..2} # DEBUG
for i in {1..10} # ROBUST
do
	nuqueries+=(${queries[$i]})
done

toparse=() # array of links to be populated and later passed to firefox

islive=0 # param used to evaluate if the API key plus CX are returning queries
echo $islive
# test the API

testquery="https://www.googleapis.com/customsearch/v1?key=$key&cx=$cx&q=testing+google&filter=1&start=1&num=2&alt=json"
# note that start and num are limited here for testing purposes
curl $testquery > "errata.json" # this way the same file will be overwritten every time == desired behaviour
limit=`jq '.error.errors' "errata.json"`
links=`jq '.items[].link' "errata.json"`
if [[ -z $links ]]; # if using double square brackets, the quotes aren't necessary.
# above evaluates if the links is set or not
	then echo "null for curl'd links, limit likely exceeded: $limit"
else
	echo "good to go"
	echo $links
	islive=1
fi
# retrieve results, contingent on API check above
if [[ $islive -eq 1 ]];
	then
	echo "API key valid for more queries"
	echo $islive
		for i in "${nuqueries[@]}"
		do
			echo $i
			# curlquery="https://www.googleapis.com/customsearch/v1?key=$key&cx=$cx&q=$i&filter=1&start=1&num=2&alt=json" # DEBUG
			curlquery="https://www.googleapis.com/customsearch/v1?key=$key&cx=$cx&q=$i&filter=1&start=1&num=10&alt=json" # ROBUST
			curl $curlquery > "tmpdata/$i.json"
			links=( `jq '.items[].link' "tmpdata/$i.json" | awk '{print substr($0, 2, length() - 2)}'` )
			# copy file to archive folder
			toparse+=(${links[$RANDOM % ${#links[@]} ]})
		done

		# before loading firefox , empty store.json to ensure it is a fresh graph

		echo -e " " > "firefox_profiles/shadow_puppetry/jetpack/jid1-F9UJ2thwoAm5gQ@jetpack/simple-storage/store.json"
		# removes local store of lightbeam data so that each shadow animates from scratch

		# -p presumes that a profile has been loaded into the local users firefox profile manager
		# -profile permits loading a profile based on a path
		firefox -profile firefox_profiles/shadow_puppetry -new-window resource://jid1-f9uj2thwoam5gq-at-jetpack/lightbeam/data/index.html &
		# firefox -new-window resource://jid1-f9uj2thwoam5gq-at-jetpack/lightbeam/data/index.html &
		sleep 3;
		xvkbd -window Firefox -text "\Cr";

		for i in "${toparse[@]}"
		# write the link retrieved to a file
		do
			# printf '%s\n\t%s\n' 'site selected: ' $i >> visited.txt
			echo -e "site visited: "$i"\n" >> "visited.txt"
			# echo $i
			# echo "line break"
			firefox -new-tab "$i" & 2>/dev/null
			sleep 15;
		done
		sleep 25;
		# then everything in to parse should be written to a file 'visited', which accompanies the screengrab of the shadow
		# gnome-screenshot -w -B & # uncomment and replace screengrab program with one that is compatible with your distro
		# script to close and save data, and exit firefox
		sleep 1;
		xvkbd -window Firefox -text "\Cw";
		sleep 1;
		xvkbd -window Firefox -text "\[Alt]\[F4]";

		find ./tmpdata -name "*.json" -type f -exec cp {} ./"archive/$1_$date" \; # move search result JSON files from tmp to archive
		# find ./tmpdata -name "*.png" -type f -exec cp {} ./"archive/$1_$date/$1_$2.png" \; # if capturing screen shots
		rm tmpdata/* #remove the temporary files stored to the tmpdata folder
else
	echo "API key has reached limit"
	firefox -profile firefox_profiles/shadow_puppetry -new-window lightbeam_error/error.html # or a localhost derivative
	# firefox load up a page instructing that new API key required
fi
