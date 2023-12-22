#!/bin/zsh

# Author:Guillaume Gète
# 25/11/2022

# What does this script do?

# Verifies if the user is part of MyCompany International. If it is, it automatically 
# attributes the Mac to the proper site. Requires ability to modify Computers through Jamf Pro API.
# The script is built around the idea that only two values are available for a user to be read from the position field, 
# that we get from a Jamf variable ("position"), that we push through a profile in the 
# /Library/Managed Preferences/com.MyCompany.variables.plist file.

# 1.0.1 
# Updated with Bearer Token Authorization
# Modified to change the computer to be attributed to MyCompany France if not MyCompany International

jamfProURL="https://MyCompany.jamfcloud.com"
username="$4"
password="$5"

# request auth token
authToken=$( /usr/bin/curl \
--request POST \
--silent \
--url "$jamfProURL/api/v1/auth/token" \
--user "$username:$password" )

echo "$authToken"

# parse auth token
token=$( /usr/bin/plutil \
-extract token raw - <<< "$authToken" )

tokenExpiration=$( /usr/bin/plutil \
-extract expires raw - <<< "$authToken" )

localTokenExpirationEpoch=$( TZ=GMT /bin/date -j \
-f "%Y-%m-%dT%T" "$tokenExpiration" \
+"%s" 2> /dev/null )

echo Token: "$token"
echo Expiration: "$tokenExpiration"
echo Expiration epoch: "$localTokenExpirationEpoch"

VARIABLE_FILE="/Library/Managed Preferences/com.MyCompany.variables.plist"

USER_POSITION=$(/usr/bin/defaults read "$VARIABLE_FILE" position | grep -i international)

XML_INPUT_FILE="/tmp/site.xml"


if [ -z "$USER_POSITION" ]; then
	echo "This Mac is part of MyCompany France. Changing site in Jamf Pro now."

	echo "Generating XML file…"

	cat << "EOF" > "$XML_INPUT_FILE"
<computer>
	<general>
		<site>
			<id>2</id>
			<name>MyCompany France</name>
		</site>
	</general>
</computer>
EOF

	
else
	echo "This Mac is part of MyCompany International. Changing Site in Jamf Pro now."
	
	echo "Generating XML file…"
	
	cat << "EOF" > "$XML_INPUT_FILE"
<computer>
	<general>
		<site>
			<id>1</id>
			<name>MyCompany International</name>
		</site>
	</general>
</computer>
EOF

fi

# Get serial number of Mac so it can be identified in the JSS

serial=$(system_profiler SPHardwareDataType | grep 'Serial Number (system)' | awk '{print $NF}')

echo "Mac Serial Number: $serial"


# Generates XML file to PUT in Jamf Pro
	

sleep 2
echo "Now uploading in Jamf Pro…"

sleep 1

# Upload the xml file

curl -sfk --header "Authorization: Bearer $token" $jamfProURL/JSSResource/computers/serialnumber/"$serial"/subset/general -T "$XML_INPUT_FILE" -X PUT

sleep 2

rm "$XML_INPUT_FILE"

# expire auth token
/usr/bin/curl \
--header "Authorization: Bearer $token" \
--request POST \
--silent \
--url "$jamfProURL/api/v1/auth/invalidate-token"
