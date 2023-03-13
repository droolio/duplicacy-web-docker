git checkout master || exit 1

export DUPLICACY_WEB_VERSION=1.7.2

docker buildx build \
		--push								\
		--platform linux/arm/v7,linux/amd64,linux/arm64			\
		--build-arg DUPLICACY_WEB_VERSION=${DUPLICACY_WEB_VERSION} 	\
		--tag saspus/duplicacy-web:latest 				\
		--tag saspus/duplicacy-web:v${DUPLICACY_WEB_VERSION} 		\
		.
