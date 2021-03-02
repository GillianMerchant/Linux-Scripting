#!/bin/bash

# An exercise to create a shall script that adds users to the system with an automated randomised password , where account name and comments can be entered as arguments on the command line, rather than from prompts. 

# Script outline provided in these instructions from https://www.udemy.com/course/linux-shell-scripting-projects/learn/lecture/7981808#questions/10167940

	# Enforces that it be executed with superuser (root) privileges.  If the script is not executed with superuser privileges it will not attempt to create a user and returns an exit status of 1
	# Provides a usage statement much like you would find in a man page if the user does not supply an account name on the command line and returns an exit status of 1.
	# Uses the first argument provided on the command line as the username for the account.  Any remaining arguments on the command line will be treated as the comment for the account.
	# Automatically generates a password for the new account.
	# Informs the user if the account was not able to be created for some reason.  If the account is not created, the script is to return an exit status of 1.
	# Displays the username, password and host where the account was created.  This way the help desk staff can copy the output of the script in order to easily deliver the information to the new account holder.





# All following comments and code by me!

# NB This script can only be used to add one user at a time

# an if statement to check the user privileges - if not root, exit with status 1
if [[ "${UID}" -ne 0 ]]
then
	echo "Sorry - you need super user privileges to run this script."
	exit 1
fi


# an if statement to check if a user name argument has been supplied and provide usage if not. Use ${0} to access the command name. 
if [[ "${#}" < 1 ]]
then
	echo "Usage: ${0} USER_NAME ... [COMMENT]"
	echo "Supply a USER_NAME and optional COMMENT for ${0}"
	exit 1
fi



# set a user name variable to the first parameter with ${1}

USER_NAME="${1}"
echo "User name set to ${USER_NAME}"


# set the rest of the arguments as the comment field. Use shift to remove the user name var from the first param position, then use "${@}" to store the rest in one variable
shift
COMMENT="${@}"
echo "Comment set to: ${COMMENT}"

# set a randomly-generated password. Use epoch time, nano time and the random variable. Pipe all of that to sha256sum to generate a hexadec value. Pipe that to  head to return a sensible sized-password. Then add a randomly selected special char on the end. 

# set up some chars, fold them into a single column, shuffle them and pick the top line (that is the top char). 
CHARS="£$%^&*"
RANDOM_CHAR="$(echo ${CHARS} | fold -w1 | shuf | head -c1)"
echo "random char is: ${RANDOM_CHAR}"

# set up the password as described with the random char appended
PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c30)${RANDOM_CHAR}




# create the user with the comment and home directory options, and check if the command was successful by checking the exit status

useradd -c "${COMMENT}" -m  ${USER_NAME}
if [[ "${?}" -ne 0 ]]
then
	echo "Account creation failed"
	exit 1
fi

# set the password on the account by piping it to the passwd function as standard input

echo ${PASSWORD} | passwd --stdin ${USER_NAME}
if [[ "${?}" -ne 0 ]]
then
	echo "Password assignation failed"
	exit 1
fi

# set the password so that it has to be reset before the user logs in for the first time. Use passwd command , -e option and user name 
passwd -e ${USER_NAME}



# echo the user name, password and host variables

echo "USERNAME: ${USER_NAME} : PASSWORD: ${PASSWORD} : HOST: ${HOSTNAME}"
