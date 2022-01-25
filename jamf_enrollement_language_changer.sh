#!/bin/bash

#####################################################################################################
# INFO - This script will request a Jamf Pro UAPI token and then add a new language as a 
#        supported language for user enrollement.
#        Tested with Jamf Pro 10.35
# AUTHOR - Guillaume Gete (with help of Vincent Bonnin)
# VERSION - 1.0
#####################################################################################################

# API Credentials
instanceURL="https://JAMF.SERVER.URL"
apiUser="nameofapiuser"
apiPass="PasswordOfApiUser"
CompanyName="Company Name"
CompanyLogo="https://your.url.to/some.logo.png.or.jpg"

# The language code that will be added here
# NB: you can also modify the default English text with one that suits you using "en" as the language code.

enrollmentLanguage="fr"

# created base64-encoded credentials
encodedCredentials=$( printf "$apiUser:$apiPass" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )

# Request an auth token
tokenCommand=$(curl "$instanceURL/uapi/auth/tokens" \
--silent \
--request POST \
--header "Authorization: Basic $encodedCredentials")

# parse authToken for token, omit expiration key
token=$( /usr/bin/awk -F \" '{ print $4 }' <<< "$tokenCommand" | /usr/bin/xargs )


# You can change the text below to accomodate your language.
# We use French here, but you can update it to your own language.
# To get the proper, up-to-date schema, check https://developer.jamf.com/jamf-pro/reference/get_v2-enrollment-languages-languageid?
# Remember that Markdown is supported, allowing to add icons or bold text, etc. 


read -r -d '' jsonData <<EOF
{
	"languageCode" : "$enrollmentLanguage",
	"name" : "Français",
	"title" : "Insciption de votre appareil",
	"loginDescription" : "![icon]($CompanyLogo)\n\n**Bienvenue sur la page d'enrôlement des appareils Apple pour $CompanyName !**\n\nConnectez-vous pour enrôler votre appareil",
	"username" : "Utilisateur",
	"password" : "Mot de passe",
	"loginButton" : "Connexion",
	"deviceClassDescription" : "Spécifiez le type d'appareil à enrôler, appareil professionnel ou personnel",
	"deviceClassPersonal" : "Appareil Personnel",
	"deviceClassPersonalDescription" : "Sur les appareils personnels, nos administrateurs **peuvent**:\n\n*   Lock the device\n*   Apply institutional settings\n*   Install and remove institutional data\n*   Install and remove institutional apps\n\n\nSur les appareils personnels, nos administrateurs **ne peuvent pas**:\n\n*   Wipe all data and settings from your device\n*   Track the location of your device\n*   Remove anything they did not install\n*   Add/remove configuration profiles\n*   Add/remove provisioning profiles",
	"deviceClassEnterprise" : "Appareil Professionnel",
	"deviceClassEnterpriseDescription" : "Sur les appareils professionnels, nos administrateurs **peuvent**:\n\n*   Wipe all data and settings from the device\n*   Lock the device\n*   Remove the passcode\n*   Apply institutional settings\n*   Install and remove institutional data\n*   Install and remove institutional apps\n*   Add/remove configuration profiles\n*   Add/remove provisioning profiles\n\nSur les appareils professionnels, nos administrateurs **ne peuvent pas**:\n\n*   Remove anything they did not install\n*   Track the location of the device",
	"deviceClassButton" : "Enrôler",
	"personalEula" : "",
	"enterpriseEula" : "",
	"eulaButton" : "Accept",
	"siteDescription" : "Sélectionnez un site d'appartenance pour cet appareil.",
	"certificateText" : "Pour continuer cet enrôlement, vous devez installer un certificat provenant de votre organisation.",
	"certificateButton" : "Continuer",
	"certificateProfileName" : "Certificat CA",
	"certificateProfileDescription" : "Certificat permettant la gestion d'appareils Apple",
	"personalText" : "![icon]($CompanyLogo)\n\nPour compléter cet enrôlement, vous devez installer et accepter un profil de gestion MDM.",
	"personalButton" : "Continuer",
	"personalProfileName" : "Gestion par $CompanyName",
	"personalProfileDescription" : "Profil d'enrôlement permettant la gestion de votre appareil Apple avec des droits limités.",
	"userEnrollmentText" : "![icon](https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Apple_logo_grey.svg/128px-Apple_logo_grey.svg.png)\n\nVeuillez entrer votre identifiant Apple ID pour continuer l'enrôlement de cet appareil personnel.",
	"userEnrollmentButton" : "Continuer",
	"userEnrollmentProfileName" : "Gestion par $CompanyName",
	"userEnrollmentProfileDescription" : "Profil d'enrôlement permettant la gestion de votre appareil Apple avec des droits limités.",
	"enterpriseText" : "![icon]($CompanyLogo)\n\nPour compléter cet enrôlement, vous devez installer et accepter un profil de gestion MDM.",
	"enterpriseButton" : "Continuer",
	"enterpriseProfileName" : "Profil MDM Professionnel $CompanyName",
	"enterpriseProfileDescription" : "Profil MDM permettant la gestion d'appareils Apple de type professionnel.",
	"enterprisePending" : "Pour terminer l'enrôlement, veuillez installer le certificat et/ou le profil MDM téléchargés sur votre appareil.",
	"quickAddText" : "",
	"quickAddButton" : "",
	"quickAddName" : "",
	"quickAddPending" : "",
	"completeMessage" : "![icon](https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Check_green_circle.svg/128px-Check_green_circle.svg.png)\n\nProcessus d'enrôlement terminé.",
	"failedMessage" : "![icon](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Dialog-warning-custom.svg/128px-Dialog-warning-custom.svg.png)\n\nImpossible de terminer l'enrôlement, veuillez contacter votre administrateur informatique.",
	"tryAgainButton" : "Réessayer",
	"checkNowButton" : "Status",
	"checkEnrollmentMessage" : "Cliquez sur \"Status\" pour voir le status d'enrôlement de votre appareil",
	"logoutButton" : "Se Déconnecter"
}


EOF

UpdateEnrollment=$(curl -X PUT "$instanceURL/api/v2/enrollment/languages/$enrollmentLanguage" \
-H "accept: application/json" -H "Authorization: Bearer $token" \
-H "Content-Type: application/json" \
-d "${jsonData}")



exit 0
