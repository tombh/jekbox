#!/bin/sh
bundle exec eye load processes.eye.rb -f &
touch /app/jekbox.log
tailf /app/jekbox.log
