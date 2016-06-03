$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'capybara'

require 'marty_rspec'

include MartyRSpec::Util
include MartyRSpec::NetzkeGrid
