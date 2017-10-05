#!/bin/bash

DIR=$(cd `dirname ${BASH_SOURCE[0]}` && pwd)

output="/tmp/game.zip"

cd $DIR/..
zip -r $output *

open -a love $output
