#!/bin/bash

echo "Installing 32-bit dependencies..."
yum install -y glibc.i686 glibc-devel.i686 libstdc++.i686 zlib.i686

echo "Done! Dependencies installed."
