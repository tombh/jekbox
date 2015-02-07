require_relative 'lib/jekbox.rb'

puts "Logging to: #{Jekbox::LOG_PATH}"

Eye.config do
  logger Jekbox::LOG_PATH
end

Eye.application 'Jekbox' do
  working_dir Jekbox::PROJECT_ROOT
  stdall Jekbox::LOG_PATH

  # Dropbox daemon
  process :dropbox do
    pid_file 'dropbox.pid'
    daemonize true
    start_command '/usr/local/.dropbox-dist/dropboxd'
  end

  # Only sync folders that contain websites
  process :selective_sync do
    pid_file 'selective_sync.pid'
    daemonize true
    start_command 'ruby -r ./lib/jekbox.rb -e Jekbox.selective_sync'
  end

  # Start, monitor and stop Jekyll servers
  process :jekyll_servers do
    pid_file 'jekyll_servers.pid'
    daemonize true
    start_command 'ruby -r ./lib/jekbox.rb -e Jekbox.jekyll_servers'
  end

  # The proxy server forwards requests to the appropriate Jekyll server instance
  process :reverse_proxy do
    pid_file 'thin.pid'
    start_command 'bundle exec thin start -R config.ru -p 80 -d -l jekbox.log -P thin.pid'
  end
end
