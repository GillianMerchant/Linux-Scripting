#!/bin/bash

# An exerciseto build a bash script to automate creating user accounts
# Script outline provided in these instructions from https://www.udemy.com/course/linux-shell-scripting-projects/learn/lecture/7981796#questions/10167940

	# Enforces that it be executed with superuser (root) privileges.  If the script is not executed with superuser privileges it will not attempt to create a user and returns an exit status of 1.
	# Prompts the person who executed the script to enter the username (login), the name for person who will be using the account, and the initial password for the account.
	# Creates a new user on the local system with the input provided by the user.
	# Informs the user if the account was not able to be created for some reason.  If the account is not created, the script is to return an exit status of 1.
	# Displays the username, password, and host where the account was created.  This way the help desk staff can copy the output of the script in order to easily deliver the information to the new account holder.



# All following comments and code by me!

# Start with an if statement to check that the user is the root user - and if not, send a message and exit script with status 1.

if [[ "${UID}" -ne 0 ]]
then
	echo 'No way Jose! You need su privileges to do this'
	exit 1
fi


# Now use read commands to capture user input against user name, comment and password variables (comment is usually used for full name plus any other useful identifiers)

read -p 'Please enter your user name: ' USER_NAME
read -p 'Please enter your full name: ' COMMENT
read -p 'Password please: ' PASSWORD


# The useradd command is now run on the user along with a comment option and the -m option to create a home directory for the user

useradd -c "${COMMENT}" -m ${USER_NAME}


# check if useradd succeeded by checking the exit status and exiting the script if it failed

if [[ "${?}" -ne 0 ]]
then
	echo 'Sorry - this account for $USER_NAME could not be created'
	exit 1
fi


# Set the password on the user account, piping to standard input
echo $PASSWORD | passwd --stdin $USER_NAME


# Check if password created ok with the exist status again

if [[ "${?}" -ne 0 ]]
then
	echo 'Sorry - this password for $USER_NAME could not be set'
	exit 1
fi


# Enforce password change at the next (first) login

passwd -e ${USER_NAME}


# Now print back the variables and then exit

echo "username: ${USER_NAME}"
echo
echo "password: ${PASSWORD}"
echo
echo "host: ${HOSTNAME}"

exit 0
