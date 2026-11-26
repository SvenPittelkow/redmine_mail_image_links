# frozen_string_literal: true

# Inside Redmine (rails redmine:plugins:test) the Redmine test helper is used.
# With STANDALONE=1 the pure-Ruby filter tests run without Redmine:
#   STANDALONE=1 ruby -Itest test/unit/html_filter_test.rb
if ENV['STANDALONE']
  require 'minitest/autorun'
  require_relative '../lib/redmine_mail_image_links/html_filter'
  MailImageLinksTestCase = Minitest::Test
else
  require File.expand_path('../../../test/test_helper', __dir__)
  MailImageLinksTestCase = ActiveSupport::TestCase
end
