require 'listen'
require 'listen/version'
require_relative 'jekbox.rb'

# Watch for changes to files and rebuild the jekyll site
class Builder
  class << self
    def run
      # TODO: watch for new folders
      Jekbox.all_dropbox_folders.each do |folder|
        watch folder
      end
    end

    def watch(folder)
      build_log = File.join folder, '_latest_build.txt'
      Listen.to(folder, ignore: %r{_site\/|latest_build}) do |_modified, _added, _removed|
        `cd #{folder} && jekyll build &>> #{build_log}`
      end.start
    end
  end
end
