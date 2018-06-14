# NPM Token Rotation Service

A docker image that runs a script that will rotate an npm autentication token.
Intended to be run as a CronJob in a k8s cluster on a schedule.

## Requires

- `docker`
- `envsubst` - `brew install gettext && brew link --force gettext`
- `gcloud`
- `kubectl`
- `make`
- `vim` (or equivalent editor)
- shell commands: `awk`, `grep`, `xargs`

## CLI Commands

These commands assume you are properly authorized everywhere.

```bash
## To build and run on localhost
$ ./jobs/rotate-npm-token.sh

## To build and run in a docker container on localhost
$ make run

## To build and push to DockerHub
$ make push

## To remove all local docker remanents of this project from localhost
$ make clean

## To delete the existing k8s CronJob in GKE on GCP
$ kubectl delete cronjob npm-token-rotation

## To create the k8s CronJob in GKE on GCP
$ kubectl create -f cronjob.yml

## To modify the existing k8s CronJob in GKE on GCP
$ vim cronjob.yml   # change something
$ kubectl apply -f cronjob.yml
```
