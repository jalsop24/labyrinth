#! /bin/bash 
set -eo pipefail

echo "123" > build/version.txt

rojo build -o ./build/placefile.rbxl