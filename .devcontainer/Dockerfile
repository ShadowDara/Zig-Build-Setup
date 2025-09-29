# .devcontainer/Dockerfile
FROM ubuntu:22.04

# Install Zig and build tools
RUN apt-get update && apt-get install -y \
    curl build-essential git pkg-config \
 && curl -L https://ziglang.org/download/0.12.0/zig-linux-x86_64-0.12.0.tar.xz | tar -xJ \
 && mv zig-linux-x86_64-0.12.0 /opt/zig \
 && ln -s /opt/zig/zig /usr/local/bin/zig
