#!/bin/bash

[ ! -d "stable-diffusion-ui" ] && wget https://github.com/cmdr2/stable-diffusion-ui/releases/download/v2.05/stable-diffusion-ui-linux.tar.xz && tar xf stable-diffusion-ui-linux.tar.xz

cd stable-diffusion-ui

until sh -c ./start.sh
do
  echo "!!!!!!!!!!! Failed. Will retry !!!!!!!!!!!!!!!!!!! "
done


