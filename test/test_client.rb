#!/usr/bin/env ruby
# $Id$

require "test/unit"
require "ftools"

require "client.rb"

class TC_CLIENT < Test::Unit::TestCase
   def test_initialize
      assert( LinkStorage::Client.new( "http://localhost/~masao/private/cvswork/linkstorage/api.cgi/example" ) )
   end
end
