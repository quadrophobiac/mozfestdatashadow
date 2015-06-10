## Overview

This is a bash script (and requisite files) that will run a customised version of Firefox in order to visualise the Lightbeam plug in as an automated data visualisation useful for articulating the data shadows which correspond to marketing segmentation data.

## System Requirements
Linux system (will not work on mac)  
bash  
curl (fetch HTTP files)  
jq (parse json from command line)  
xvkbd (virtual keyboard for automation of firefox)  

If you wish to save screenshots, you will need to specify the terminal command for your screenshot software of choice  
Configuration of the gnome-screenshot save folder via dconf-editor

## Script Requirements
Google Custom Search Engine (CSE) key  
Google Dev API key  

ensure that the shadowpuppetry.sh file is marked as executable

pass it command line arguments as follows: 
* $1 name of personae you wish to visualise
* $2 ranked or unranked (in reference to the google adword queries consulted)
* $3 = CSE key
* $4 = Google Dev API key
The script tests if the CSE key and google Dev API key are valid (i.e. that the daily request limit has not been exceeded)
If there is a valid API & CSE key combo then the script can execute, if not it will return an error and load up a local 'error.html' page into a FF browser
The script empties the tmpdata directory upon initialisation

## Directory Structure

A resrc directory contains subdirectories which house .txt files consisting of google keyword phrases, seperated by "+" rather than " " (for ease of search term construction)

Each time the script is called it will store files generated in tmpdata directory.

The script creates a bespoke subdirectory (named in accordance with arguments passed to the script) in the archive directory

Upon conclusion of the script all files from tmpdata are copied to a folder named in accordance with the parameter passed to the most recent iteration of the script

An entire firefox profile loads from the folder where the bash script executes. This is because the script can delete locally held data each time the browser closes. You may use your own default Firefox installation by commenting out line 102 and uncommenting line 103. If you do so you must ensure that your local Firefox has the Lightbeam Plug In installed

## Mozilla Profile

This is launched using "firefox -profile ABS/DIR/PATH" and uses a locally sourced Mozilla profile provided in the download

Mozilla profile is a duplicate of the base profile generated via Mozilla Profile Manager with changes to the preferences as follows

browser.tabs.loadDivertedInBackground = true # ensures that focus stays on the first tab loaded, in this case lightbeam plug in  
browser.tabs.warnOnClose = false #  
browser.tabs.warnOnCloseOtherTabs = false  
browser.showQuitWarning = false  
browser.warnOnQuit = false  

## Custom Lightbeam Plug In

The Lightbeam plug in has been modified from the original developed by Mozilla, using the instructions detailed in 'modifying_lightbeam_plugin.txt'
Changes to HTML and CSS to make the presentation cleaner
Inclusion of window.onbeforeunload = closingCode; in ui.js, with return value of null. Inclusion of this function enables any Lightbeam JSON to be downloaded upon closing of TAB where the lightbeam is contained (function will not trigger on ALT+F4, or on F5 refresh)
