build_id := $(shell uuidgen | cut -c1-7)
repository_name = yungjames
project_name = npm-token-rotation
version = 1.0.0
docker_tag = ${repository_name}/${project_name}:${version}-${build_id}


.PHONY: build run push clean


build:
	docker build --tag ${docker_tag} .


run: check-env build
	docker run --rm \
	-e NPM_TOKEN=${NPM_TOKEN} \
	-e NPM_USER=${NPM_USER} \
	-e NPM_PASS=${NPM_PASS} \
	-it ${docker_tag} /bin/bash -- jobs/rotate-npm-token.sh 


push: build
	docker push ${docker_tag}


check-env:
ifeq ($(NPM_TOKEN),)
	$(error NPM_TOKEN is undefined)
endif
ifeq ($(NPM_USER),)
	$(error NPM_USER is undefined)
endif
ifeq ($(NPM_PASS),)
	$(error NPM_PASS is undefined)
endif


clean:
	docker ps -a | grep "${repository_name}/${project_name}" | \
	awk '{print $$1}' | xargs docker rm

	docker images -a ${repository_name}/${project_name} | grep -v REPO | \
	awk '{print $$3}' | xargs docker rmi -f
