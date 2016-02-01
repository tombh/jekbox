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
    context 'Finding the index.html file when a URL without a file is requested' do
      it 'should use index.html when root is requested' do
        get 'http://jekbox.example.com'
        expect(last_response.body).to eq "The index page\n"
      end

      it 'should use index.html when a / is present' do
        get 'http://jekbox.example.com/deep/'
        expect(last_response.body).to eq "Deep page\n"
      end

      it 'should use index.html when a / is not present' do
        get 'http://jekbox.example.com/deep'
        expect(last_response.body).to eq "Deep page\n"
      end
    end

    it 'should find a normal file' do
      get 'http://jekbox.example.com/assets/foo.css'
      expect(last_response.body).to eq "body {}\n"
    end

    it 'should find a normal file' do
      expect do
        get 'http://jekbox.example.com/../../../spec_helper.rb'
      end.to raise_error RuntimeError
    end
  end
end
