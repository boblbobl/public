#
# [Ubuntu] Sort out Apache www-data perms
#
# This script will cope the user permission to the group permission
#

# Set owner:group defaults
OWNER="username"
GROUP="groupname"

# Add www-data user to group
usermod -G ${GROUP} www-data 
# Added to group that allows scp (/ets/sshd_config)
usermod -G filetransfer ${OWNER}

# Set directory to change
DIR="/dir1/dir2/"

FILES=$(find ${DIR}.)
for F in $FILES
do		
	# Set owner/group 
	chown ${OWNER}:${GROUP} ${F}
	# Get file access rights
	PERMS=$(stat -c%a ${F})	
	# Apply owner => group file access rights
	chmod ${PERMS:0:1}${PERMS:0:1}${PERMS:2:1} ${F}
	echo "${PERMS:0:1}${PERMS:1:1}${PERMS:2:1} => ${PERMS:0:1}${PERMS:0:1}${PERMS:2:1} - ${F}"	
done