require 'json'

# Shared Jekbox code
class Jekbox
  PROJECT_ROOT = File.expand_path File.join(File.dirname(__FILE__), '../')
  DROPBOX_PATH = "#{ENV['HOME']}/Dropbox"
  LOG_PATH = "#{PROJECT_ROOT}/jekbox.log"

  class << self
    def log(message)
      message.strip!
      p message unless message.empty?
    end

    def sh(command)
      log `#{command} 2>&1`
    end

    def all_dropbox_paths
      return [] unless File.exist? DROPBOX_PATH
      paths = Dir.entries(DROPBOX_PATH) - ['.', '..', '.dropbox', '.dropbox.cache']
      paths.map { |p| File.expand_path(File.join(DROPBOX_PATH, p)) }
    end

    def all_dropbox_folders
      all_dropbox_paths.select do |path|
        File.directory? path
      end
    end

    # Jekbox convention is that any folder that has a name that looks like a domain will be served
    # as a Jekyll site.
    def site_folders
      all_dropbox_folders.select do |path|
        # *sigh* a '.' is the only real indicator of a domain.
        # Unless we require that folder names have 'http://' in them?
        # TODO: perhaps look at the contents of the folder
        path.include? '.'
      end
    end

    # Sites without the path. So /home/user/Dropbox/www.example.com just becomes
    # www.example.com
    def site_names
      site_folders.map { |p| p.split('/').last }
    end

    # Monitor paths in the Dropbox folder and exclude all paths that don't contain
    # a Jekbox site.
    def selective_sync
      log 'Starting selective sync daemon...'
      loop do
        excludable = all_dropbox_paths - site_folders
        excludable.each do |path|
          log "Excluding #{path}"
          sh "dropbox.py exclude add '#{path.gsub("'", "\'")}'"
        end
        sleep 3
      end
    end

    def jekyll_servers
      log 'Starting Jekyll servers daemon...'
      loop do
        site_names.each do |site|
          port = sites_json.fetch(site, {}).fetch('port', 0).to_i
          boot_site(site) unless port > 0
        end
        sleep 10
      end
    end

    # Start a site using the Jekyll gem
    def boot_site(site)
      log "Attempting to launch #{site}"
      sites = sites_json
      sites[site] = {}
      sites[site]['port'] = 'LAUNCHME'
      save_sites_json sites
      sh "bundle exec eye load #{PROJECT_ROOT}/lib/server.eye.rb"
    end

    # sites.json keeps track of the booted sites and the ports they are being served on
    def sites_json
      path = "#{PROJECT_ROOT}/sites.json"
      return {} unless File.exist? path
      JSON.parse File.read path
    end

    # Save changes to sites.json back to disk
    def save_sites_json(json)
      File.open("#{PROJECT_ROOT}/sites.json", 'w') do |f|
        f.write(json.to_json)
      end
    end

    # Given a web request from the proxy server, determine the site to serve
    def find_destination(request)
      sites = sites_json
      hosts = sites.keys
      return false unless hosts.include? request.host
      site = sites[request.host]
      forwarding_address = "http://localhost:#{site['port']}#{request.path}"
      puts "Proxying request to: #{forwarding_address}"
      URI.parse forwarding_address
    end
  end
end
