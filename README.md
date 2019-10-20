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

Customize the environment in docker-compose.yaml and execute this from repo root dir:

```
docker-compose up -d
```
It will then:
* Pull the `rcmorano/jormungandr:0.6.5` from the hub if wasn't built locally
* Bootstrap the node if the necessary files are not present in `$DATA_DIR`, which defaults to `/data` and is bind mounted from `$GIT_REPO_DIR/data`.
* Run `jormungandr` with default config 


You can also run it using plain docker:
```
JORMUNGANDR_VERSION=0.6.5
JORMUNGANDR_EXTRA_ARGS=--enable-explorer
JORMUNGANDR_BLOCK0_HASH=_CHANGE_ME_ \
PUBLIC_PORT=8300
docker run -d --name jormungandr-${JORMUNGANDR_VERSION} \
  -v $HOME/.jormungandr-${JORMUNGANDR_VERSION}:/data \
  -p $PUBLIC_PORT:8299 \
  -e PUBLIC_PORT=$PUBLIC_PORT \
  -e JORMUNGANDR_BLOCK0_HASH=$JORMUNGANDR_BLOCK0_HASH \
  -e JORMUNGANDR_EXTRA_ARGS=$JORMUNGANDR_EXTRA_ARGS \
  emurgornd/jormungandr:${JORMUNGANDR_VERSION}
```

Note that if no `$JORMUNGANDR_BLOCK0_HASH` was provided, the node will be started with the bootstrapped/generated genesis block.

## Environment variables

| VARIABLE                   | Description                                                                  |
| -------------------------- | ---------------------------------------------------------------------------- |
| JORMUNGANDR_EXTRA_ARGS     | Extra arguments to pass to the daemon                                        |
| JORMUNGANDR_BLOCK0_HASH    | Genesis block to use instead of local bootstrapped genesis                   |
| PUBLIC_ADDRESS             | Force daemon to publish this address. If not provided, will be guessed       |
| PUBLIC_PORT                | Port to be published to the internet. If not provided, defaults to 8299      |
| DATA_DIR                   | Data dir to be used inside the container. Defaults to `/data`                |
| DEBUG                      | Sets entrypoint bash script in debug mode                                    |

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
