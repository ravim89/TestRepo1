sudo ./root/Automation_Project/automation.sh


$timestamp=$(date '+%d%m%Y-%H%M%S')
$myname='Ravi'
$s3_bucket=s3://upgrad-ravicourseassignment


##Perform apt update
apt update -y


##check apache2
apache2server=$(service apache2 status)

##Validate if apache2 is installed and running, if not install and run.
if [[ $apache2server == *"active (running)"* ]]; then
	echo "apache2 is installed and running"
elif [[ $apache2server == *"inactive (dead)"* ]]; then
	service apache2 start
	echo "apache2 installed, but was not running. Hence running it now."
else 
	echo "apache 2 not installed"
	apt install apache2
	service apache2 start
	if [[ $(service apache2 status) == *"active (running)"* ]]; then
		echo "apache is installed and is running."
	fi
fi


##Check if apache2 is enabled for startup
apache2enabled=$(systemctl list-unit-files --state=enabled | grep apache2.service)


##Validate apache2 is enabled if not enable it using systemclt
if [[ $apache2enabled == *"enabled"* ]]; then
	echo "apache2 service is enabled already."
else
	systemctl enable apache2
	echo "apache2 service enabled now."
	
##Archive the log files using tar and delete the log files once the tar is created. Copy the tar file to tmp directory for further operations.

tar -zcvf ${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log && rm -f /var/log/apache2/*.log && cp ${myname}-httpd-logs-${timestamp}.tar /tmp/${myname}-httpd-logs-${timestamp}.tar

## Copy the tar file from tmp directory to AWS S3 bucket.
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

