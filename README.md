# jamfscripts
Scripts for Jamf Pro management. These could be useful if you regularly set up new Jamf instances (i.e. MSP provider).

## Jamf Pro Enrollement Language Changer 
This script can be used to create a new Enrollment language or modify the default one and customize its interface.

https://github.com/guillaumegete/jamfscripts/blob/main/jamf_enrollement_language_changer.sh

I regularly need to enrol positions in a new Jamf Pro instance, and the enrolment procedure goes through a page normally in English. Jamf Pro allows you to create custom enlistment pages by language, but the procedure is a little tedious since you have to create the custom text for each language. 

This script creates a new language (default is French, but you can use any language you want). Fill in the settings with an API account (you can use your administrator account, but it is better to have a dedicated account with restricted rights), launch the script, and after a few seconds, a new enrolment page will be added in French. You can obviously edit the text in the JSON part, and even add links to other images using the Markdown syntax. If you want to add other languages, you can add them by modifying the text _fr_ at the beginning of the line using the international code for your country instead.

Uses Jamf API v2.

## Jamf Pro Mail Setup

Sets up the mail server used to send notifications from Jamf Pro. Useful if you regularly have to manage Jamf instances.

https://github.com/guillaumegete/jamfscripts/blob/main/jamfpro_mail_setup

Uses Jamf Classic API.
