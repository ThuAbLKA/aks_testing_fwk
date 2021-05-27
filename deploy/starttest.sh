#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir="`pwd`"

#Get namesapce variable

jmx="$1"
[ -n "$jmx" ] || read -p 'Enter path to the jmx file ' jmx

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

test_name="$(basename "$jmx")"

#Get Master pod details

master_pod=`kubectl get po  | grep jmeter-master | awk '{print $1}'`

kubectl cp "$jmx"  "$master_pod:/$test_name"

# set the JMTR user.properties to include reporting
kubectl cp ./jmeter/user.properties "$master_pod:/jmeter/apache-jmeter-*/bin/user.properties"

# add template file
kubectl exec -it $master_pod -- /bin/bash touch /jmeter/template.csv

# create reporting folder
kubectl exec -it $master_pod -- /bin/bash mkdir /jmeter/reporting

## Echo Starting Jmeter load test

kubectl exec -ti $master_pod -- /bin/bash /load_test "$test_name"