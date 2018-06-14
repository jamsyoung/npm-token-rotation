# NPM Token Rotation Service

A docker image that runs a script that will rotate an npm autentication token.
Intended to be run as a CronJob in a k8s cluster on a schedule.

## Requirements

- [`docker`](https://docs.docker.com/docker-for-mac/install/)
- [`gcloud`](https://cloud.google.com/sdk/docs/quickstart-macos)
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [`make`](http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/)
- shell commands: `awk`, `grep`, `xargs`

## CLI Commands

These commands assume you are properly authorized everywhere.

```bash
## To run on localhost
$ NPM_TOKEN=token NPM_USER=user NPM_PASS=pass jobs/rotate-npm-token.sh
Revoking 890ec2
Removed 1 token
Done!
Creating read-only token
Done!

## To build and run in a docker container on localhost
$ NPM_TOKEN=token NPM_USER=user NPM_PASS=pass make run
docker build --tag yungjames/npm-token-rotation:0.0.1-E7155A7 .
Sending build context to Docker daemon  91.14kB
Step 1/3 : FROM node:10.4.1
 ---> 4df1f3e94ef9
Step 2/3 : WORKDIR /app
 ---> Using cache
 ---> 265ef53bc83a
Step 3/3 : ADD . /app/
 ---> Using cache
 ---> 39e4e82a1105
Successfully built 39e4e82a1105
Successfully tagged yungjames/npm-token-rotation:0.0.1-E7155A7
docker run --rm \
        -e NPM_TOKEN=token \
        -e NPM_USER=user \
        -e NPM_PASS=pass \
        -it yungjames/npm-token-rotation:0.0.1-E7155A7 /bin/bash -- jobs/rotate-npm-token.sh
Revoking bd61a4
Removed 1 token
Done!
Creating read-only token
Done!


## To build and push to DockerHub
$ make push
docker build --tag yungjames/npm-token-rotation:0.0.1-EC553C6 .
Sending build context to Docker daemon   93.7kB
Step 1/3 : FROM node:10.4.1
 ---> 4df1f3e94ef9
Step 2/3 : WORKDIR /app
Removing intermediate container d588e0496da8
 ---> 953473c912cb
Step 3/3 : ADD . /app/
 ---> 534a8c65b141
Successfully built 534a8c65b141
Successfully tagged yungjames/npm-token-rotation:0.0.1-EC553C6
docker push yungjames/npm-token-rotation:0.0.1-EC553C6
The push refers to repository [docker.io/yungjames/npm-token-rotation]
70cfd893a52e: Pushed
7683e1aac1a1: Pushed
9781a4b557c7: Layer already exists
9ceb65bfc1c5: Layer already exists
0b3c2dee153a: Layer already exists
9ba7f6deb379: Layer already exists
f3693db46abb: Layer already exists
bb6d734b467e: Layer already exists
5f349fdc9028: Layer already exists
2c833f307fd8: Layer already exists
0.0.1-EC553C6: digest: sha256:edb69213af8d9910f520ac6859f6930acb008cb8e39eb2d8e9d2fdf7015b669e size: 2422


## To remove all local docker remanents of this project from localhost
$ make clean
docker ps -a | grep "yungjames/npm-token-rotation" | \
        awk '{print $1}' | xargs docker rm
docker images -a yungjames/npm-token-rotation | grep -v REPO | \
        awk '{print $3}' | xargs docker rmi -f
Untagged: yungjames/npm-token-rotation:0.0.1-EC553C6
Untagged: yungjames/npm-token-rotation@sha256:edb69213af8d9910f520ac6859f6930acb008cb8e39eb2d8e9d2fdf7015b669e
Deleted: sha256:534a8c65b141f8a262393e4726f88dd768ac963ba9b009adeb7bf92abe260664
Deleted: sha256:98c27c292bff112e2c5ece21698d0a784775bb34b226fee2970c79d3c16f1f6e
Deleted: sha256:953473c912cbe98ed704af2e938c581d94fd7a32e05e94eeab4c3b3bccc2362d
Deleted: sha256:f158ae845dc5f8efef8de0a2827147fd52a3058ade93ecf0a2df60dcb2646f18


## To delete the existing k8s CronJob in GKE on GCP
$ kubectl delete cronjob npm-token-rotation
cronjob "npm-token-rotation" deleted


## To create the k8s CronJob in GKE on GCP
$ kubectl create -f cronjob.yml
cronjob "npm-token-rotation" created


## To modify the existing k8s CronJob in GKE on GCP
$ kubectl apply -f cronjob.yml
cronjob "npm-token-rotation" configured


## Get the status of an existing CronJob in GKE on GCP
$ kubectl describe cronjob npm-token-rotation
Name:                       npm-token-rotation
Namespace:                  default
Labels:                     <none>
Schedule:                   @hourly
Concurrency Policy:         Allow
Suspend:                    False
Starting Deadline Seconds:  <unset>
Selector:                   <unset>
Parallelism:                <unset>
Completions:                <unset>
Pod Template:
  Labels:  <none>
  Containers:
   npm-token-rotation:
    Image:  yungjames/npm-token-rotation:0.0.1-EC553C6
    Port:   <none>
    Command:
      /app/jobs/rotate-npm-token.sh
    Environment:
      NPM_TOKEN:     <set to the key 'token' in secret 'npm-token-rotation-npmuser-creds'>  Optional: false
      NPM_USER:      <set to the key 'user' in secret 'npm-token-rotation-npmuser-creds'>   Optional: false
      NPM_PASS:      <set to the key 'pass' in secret 'npm-token-rotation-npmuser-creds'>   Optional: false
    Mounts:          <none>
  Volumes:           <none>
Last Schedule Time:  Thu, 14 Jun 2018 18:23:00 -0400
Active Jobs:         <none>
Events:
  Type    Reason            Age   From                Message
  ----    ------            ----  ----                -------
  Normal  SuccessfulCreate  11m   cronjob-controller  Created job npm-token-rotation-1529014980
  Normal  SawCompletedJob   11m   cronjob-controller  Saw completed job: npm-token-rotation-1529014980


## To delete the npm-cnnlabs-creds secret
$ kubectl delete secret npm-token-rotation-npmuser-creds
secret "npm-token-rotation-npmuser-creds" deleted


## To create the npm-cnnlabs-creds secert
$ kubectl create secret generic npm-token-rotation-npmuser-creds \
  --from-literal=user='user' \
  --from-literal=pass='pass' \
  --from-literal=token='token'
secret "npm-token-rotation-npmuser-creds" created


## To view logs on a pod in GKE on GCP
$ kubectl logs npm-token-rotation-1529014980-gsmnw
Revoking 3f25f0
Removed 1 token
Done!
Creating read-only token
Done!
```
