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
      expect(last_response.header['Location']).to eq 'www.example1.com'
    end

    it 'should redirect www to apex when apex is the defined domain' do
      get 'http://www.example2.com'
      expect(last_response.status).to eq 301
      expect(last_response.header['Location']).to eq 'example2.com'
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

    it 'should find a normal file' do
      get 'http://www.example1.com/assets/foo.css'
      expect(last_response.body).to eq "body {}\n"
    end

    it 'should find a normal file' do
      expect do
        get 'http://www.example1.com/../../../spec_helper.rb'
      end.to raise_error RuntimeError
    end
  end
end
