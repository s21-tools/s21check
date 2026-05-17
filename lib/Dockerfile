FROM debian:stable

RUN apt update && apt install -y \
    build-essential \
    valgrind \
    lcov \
    gcovr \
    check \
    pkg-config \
    wget \
    ca-certificates \
    gdb

# Debug symbols for glibc
RUN apt update && apt install -y libc6-dbg

WORKDIR /app