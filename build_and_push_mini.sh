git checkout mini || exit 1

docker buildx build 					\
       --push 						\
       --platform linux/arm/v7,linux/amd64,linux/arm64 	\
       --tag saspus/duplicacy-web:mini			\
       .
