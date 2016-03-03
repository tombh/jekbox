require 'spec_helper'
require 'rack/test'

describe Server do
  include Rack::Test::Methods
  def app
    Server.new
  end

  describe 'Handling domains' do
    it 'should redirect apex to www when www is the defined domain' do
      get 'http://example1.com'
      expect(last_response.status).to eq 301
      expect(last_response.header['Location']).to eq 'http://www.example1.com'
    end

    it 'should redirect www to apex when apex is the defined domain' do
      get 'http://www.example2.com'
      expect(last_response.status).to eq 301
      expect(last_response.header['Location']).to eq 'http://example2.com'
    end
  end

  describe 'Handling headers' do
    it 'should return 304 for unchanged files' do
      file = File.join Jekbox::DROPBOX_PATH, 'example_site_1/_site/index.html'
      time = FileHandler.file_info(file)[:time]
      header 'IF_MODIFIED_SINCE', time
      get 'http://www.example1.com'
      expect(last_response.status).to eq 304
      expect(last_response.header['Last-Modified']).to eq time
    end
  end

  describe 'Find paths' do
    context 'Finding the index.html file when a URL without a file is requested' do
      it 'should use index.html when root is requested' do
        get 'http://www.example1.com'
        expect(last_response.body).to eq "The index page\n"
      end

      it 'should use index.html when a / is present' do
        get 'http://www.example1.com/deep/'
        expect(last_response.body).to eq "Deep page\n"
      end

      it 'should use index.html when a / is not present' do
        get 'http://www.example1.com/deep'
        expect(last_response.body).to eq "Deep page\n"
      end
    end

    it 'should find an html file even without the .html extension' do
      get 'http://www.example1.com/permalink'
      expect(last_response.body).to eq "permalink content\n"
    end

    it 'should find a normal file' do
      get 'http://www.example1.com/assets/foo.css'
      expect(last_response.body).to eq "body {}\n"
    end

    it 'should prevent access to files not in the site folder' do
      expect do
        get 'http://www.example1.com/../../../spec_helper.rb'
      end.to raise_error RuntimeError
    end
  end
end
