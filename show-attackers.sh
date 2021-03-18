#!/bin/bash

# exercise to show repeated log in attempts and show those that have had greater than a specific number of failed attempts

# set up the limit of failed attempts first, hardcode it for now. 

LIMIT='10'


# get the file name from the command line with ${1}
LOG_FILE="${1}"

# check a file has been provided as an argument

[[ if "${#}" -lt 1 ]]
then
	echo "Supply a filename - the user's log file" >&2
	exit 1
fi

# set up a pipe to get the IPs that we want- the following steps produce two columns of data - a count, and an IP address. It does not filter for the limit yet.

# First you can pull out all the failed attempts by matching with grep on the word "Failed". 

# Now pipe that to reverse grep (with v) to remove all those failed attempts by the account owner with the word "root". 

# Then isolate the IP address by splitting the line with the previous word, using awk with "from " as a field separator, printing the IP address with {print $2}

# now we have the IP number at the start of each row, and we only have rows with failed attempts from a user other than root. Do a cut to just get the IP address from these rows. 

# now pipe to sort and then to uniq to get each IP address listed uniquely, with the number of occurrences. 

# now pipe that to a numerical sort to see the IP addresses listed by number of attempts (greatest first)


# grep Failed syslog-sample | grep -v root | awk -F 'from' '{print $2}' | cut -d ' ' -f 1 | sort | uniq -c | sort -nr


# now set up a loop to work through the IPs in the output. Use while read COUNT IP to read the two columns


grep Failed syslog-sample | grep -v root | awk -F 'from' '{print $2}' | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | while read COUNT IP
do
	if [[ "${COUNT}" -gt "${LIMIT}" ]] # if the number of attempts is above the limit we set
	then
		LOCATION=$(geoiplookup ${IP}) # set a location var using the geoiplookup command on the current IP address
		echo "${COUNT} ${IP} ${LOCATION}" # print the output for those that exceed limit
	fi
done

exit 0


