#!/usr/bin/env ruby
# $Id$

require "test/unit"
require "ftools"

require "client.rb"

user, passwd = open(".localhost.passwd").read.chomp.split(/:/)

class TC_CLIENT < Test::Unit::TestCase
   def setup
      File.rm_f "data/example.db"
   end
   
   def test_initialize
      client = LinkStorage::Client.new( "http://localhost/~masao/private/cvswork/linkstorage/api.cgi/example" )
      assert( client )
   end
   def test_store
      client = LinkStorage::Client.new( "http://localhost/~masao/private/cvswork/linkstorage/api.cgi/example", user, passwd )
      set = [ 1, 2, 3 ]
      response = client.save( set )
      puts response.body
      assert_equal( "200", response.code, "HTTP status code" )
   end
end
