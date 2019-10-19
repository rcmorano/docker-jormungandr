# Build

Execute from repo root dir:

```
JORMUNGANDR_VERSION=0.6.5
JORMUNGANDR_COMMIT=v0.6.5 # commit/tag/branch to checkout scripts from
docker build -t rcmorano/jormungandr:${JORMUNGANDR_VERSION} \
  --build-arg JORMUNGANDR_VERSION=${JORMUNGANDR_VERSION} \
  --build-arg JORMUNGANDR_COMMIT=${JORMUNGANDR_COMMIT} .
```

# Run

Execute from repo root dir:

```
docker-compose up -d
```

Container's entrypoint will: 
* Pull the `rcmorano/jormungandr:0.6.5` from the hub if wasn't built locally
* Bootstrap the node if the necessary files are not present in `$DATA_DIR`, which defaults to `/data` and is bind mounted from `$GIT_REPO_DIR/data`.
* Run `jormungandr` with default config 

## Checking logs

Execute from repo root dir:

```
docker-compose logs -f
```

## Using jcli

Execute from repo root dir:
```
docker-compose exec jormungandr jcli
# or execute an interactive shell
docker-compose exec jormungandr bash
```

# Debug

If you use docker-compose to bring the whole thing up, the entrypoint is bind mounted to easily debug things without having to rebuild the image.
