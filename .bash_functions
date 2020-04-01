pumlit(){
	echo "pUMLit is an plantuml extractor for source code."
	echo "it recursively searches for files with //@puml <plantuml text>" 
	echo "and writes it to a file with the name <filename>.ms.puml. These"
	echo "files can then be rendered in a plantuml viewer (intelliJ etc)"
	echo "The idea here is to bring documentation closer to code thus"
	echo "promoting easier understanding of complex systems."
	echo "Munaf Sheikh v1.0"
	echo "munaf.sheikh@gmail.com | SuperMunaf"

 	find . -name "*.ms.puml" -type f -delete
	grep -F -R -i '//@puml' * | awk '{ gsub("  ", ""); print $0 }' | awk -F ' |:' '{ fn=$1".ms.puml"; $1=$2=""; print $0 > fn }'

}


gitUpdateCommits(){
  export commitM=`git log | grep "fix" | head -n 1`
  echo "git unstage, uncommit"
  gsr
  echo "git add commit..."
  gac "$commitM"
  echo "git push origin branch force"
  gpof
}

gLRd() {
 if [ -z "$1" ]; then 
  echo "specify a branch to delete locally and remote"		
 else
  gLd $1
  gRd $1
 fi
}

getCurrentGitBranch() {
 git branch &>/dev/null
 local OUTCOME=$?
 if [ $OUTCOME -eq 128 ] 
 then
  return 1
 else
  git branch | grep '*' | cut -f2 -d' ' 
 fi
}

export DOCKER_USER_ID=$(id -u)
export DOCKER_USER_NAME=$(id -un)




SUCCESS() {
    exit 0
}

FAILURE() {
    exit 1
}

selectEnvironment() {
  if [ -z "$1" ]; then 
    local cmd=(dialog --keep-tite --menu  "Select Environment:" 22 76 16)
    local options=(dev ""    # any option can be set to default to "on"
			 int "" )
    local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    echo ${choices[@]}
  else
    echo $1
  fi
}


kContext() {
 if [ -z "$1" ]; then 
  echo "specify an environment (dev/int/uat)"		
 else
  if [ $1 = 'dev' ]
  then
  	kubectl config use-context dev
  elif [ $1 = 'int' ]; then
  	kubectl config use-context dev
  elif [ $1 = 'uat' ]; then
  	kubectl config use-context uat
  else
      	echo "specify an environment (dev/int/uat)"		
  fi
 fi
}

k() {
   local ENVIRO=`selectEnvironment $1`
   kContext $ENVIRO
   #kubectl config use-context $ENVIRO
   kubectl get po -n $ENVIRO | grep -v "Completed"   
}


kr() {

 local ENVIRO=`selectEnvironment $1`
 kubectl delete po -n $ENVIRO -l project="$2"
}

ks() {
  kubectl scale deploy -n $1 $2 --replicas="$3" 
}

kl() {
  kubectl logs -n $1 $2 $3
}

failStageIfURLDown(){
  echo "==== testing: [" $1 "] response: ======="
  curl -I $1
  echo "---- Pod outcome -----"
  if [ `curl -I $1 | head -n 1 | grep -v "500" | wc -l` -eq 1 ]
  then
    exit 0
  else
    exit 1
  fi
}

krvb(){
 local ENVIRO=`selectEnvironment $1`
 kr $ENVIRO api-voice-biometrics
}


krvr(){
 local ENVIRO=`selectEnvironment $1`
 kr $ENVIRO api-voice-recording
}

krvbl(){
 local ENVIRO=`selectEnvironment $1`
 kr $ENVIRO app-voice-biometrics-listener
}


krvoice(){
 local ENVIRO=`selectEnvironment $1`
 kr $ENVIRO app-voice-biometrics-listener
 kr $ENVIRO api-voice-biometrics
 kr $ENVIRO api-voice-recording
}

monitor(){
	echo "Launches an infinite loop of monitoring a file and executing a build"
	echo "Use arg1=file to monitor.  arg2=command/script to execute."
	l
	local FILE=$1
	local COMMD=${@:2}


	while true
	do 	
		echo 'Monitoring.... ' $1
		~/.sleep_until_modified.sh $1
		echo 'Change detected in ' $1
echo 		$COMMD
	done 
}

declare -x ENVIRONMENT_PROPERTIES_PATH=/home/dev/environment

AUTH_TOKEN='Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImphY3F1ZXN2ZHciLCJleHAiOjQwNzA5MDg4MDB9.C7fLFrHKacM6baXuWO9ZZGwFjX2ykB3YCbrScUM8Bec'


f(){
	echo 'Searching for:' $1
	grep  -R $1 *
}


selectProject() {
  if [ -z "$1" ]; then 
    local cmd=(dialog --keep-tite --menu  "Select Project:" 22 76 16)
    local options=(	 architects ""    # any option can be set to default to "on"
	                  client-comms ""
	                  crm ""
	                  products ""
	                  falcons ""
	                  weavers ""
	                  transactions ""
	                  product-rules ""
	                  fusion ""
	                  alchemist ""
	                  wolwe ""
	                  mobility "")

    local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    echo ${choices[@]}
  else
    echo $1
  fi
}

t(){

	if [ -z "$1" ]; then 
		clear
		echo 'RUNNING WITH DEFAULTS test:dev:crm'
    		docker-compose run --rm tool npm run test:dev:all
        else
		local ENVIRO=$1
		clear
		echo "RUNNING AGAINST " $1
  		docker-compose run --rm tool npm run test:$1:all

	fi
	
}

export PATH="/home/dev/Projects/bin:/usr/local/go/bin:/bin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/home/dev/.vimpkg/bin"

