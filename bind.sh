#!/bin/sh

bind -x '"\C-x\C-f": "cd $(./vertnav); kill -INT $$"'
