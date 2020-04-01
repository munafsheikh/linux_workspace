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

f(){
	echo 'Searching for:' $1
	grep  -R $1 *
}


selectProject() {
  if [ -z "$1" ]; then 
    local cmd=(dialog --keep-tite --menu  "Select Project:" 22 76 16)
    local options=(	 proj1 ""    # any option can be set to default to "on"
	                  proj2 ""
	                  proj3 "")

    local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    echo ${choices[@]}
  else
    echo $1
  fi
}


export PATH="/home/dev/Projects/bin:/usr/local/go/bin:/bin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/home/dev/.vimpkg/bin"

