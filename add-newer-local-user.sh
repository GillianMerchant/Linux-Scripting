# Exercise 4 from https://www.udemy.com/course/linux-shell-scripting-projects/learn/lecture/7981820#overview

# The same task to create a scrip that creates user, but this time conforming to standard linux convention by redirecting error messages. 

# Instructions provided:

# Enforces that it be executed with superuser (root) privileges.  If the script is not executed with superuser privileges it will not attempt to create a user and returns an exit status of 1.  # # All messages associated with this event will be displayed on standard error. 
# Provides a usage statement much like you would find in a man page if the user does not supply an account name on the command line and returns an exit status of 1
# Uses the first argument provided on the command line as the username for the account. 
# Automatically generates a password for the new account. 
# Informs the user if the account was not able to be created for some reason.  If the account is not created, the script is to return an exit status of 1.  All messages associated with this event will be displayed on standard error.
# Displays the username, password, and host where the account was created. 




# Code and all other comments by GM


#GM: Checking user. To suppress the error message we have to redirect it from standard out to standard error. This is done with ">" for standard output (short for "1>"), "&2" meaning standard error descriptor 

if [[ "${UID}" -ne 0 ]]
then
	echo "Please run this from root" >&2
	exit 1
fi



#GM:Checking parameters. The usage statement is again redirected to standard error with ">&2"

if [[ "${#}" < 1 ]]
then
	echo "Usage : ${0} USER_NAME ... [COMMENT]" >&2
	exit 1
fi


#GM: setting variables from parameters, using shift. No handling of error or output needed here. 

USER_NAME="${1}"
shift
COMMENT="${@}"


#GM: password setup as before with randomised date, encryption, and random symbol generated with fold and shuf. No need for error handling as just assignments. 

CHAR_ARRAY='*!&'
CHAR=CHAR_ARRAY | fold -w1 | shuf | head -c1
PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c30)${CHAR}


#GM: Creating user. Use "&> /dev/null" to discard both output and error, because we are checking status ourselves. Send ">&2" to send our error messgae from the status checker to error.

useradd ${USER_NAME} -m -c COMMENT > /dev/null
if [[ ${?} -ne 0 ]]
then
	echo "User not successfully created " >&2
	exit 1
fi	
	
# apply the password to the user. Same setup as above. 

echo ${PASSWORD} | passwd --stdin ${USERNAME} > /dev/null
if [[ ${?} -ne 0 ]]
then
	echo "Password could not be used "  >&2
	exit 1
fi

# force the password change on first login and discard the output of the passwd command

passwd -e ${USER_NAME} > /dev/null



echo "UserName"
echo "${USER_NAME}"
echo
echo "Password"
echo "${PASSWORD}"
echo
echo "Host"
echo "${HOSTNAME}"



