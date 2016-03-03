require 'json'
require 'yaml'

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
      paths = Dir.entries(DROPBOX_PATH) - [
        '.',
        '..',
        '.dropbox',
        '.dropbox.cache'
      ]
      paths.map { |p| File.expand_path(File.join(DROPBOX_PATH, p)) }
    end

    def all_dropbox_folders
      all_dropbox_paths.select do |path|
        File.directory? path
      end
    end

    # Jekbox convention is that any folder that has a `_jekbox.yml` file is
    # condsidered a Jekbox site
    def site_folders
      all_dropbox_folders.select do |path|
        File.exist? File.join path, '_jekbox.yml'
      end
    end

    # Hash of all the _jekbox.yml config, indexed by domain name
    def all_config
      hash = {}
      site_folders.each do |folder|
        config = YAML.load File.read File.join folder, '_jekbox.yml'
        hash[config['domain']] = config
        hash[config['domain']]['location'] = folder
      end
      hash
    end

    # Monitor paths in the Dropbox folder and exclude all paths that don't
    # contain a Jekbox site.
    # Called from processes.eye
    def selective_sync
      log 'Starting selective sync daemon...'
      loop do
        excludable = all_dropbox_paths - site_folders
        excludable.each do |path|
          log "Excluding #{path}"
          sh "dropbox.py exclude add '#{path.tr("'", "\'")}'"
        end
        sleep 3
      end
    end
  end
end
