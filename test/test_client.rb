#!/usr/bin/env ruby
# $Id$

require "test/unit"
require "ftools"

require "client.rb"

class TC_CLIENT < Test::Unit::TestCase
   def test_initialize
      client = LinkStorage::Client.new( "http://localhost/~masao/private/cvswork/linkstorage/api.cgi/example" )
      assert( client )
   end
end
