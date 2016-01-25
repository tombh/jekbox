# Startup a Jekyll site managed by eye.
# Called by Jekbox.boot_site
require_relative 'jekbox.rb'

Eye.config do
  logger Jekbox::LOG_PATH
end

sites = Jekbox.sites_json

launchable = sites.select { |_k, v| v['port'] == 'LAUNCHME' }
site = launchable.first.first

fail 'No launchable site' unless site

# Simple convention of incrementing the port number for each new site
port = 4000 + sites.keys.length

Eye.application 'Jekbox' do
  working_dir "#{Jekbox::DROPBOX_PATH}/#{site}"
  stdall Jekbox::LOG_PATH

  group 'Servers' do
    process "jekbox-server-#{site}" do
      pid_file "#{site}.pid"
      daemonize true

      start_command "bundle exec jekyll server --port #{port} --trace"

      trigger :transition1, to: :starting, do: (lambda do
        sites[site]['port'] = port
        Jekbox.save_sites_json(sites)
      end)

      trigger :transition2, to: :down, do: (lambda do
        sites.delete site
        Jekbox.save_sites_json(sites)
      end)
    end
  end
end
