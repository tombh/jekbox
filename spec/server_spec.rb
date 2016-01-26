require 'spec_helper'
require 'rack/test'

describe Server do
  include Rack::Test::Methods
  def app
    Server.new
  end
  before :each do
    stub_const('Jekbox::DROPBOX_PATH', File.join(Jekbox::PROJECT_ROOT, 'spec/fixtures'))
  end

  describe 'Find paths' do
    it 'should find the index.html file when a URL without a file is requested' do
      get 'http://jekbox.example.com'
      expect(last_response.body).to eq "The index page\n"
    end

    it 'should find a normal file' do
      get 'http://jekbox.example.com/foo.css'
      expect(last_response.body).to eq "body {}\n"
    end
  end
end
