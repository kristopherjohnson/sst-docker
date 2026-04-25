# Super Star Trek (Dockerized)

A multi-arch Docker image of the classic Super Star Trek text adventure
by David Matuszek, Paul Reynolds, Don Smith, and Tom Almy (with later
contributions by Erik Olofsen). The image runs on `linux/amd64` and
`linux/arm64` and is built `FROM scratch` using a statically linked
musl binary, so the final image is well under 1 MB.

The original C source is in this repository. See [`LICENSE`](LICENSE)
for full author attribution and the licensing terms governing both the
game and the embedded BSD-3 `CAPTURE` code.

## Run from Docker Hub

The image is published as `oldmankris/sst` on Docker Hub.

```sh
docker run -it --rm oldmankris/sst
```

`-it` is required: the game reads from stdin and is interactive.
`--rm` removes the container when you exit.

Docker will automatically pull the matching image for your architecture
(arm64 on Apple Silicon, amd64 on Intel/AMD, etc.).

To exit at any time, press **Ctrl-D** at a prompt — the program will
terminate cleanly.

## Build locally with `just`

The repository's [`Justfile`](Justfile) wraps the `docker buildx`
commands needed for multi-arch image builds. Install
[`just`](https://github.com/casey/just) (e.g. `brew install just`) and
[Docker Desktop](https://www.docker.com/products/docker-desktop/) (or
any Docker engine with `buildx`).

| Command        | What it does                                                                                                                 |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `just`         | List all available recipes.                                                                                                  |
| `just setup`   | Create or reuse the `sst-builder` buildx builder.                                                                            |
| `just local`   | Build for your host architecture and load the image into your local Docker daemon as `oldmankris/sst:local`.                 |
| `just run`     | Build (host arch) and run interactively.                                                                                     |
| `just build`   | Build both `linux/amd64` and `linux/arm64` without pushing. Used for verification.                                           |
| `just push`    | Build both architectures and push the multi-arch manifest to `oldmankris/sst:latest` on Docker Hub. Requires `docker login`. |
| `just inspect` | Show the manifest list for the published image.                                                                              |
| `just clean`   | Remove the buildx builder.                                                                                                   |

## Image layout

| Path           | Purpose                                                                                                      |
| -------------- | ------------------------------------------------------------------------------------------------------------ |
| `/app/sst`     | The statically linked game binary.                                                                           |
| `/app/sst.doc` | In-game help text. Read by the `help` command at runtime.                                                    |
| `/app/LICENSE` | Combined license/notice file (game freeware grant + BSD-3 + CC0 dedication for the Dockerization additions). |

The `WORKDIR` is `/app`, so the game's relative `fopen("sst.doc", ...)`
lookup resolves correctly.

## Repository contents

| File            | Purpose                                                                                 |
| --------------- | --------------------------------------------------------------------------------------- |
| `*.c`, `*.h`    | Original game source.                                                                   |
| `makefile`      | Original build rules; invoked unchanged by the Dockerfile with `make CC="cc -static"`.  |
| `Dockerfile`    | Two-stage build (Alpine builder → `scratch` final).                                     |
| `.dockerignore` | Excludes the host-built `sst` binary, `.DS_Store`, `.git`, etc. from the build context. |
| `Justfile`      | Build/push driver commands listed above.                                                |
| `LICENSE`       | Author credits and licensing for all components.                                        |

## License

See [`LICENSE`](LICENSE) for the full text. In summary:

- The game itself is **non-commercial freeware** — distribute and modify
  freely for recreational use, but not for sale or profit.
- The `CAPTURE` command's code (in `battle.c`) is BSD-3-clause from
  NetBSD.
- The Dockerization additions (`Dockerfile`, `.dockerignore`, `Justfile`,
  `LICENSE`, and the `proutn`/`scan` source modifications) are
  dedicated to the public domain under
  [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) by
  Kristopher Johnson.
