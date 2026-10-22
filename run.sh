#!/bin/bash
tmux new-session -d -s build "bash /home/deployer/build.sh > /home/deployer/build.log 2>&1"
