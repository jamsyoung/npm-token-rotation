# NPM Token Rotation

This is a bash script that can be run in a variety of ways. It was designed to run as a CronJob in
GKE on GCP with a very specific job to do.

1.  delete all existing read-only tokens on a given npm user account
2.  create a new read-only token on said account
3.  store said token somehwere TBD

The GKE CronJob schedule provides the rotation period.

## Requirements

- [`docker`](https://docs.docker.com/docker-for-mac/install/)
- [`gcloud`](https://cloud.google.com/sdk/docs/quickstart-macos)
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [`make`](http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/)
- shell commands: `awk`, `grep`, `xargs`

## CLI Commands

These commands assume you are properly authorized everywhere.

Required ENVIRONMENT variables:

- `NPM_TOKEN` - The NPM_TOKEN for the npm user account tokens will be created on
- `NPM_USER` - The username of said account
- `NPM_PASSWORD` - The password of said account

### Doing things on localhost

#### To run directly

```bash
$ NPM_TOKEN=token NPM_USER=user NPM_PASS=pass jobs/rotate-npm-token.sh
```

#### To build and run in a docker container

```bash
$ NPM_TOKEN=token NPM_USER=user NPM_PASS=pass make run
```

#### To build and push to DockerHub

```bash
$ make push
```

#### To remove all local docker remanents of this project

```bash
$ make clean
```

### Doing things in GKE on GCP

#### To delete the existing k8s CronJob

```bash
$ kubectl delete cronjob npm-token-rotation
```

#### To create the k8s CronJob

```bash
$ kubectl create -f cronjob.yml
```

#### To modify the existing k8s CronJob

```bash
$ kubectl apply -f cronjob.yml
```

#### Get the status of an existing CronJob

```bash
$ kubectl describe cronjob npm-token-rotation
```

#### To delete the npm-token-rotation-npmuser-creds secret

```bash
$ kubectl delete secret npm-token-rotation-npmuser-creds
```

#### To create the npm-token-rotation-npmuser-creds secert

```bash
$ kubectl create secret generic npm-token-rotation-npmuser-creds \
  --from-literal=user='user' \
  --from-literal=pass='pass' \
  --from-literal=token='token'
```

#### To view logs on a pod

```bash
$ kubectl logs npm-token-rotation-1529014980-gsmnw
```
