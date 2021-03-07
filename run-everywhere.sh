#!/bin/bash

# Exercise to create a mini network and run a given command on its machines remotely, from https://www.udemy.com/course/linux-shell-scripting-projects/learn/lecture/9558554#notes

# Instructions provided: 

# Executes all arguments as a single command on every server listed in the /vagrant/servers file by default.
# Executes the provided command as the user executing the script.
# Uses "ssh -o ConnectTimeout=2" to connect to a host.  This way if a host is down, the script doesn't hang for more than 2 seconds per down server.
# Allows the user to specify the following options:
#-f FILE  This allows the user to override the default file of /vagrant/servers.  This way they can create their own list of servers execute commands against that list.
# -n  This allows the user to perform a "dry run" where the commands will be displayed instead of executed.  Precede each command that would have been executed with "DRY RUN: ".
# -s Run the command with sudo (superuser) privileges on the remote servers.
# -v Enable verbose mode, which displays the name of the server for which the command is being executed on.
# Enforces that it be executed without superuser (root) privileges.  If the user wants the remote commands executed with superuser (root) privileges, they are to specify the -s option.
# Provides a usage statement much like you would find in a man page if the user does not supply a command to run on the command line and returns an exit status of 1.  All messages associated with this event will be displayed on standard error.
# Informs the user if the command was not able to be executed successfully on a remote host.
# Exits with an exit status of 0 or the most recent non-zero exit status of the ssh command.


#Comments and code from here on are mine!  Note there is a problem with shift so options are not being handled properly. 

SERVER_FILE="/vagrant/servers"

# set up a usage function
usage() {
echo "Usage: ${0} [-nsv] [-f FILE] COMMAND" >&2
echo " -f FILE Use FILE for the list of servers (default $SERVER_FILE}" >&2
echo " -n Dry run mode" >&2
echo " -s run using sudo on the remote server" >&2
echo " -v verbose mode" >&2
exit 1
}


# check that the user is not executing with superuser privileges at the outset
if [[ $UID -eq 0 ]]
then
	echo "Cannot execute this as superuser. Use the -s option instead" >&2
	usage
fi

# use getopts to parse the options - SOMETHING WRONG HERE OR IN THE SHIST FOLLOWING
while getopts f:nsv OPTION
do	
	case ${OPTION} in
	f) SERVER_LIST="${OPTARG}" ;;
	n) DRY_RUN='true' ;;
	s) SUDO='sudo' ;;
	v) VERBOSE='true' ;;
	?) usage ;;
	esac
done

# remove the options using shift and the OPTIND variable so the only argument left is the command you want to run (but how does it know which.. does it matter which order the command argument is provided?
echo "before shift we have ${#} args"
echo "optind is ${OPTIND}"
shift "$(( OPTIND - 1 ))"
echo "after shift we have ${#} args"

# if there's no arguments left, do usage function
if [[ "${#}" -lt 1 ]]
then
	usage
fi
	

# get the command as a variable
COMMAND="${@}"
echo "command was $COMMAND"


# check the server file exists

if [[ ! -e ${SERVER_FILE} ]]
then
	echo "Server file cannot be found" >&2
	exit 1
fi


set the default exit status for the rest of the script, whcih we can set to be overridden in certain situations
EXIT_STATUS='0'

# do a for loop to run through all the servers in the server file and for each run the command. Use `cat` to get the contents of the file into the for loop variable. Use the SUDO var which will either have sudo or nothing. 


for SERVER in $(cat ${SERVER_FILE})
do
	if [[ "${VERBOSE}"='true' ]]
	then
		echo "running ${COMMAND} on ${SERVER}"
	fi
done

# execute it is not set to be dry run, and save a new exit code in case of error. 
if [[ "${DRY_RUN}" = 'true' ]]
then	
	echo "DRY RUN ${COMMAND}"
else
	ssh -o ConnectTimeout=2 ${SERVER} ${SUDO} ${COMMAND}
	SSH_EXIT_STATUS="${?}" 
	if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
	then	
		EXIT_STATUS=${SSH_EXIT_STATUS}
		echo "Exe failed" >&2
	fi
fi


exit ${EXIT_STATUS}
	