$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../')

require 'lib/server'

RSpec.configure do |c|
  c.mock_with :rspec
  c.expect_with :rspec
  c.color = true

  c.before(:each) do
    stub_const('Jekbox::DROPBOX_PATH', File.join(Jekbox::PROJECT_ROOT, 'spec/fixtures'))
  end
end
