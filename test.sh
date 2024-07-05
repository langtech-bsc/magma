docker_sha=$(md5sum "README.md" 2>/dev/null | awk '{print $1}')
req_sha=$(md5sum "fssfsf" 2>/dev/null | awk '{print $1}')

docker_sha=${docker_sha:-null}
req_sha=${req_sha:-null}

echo $docker_sha
echo $req_sha
