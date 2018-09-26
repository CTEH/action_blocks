# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/north_winds/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/north_winds/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
# Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# https://stackoverflow.com/questions/6908708/how-to-show-longer-traces-in-rails-testcases
Rails.backtrace_cleaner.remove_silencers!


# # Load fixtures from the engine
# if ActiveSupport::TestCase.respond_to?(:fixture_path=)
#   ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
#   ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
#   ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
#   ActiveSupport::TestCase.fixtures :all
# end

FactoryBot.definition_file_paths << File.expand_path('north_winds/factories', __FILE__)


require 'minitest/ci'
require 'minitest/reporters'
class SpecReporter < MiniTest::Reporters::SpecReporter

  def record_print_status(test)
    test_name = test.name.gsub(/^test_: /, 'test:')
    print pad_test(test_name)
    print_colored_status(test)
    print(" (%.8fs)" % test.time) unless test.time.nil?
    puts
  end

end

Minitest::Reporters.use! [SpecReporter.new()]

def debug(msg)
  puts '-'*80
  puts caller[0].split('/').last
  puts ''
  if msg.class == String
    puts msg
  end
  if msg.class == Array || msg.class == Hash
    pp msg
  end
  if msg.class != String && msg.class != Array && msg.class != Hash
    puts msg.inspect
  end
  puts '-'*80
  puts ''
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  attr_accessor :token, :auth_headers

  def sign_in(user)
    post user_session_path \
      'user[email]'    => user.email,
      'user[password]' => user.password

    @token =  response.headers["Authorization"]
    @auth_headers = {'Authorization'=>@token}

  end

end
