require 'rubygems'
require 'rack'

require 'lib/raccept'

use Raccept
run lambda {|env| [200,{"Content-Type" => "text/plain"}, {:this => 'is a Hash'} ] }