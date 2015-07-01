# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Initiate paperclip
Paperclip.options[:command_path] = "/usr/bin/convert"