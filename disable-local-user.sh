#!/bin/bash

# Exercise to create script to delete user to be completed. Instructions provided as follows:


#Enforces that it be executed with superuser (root) privileges.  If the script is not executed with superuser privileges it will not attempt to create a user and returns an exit status of 1.  All messages associated with this event will be displayed on standard error.
# Provides a usage statement much like you would find in a man page if the user does not supply an account name on the command line and returns an exit status of 1.  All messages associated with this event will be displayed on standard error.
# Disables (expires/locks) accounts by default
# Allows the user to specify the following options:
# -d Deletes accounts instead of disabling them.
# -r Removes the home directory associated with the account(s).
# -a Creates an archive of the home directory associated with the accounts(s) and stores the archive in the /archives directory.  (NOTE: /archives is not a directory that exists by default on a Linux system.  The script will need to create this directory if it does not exist.)
# Any other option will cause the script to display a usage statement and exit with an exit status of 1.
# Accepts a list of usernames as arguments.  At least one username is required or the script will display a usage statement much like you would find in a man page and return an exit status of 1.  All messages associated with this event will be displayed on standard error.
# Refuses to disable or delete any accounts that have a UID less than 1,000.
# Only system accounts should be modified by system administrators.  Only allow the help desk team to change user accounts.
# Informs the user if the account was not able to be disabled, deleted, or archived for some reason.




# My comments and code as follows:


#set up a var to handle the archive directory
ARCHIVE_DIR='/archive'

# print a usage statement specifying the three options, the mandatory USER and the optional extra users. Send the statements to standard error and exit with status of 1.
usage() {
	echo "Usage: ${0} [-dra] USER [USER]..." >&2
	echo 'Disable a local linux account' >&2
	echo 'Use -d to delete instead' >&2
	echo 'Use -r to delete and remove home directory' >&2
	echo 'Use -a to archive the home direcory' >&2
	exit 1
	}


#Check that the user is running as sudo
if [[  "${UID}" -ne 0 ]]
then
	echo "Log in as superuser to run this script" >&2
	exit 1
fi


#Parse the options. Use while getopts for the three options - -d, -r and -a and set vars for them (boolean for delete, an option for remove

while getopts dra OPTION
do
	case ${OPTION} in
		d) DELETE_USER='true' ;;
		r) REMOVE_OPTION='-r' ;;
		a) ARCHIVE='true' ;;
		?) usage ;;
	esac
done


# Create the usgae function (above). 


# Now shift the options away so that the only parameters left are user accounts
shift "$(( OPTIND -1 ))"


# Check if there is at least one user supplied in command line, and if not call usage to print help and exit
if [[ "${#}" -lt 1 ]]
then
	usage
fi


# Iterate through the users, performing the disable, using the vars created in the getopts loop to perform the options from the command line . Print the current user being processed. Remember to check that an admin or superuser is not being deleted! Grab the user ID for each user and check it before proceding. 
for USERNAME in "${@}"
do
	echo "Processing ${USERNAME}"
	USERID=$(id -u ${USERNAME})
	if [[ "${USERID}" -lt 1000 ]] # NB this may also trigger if user not found!  Could look at handling this. 
	then
		echo "Permission not given to delete user id ${USERID}"
		exit 1
	fi
	
	# create the archive directory first if required, before doing any deleting. Use the ARCHIVE var from above. 
	if [[ "${ARCHIVE}" = 'true' ]]
	then
		echo "archive option selected" # debugging
		if [[ ! -d "${ARCHIVE_DIR}" ]] #Check if the directory exists. Use -d for exists directory (rather than -e for exists file?) 
		then
			echo "Creating archive directory"
			mkdir -p ${ARCHIVE_DIR} #-p option with mkdir means that nested directories can be created if ever needed. 
			if [[ "${?}" -ne 0 ]]  # do a check that mkdir worked
			then
				echo "Couldn't create archive dir" >&2
				exit 1
			fi
		fi
	
	# Then create an archive file in the archive directory 
		HOME_DIR="/home/${USERNAME}" # assuming that the home directory is configured like this
		ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz" # set up the compressed archive file called archive/name.tgz
		if [[ -d "${HOME_DIR}" ]] # if there is a home directory set up for the user then proceed
		then	
			echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
			tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null # create the compressed file. Test this in the command line with tar -ztvf to read compressed file
			if [[ "${?}" -ne 0 ]]  # do a check that mkdir worked
			then
				echo "Couldn't create archive file" >&2
				exit 1
			fi
		else  #if the home directory for the user does not exist
			echo "No home directory found for ${USERNAME}" >&2
			exit 1
		fi
	
	fi # end the if statement relating to the archive option
	
	# Process for when the delete option has been entered
	if [[ "${DELETE_USER}" = 'true' ]]
	then
		echo "delete option selected"
		userdel ${REMOVE_OPTION} ${USERNAME} #userdel command with the REMOVE_OPTION that we set to indicate if the home files to be removed too. This is one of userdel's own options so it will handle this. 
		if [[ "${?}" -ne 0 ]] ## do a check (this part could always be extracted to a function as we are doing it quite a lot)
		then
			echo "Account not deleted" >&2
			exit 1
		fi
		echo "Account "${USERNAME}" deleted"
	else
		chage -E 0 ${USERNAME} #chage command to expire the password now
		if [[ "${?}" -ne 0 ]] ## do a check 
		then
			echo "Account not disabled" >&2
			exit 1
		fi
		echo "Account "${USERNAME}" disabled"
	fi # end of the delete option if statement
	
		
done   # end of the for loop

exit 0	

