image     := "oldmankris/sst"
tag       := "latest"
platforms := "linux/amd64,linux/arm64"
builder   := "sst-builder"

default:
    @just --list

# Create (or reuse) a buildx builder that supports multi-arch
setup:
    docker buildx inspect {{builder}} >/dev/null 2>&1 \
      || docker buildx create --name {{builder}} --driver docker-container --bootstrap
    docker buildx use {{builder}}

# Build for both arches without pushing (verifies the build works)
build: setup
    docker buildx build --platform {{platforms}} -t {{image}}:{{tag}} .

# Build and push the multi-arch manifest to Docker Hub
push: setup
    docker buildx build --platform {{platforms}} -t {{image}}:{{tag}} --push .

# Build for the host arch only and load into the local Docker daemon
local: setup
    docker buildx build --load -t {{image}}:local .

# Smoke-test the local-arch image
run: local
    docker run --rm -it {{image}}:local

# Show final multi-arch manifest for the pushed image
inspect:
    docker buildx imagetools inspect {{image}}:{{tag}}

# Remove the buildx builder
clean:
    -docker buildx rm {{builder}}
