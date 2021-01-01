# Main Package Details
APP=$(subst .,-,$(subst Package: ,,$(shell grep "Package: " DESCRIPTION)))
VER=$(subst Version: ,,$(shell grep "Version: " DESCRIPTION))
REP=tjpalanca/apps
LAT_IMG=$(REP):$(APP)-latest
VER_IMG=$(REP):$(APP)-v$(VER)
CCH_IMG=$(REP):$(APP)-cache

# Testing Environment
BUILD_ARGS=
ENV_VARS=\
	--env R_CONFIG_ACTIVE="cicd" \
	--env TMDB_API_KEY="${TMDB_API_KEY}" \
	--env TRAKT_CLIENT_ID="${TRAKT_CLIENT_ID}"
TEST_PORT=3838
TEST_NAME=test
GHA_ENV_VARS= \
	--env R_CONFIG_ACTIVE="cicd" \
	--env GITHUB_ACTIONS="$(GITHUB_ACTIONS)" \
	--env GHA_JOB_ID="$(GHA_JOB_ID)" \
	--env GITHUB_RUN_ID="$(GITHUB_RUN_ID)"
NODENAME=$(shell kubectl get pod $(HOSTNAME) -o=jsonpath={'.spec.nodeName'})

# Cloud66 Redeployment Details
C66_DEPLOY_HOOK=${C66_DEPLOY_HOOK}
C66_DEPLOY_SERVICES=

# Log in to docker hub
dockerhub-login:
	echo ${DOCKERHUB_PASSWORD} | docker login \
		-u ${DOCKERHUB_USERNAME} \
		--password-stdin

# Pull the cache image
pkg-build-pull:
	-docker pull $(CCH_IMG)

# Build the image
pkg-build:
	docker build -f Dockerfile \
		--cache-from $(CCH_IMG) \
		$(BUILD_ARGS) \
		--tag $(VER_IMG) --tag $(CCH_IMG) .

# Build the image (dev)
pkg-build-dev:
	docker build -f Dockerfile \
		$(BUILD_ARGS) \
		--tag $(VER_IMG) --tag $(CCH_IMG) .

# Bash into the built image
pkg-bash:
	docker run -it --rm $(VER_IMG) bash

# Push the cache image
pkg-build-push:
	docker push $(CCH_IMG)

# Publish the image into the latest
pkg-publish:
	docker push $(VER_IMG) && \
	docker tag $(VER_IMG) $(LAT_IMG) && \
	docker push $(LAT_IMG)

# Deploy to Cloud66
pkg-deploy:
	curl -X POST $(C66_DEPLOY_HOOK)?services=$(C66_DEPLOY_SERVICES)

# Run the package test suite
pkg-test:
	docker run -t --rm \
        $(GHA_ENV_VARS) \
		$(ENV_VARS) \
		$(VER_IMG) \
		Rscript -e "watch.something::dev_cicd_test_package()"

# Measure package test coverage
pkg-test-coverage:
	mkdir -p /tmp/watch.something && \
	sudo chown -R 1000:1000 /tmp/watch.something && \
	docker run -t --rm \
		-v /tmp/watch.something:/tmp/watch.something \
		$(GHA_ENV_VARS) \
		$(ENV_VARS) \
		$(VER_IMG) \
		Rscript -e "watch.something::dev_cicd_test_coverage()"

# Test for linting errors
pkg-test-linting:
	docker run -t --rm \
	    $(GHA_ENV_VARS) \
	    $(ENV_VARS) \
		$(VER_IMG) \
		Rscript -e "watch.something::dev_cicd_test_linting()"

# Test for spelling errors
pkg-test-spelling:
	docker run -t --rm \
	    $(GHA_ENV_VARS) \
	    $(ENV_VARS) \
		$(VER_IMG) \
		Rscript -e "watch.something::dev_cicd_test_spelling()"

# Release the package on github
pkg-release:
	docker run -t --rm \
		-e GITHUB_PAT \
		$(VER_IMG) \
		Rscript -e "watch.something::dev_release_package()"

# Build and deploy documentation
pkg-docs-deploy:
	[ -z "$$GITHUB_ACTIONS" ] && \
	make pkg-docs-build-dev || \
	make pkg-docs-build-gha && \
	git add docs/* && \
	git commit -m "Update package documentation" && \
	git push

pkg-docs-build-gha:
	mkdir -p docs && \
	docker run -t --rm \
		-v $(shell pwd)/docs:/watch.something/docs \
		$(VER_IMG) \
		Rscript -e "pkgdown::build_site();" && \
	git config --global user.name 'GitHub Actions' && \
	git config --global user.email 'actions@github.com'

pkg-docs-build-dev:
	mkdir -p docs && \
	docker run -t --rm \
		--user 1000:1000 \
		-v /mnt/data-store$(shell pwd)/docs:/watch.something/docs \
		$(VER_IMG) \
		Rscript -e "pkgdown::build_site();"

# Test your application on a test URL
kube-test-start:
	kubectl run $(APP) \
		--image=$(VER_IMG) \
		--port=$(TEST_PORT) \
		$(ENV_VARS) \
		--overrides='{"apiVersion": "v1", "spec": { "nodeName" : "$(NODENAME)" } }' && \
	kubectl expose pod/$(APP) \
		--name=$(TEST_NAME) \
		--port=80 \
		--target-port=$(TEST_PORT)

# Test in Kubernetes Cluster
kube-test-stop:
	kubectl delete svc/$(TEST_NAME) & \
	kubectl delete pod/$(APP)

# Restart through iterative testing
kube-test-restart:
	make kube-test-stop && \
	make pkg-build && \
	make kube-test-start

# Surface logs
kube-logs:
	kubectl logs $(APP)
