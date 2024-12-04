
#!/bin/bash
# 
# Set Variables  
# Virginia us-east-1
# Oregon us-west-2

REGION="us-west-2"
MESSAGE="Deploy Upgrade Wazuh 4.1 Region "$REGION"\n\r"
SSHPAIR="/home/leandroferrari/Talsoft/Clientes/Mejuri/leandrooregon.pem"
#SSHPAIR_VIRGINIA="/home/leandroferrari/Talsoft/Clientes/Mejuri/leandro.pem"
#SSHPAIR_OREGON="/home/leandroferrari/Talsoft/Clientes/Mejuri/leandrooregon.pem"


helpFunction()
{
   echo ""
   echo "Usage: $0 -r region"
   echo -e "\t-r Region to setting WAZUH system"
   exit 1 # Exit script after printing help
}


while getopts "r:" opt
do
   case "$opt" in
      r ) regionW="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$regionW" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

#SET REGION PARAMETER
REGION=$regionW
echo "Region Wazuh Instances: "$REGION


echo "Get Default values from Oregon Region"
#OREGON WAZUH INSTANCES
#WAZUHKIBANA=$(aws  cloudformation list-exports --query "Exports[?Name=='Instance-WazuhKibana'].Value" --no-paginate --output text  --region $REGION 2>&1)
#ELASTICB=$(aws  cloudformation list-exports --query "Exports[?Name=='Instance-ElasticMasterB'].Value" --no-paginate --output text  --region $REGION 2>&1)
#ELASTICC=$(aws  cloudformation list-exports --query "Exports[?Name=='Instance-ElasticMasterC'].Value" --no-paginate --output text  --region $REGION 2>&1)
#ELASTICD=$(aws  cloudformation list-exports --query "Exports[?Name=='Instance-ElasticMasterD'].Value" --no-paginate --output text  --region $REGION 2>&1)
#ELASTICE=$(aws  cloudformation list-exports --query "Exports[?Name=='Instance-ElasticMasterE'].Value" --no-paginate --output text  --region $REGION 2>&1)
#ELASTICBOOT=$(aws  cloudformation list-exports --query "Exports[?Name=='Instance-ElasticBootstrap'].Value" --no-paginate --output text  --region $REGION 2>&1)
WAZUHM=$(aws  cloudformation list-exports --query "Exports[?Name=='WazuhMasterIP-$REGION'].Value" --no-paginate --output text  --region $REGION 2>&1)
WAZUHW=$(aws  cloudformation list-exports --query "Exports[?Name=='WazuhWorkerIP-$REGION'].Value" --no-paginate --output text  --region $REGION 2>&1)

if [ "$REGION" = "us-east-1" ]; then
    echo "Setting Wazuh instances to Virginia Region"
	#VIRGINIA WAZUH INSTANCES
#	WAZUHKIBANA="54.173.112.54"
#	ELASTICB="3.89.145.75"
#	ELASTICC="54.161.48.154"
#	ELASTICD="35.153.157.85"
#	ELASTICE="3.210.67.130"
#	ELASTICBOOT="52.86.200.68"
	WAZUHM="54.164.8.109"
	WAZUHW="54.144.135.213"
	SSHPAIR="/home/leandroferrari/Talsoft/Clientes/Mejuri/leandro.pem"
	echo "Using key pair: "$SSHPAIR
else
    echo "Setting Wazuh instances to Oregon Region"
fi


MESSAGE=""
# Functions


# Check Command
function check_command(){
	for command in "$@"
	do
	    type -P $command &>/dev/null || fail "Unable to find $command, please install it and run this script again."
	done
}

# Horizontal Rule
function HorizontalRule(){
	echo "============================================================"
}

# Fail
function fail(){
	tput setaf 1; echo "Failure: $*" && tput sgr0
	exit 1
}

# Check required commands
check_command aws jq

# Verify AWS CLI Credentials are setup
# http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
if ! grep -q aws_access_key_id ~/.aws/config; then
	if ! grep -q aws_access_key_id ~/.aws/credentials; then
		fail "AWS config not found or CLI not installed. Please run \"aws configure\"."
	fi
fi

# Check for AWS CLI profile argument passed into the script
# http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles
#if [ $# -eq 0 ]; then
#	scriptname=`basename "$0"`
#	echo "Usage: ./$scriptname profile"
#	echo "Where profile is the AWS CLI profile name"
#	echo "Using default profile"
#	echo
echo "Setting Profile AWS Default"
profile=default
#else
#	profile=$1
#fi


function upgradeWazuhServices(){
	echo
	MESSAGE="Setting Wazuh"
	
	HorizontalRule
	echo "Setting Wazuh system"
    for s in $WAZUHW $WAZUHM
    do
        echo "Connect to ..." ${s} 
        scp -i $SSHPAIR ./aws-dynamodb-add-event ec2-user@${s}:/tmp/
		scp -i $SSHPAIR ./insertIPToDynamoDB.py  ec2-user@${s}:/tmp/
		ssh -o ConnectTimeout=10 -i $SSHPAIR ec2-user@${s} 'bash -s' < step_1.sh
		
    done

}

echo "Start setting Wazuh - Detection IP Shellshock attack and block WAFv2"

start=`date +%s`
echo "Started Time: "$start

upgradeWazuhServices

end=`date +%s`
runtime=$((end-start))
hours=$((runtime / 3600)) 
minutes=$(( (runtime % 3600) / 60 ))
seconds=$(( (runtime % 3600) % 60 ))
echo "Runtime: "$hours:$minutes:$seconds"(hh:mm:ss)"

MESSAGE1+=$MESSAGE" Runtime Check: "$hours:$minutes:$seconds"(hh:mm:ss)"
echo "Message: "$MESSAGE1
echo "Test inside agent Shellshock attack localhost"
echo "Finish -- Enjoy!!!"

