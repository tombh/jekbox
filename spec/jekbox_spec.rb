require 'spec_helper'

describe Jekbox do
  it 'should compile config for all sites' do
    example = Jekbox.all_config['www.example1.com']
    expect(example['location']).to eq File.join Jekbox::DROPBOX_PATH, 'example_site_1'
  end
end
