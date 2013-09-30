#!/usr/bin/env bash

pushd $HOME/.emacs.d > /dev/null

cask install
cask update
