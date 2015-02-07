#!/bin/sh
bundle exec eye load processes.eye.rb -f &
tailf /app/jekbox.log
