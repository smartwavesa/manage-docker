eval "$1 docker rm $($1 docker ps -a  -f 'status=exited' -q --no-trunc)" || true
eval "$1 docker rmi $($1 docker images --filter 'dangling=true' -q --no-trunc)" || true