build_id := $(shell uuidgen | cut -c1-7)
repository_name = yungjames
project_name = npm-token-rotation
version = 0.0.1
docker_tag = ${repository_name}/${project_name}:${version}-${build_id}

build:
	docker build --tag ${docker_tag} .

run: build
	docker run --rm -e "NPM_TOKEN=${NPM_TOKEN}" -it ${docker_tag} /bin/bash -- jobs/rotate-npm-token.sh

push: build
	docker push ${docker_tag}

clean:
	docker ps -a | grep "${repository_name}/${project_name}" | awk '{print $$1}' | xargs docker rm
	docker images -a ${repository_name}/${project_name} | grep -v REPO | awk '{print $$3}' | xargs docker rmi -f
