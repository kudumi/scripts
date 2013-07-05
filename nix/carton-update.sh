#!/bin/bash

pushd $HOME/.emacs.d > /dev/null

carton install
carton update
