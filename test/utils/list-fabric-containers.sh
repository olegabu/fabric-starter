curl -s --unix-socket /var/run/docker.sock -X GET http:/v1.24/containers/json?all=true | \
jq -r '.[] | .Names + [.State] +[.HostConfig.NetworkMode] + [.Status] | .[0]+ " "+.[1] + " " +.[2] + " " + .[3]' | \
grep "fabric-starter" | grep "example.com " | sed -e 's/\///' | cut -d' ' -f 1,4 | sort | grep " Up" | cut -d " " -f 1

echo

docker container ls -a -q | \
xargs docker container inspect -f "{{index .NetworkSettings.Networks}} {{.Name}} {{.State.Running}}" | \
grep fabric-starter | cut -d ' ' -f 2,3 | sed -e 's/\///' | grep "example.com " | grep " true" | cut -d ' ' -f 1 | sort
