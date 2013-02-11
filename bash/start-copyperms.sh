#
# [Ubuntu] Sort out Apache www-data perms
#

# Set owner:group defaults
OWNER="cny_staging"
GROUP="cny_staging"

# Add www-data user to group
usermod -G ${GROUP} www-data 

# Set directory to change
DIR="/root/dir/"

FILES=$(find ${DIR}.)
for F in $FILES
do		
	# Set owner/group 
	chown ${OWNER}:${GROUP} ${F}
	# Get file access rights
	PERMS=$(stat -c%a ${F})	
	# Apple owner => group file access rights
	chmod ${PERMS:0:1}${PERMS:0:1}${PERMS:2:1} ${F}
	echo "${PERMS:0:1}${PERMS:1:1}${PERMS:2:1} => ${PERMS:0:1}${PERMS:0:1}${PERMS:2:1} - ${F}"	
done