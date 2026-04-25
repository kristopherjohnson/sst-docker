# syntax=docker/dockerfile:1.7
FROM alpine:3.20 AS builder
RUN apk add --no-cache build-base
WORKDIR /src
COPY . .
RUN make -f makefile CC="cc -static" && strip sst

FROM scratch
WORKDIR /app
COPY --from=builder /src/sst     /app/sst
COPY --from=builder /src/sst.doc /app/sst.doc
COPY --from=builder /src/LICENSE /app/LICENSE
ENTRYPOINT ["/app/sst"]
