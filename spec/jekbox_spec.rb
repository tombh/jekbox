require 'spec_helper'
require 'lib/builder'
require 'fileutils'

describe Jekbox do
  it 'should compile config for all sites' do
    example = Jekbox.all_config['www.example1.com']
    expect(example['location']).to eq File.join Jekbox::DROPBOX_PATH, 'example_site_1'
  end
end

describe Builder do
  let(:site) { File.join Jekbox::DROPBOX_PATH, 'example_site_unbuilt' }
  let(:new_file) { File.join site, 'new.md' }
  let(:built_file) { File.join site, '_site', 'new.md' } # TODO: test actual md to html conversion
  let(:build_log) { File.join site, '_latest_build.txt' }

  before do
    File.delete new_file if File.exist? new_file
  end

  after do
    File.delete new_file if File.exist? new_file
    File.delete built_file if File.exist? built_file
    File.delete build_log if File.exist? build_log
  end
  it 'should try building a site when a file changes' do
    expect(File.exist?(built_file)).to be false
    Builder.run
    File.open(new_file, 'w') { |f| f.write('new content') }
    sleep 1
    expect(File.exist?(built_file)).to be true
    log = File.read build_log
    expect(log).to match(/Generating.../)
  end
end
