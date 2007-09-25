#!/usr/bin/env ruby
# $Id$

require "test/unit"
require "ftools"
require "pathname"

require "client.rb"

PASSWD_FILE = Pathname.new(__FILE__).dirname.join(".localhost.passwd")
USER, PASSWD = open(PASSWD_FILE).read.chomp.split(/:/)

class TC_CLIENT < Test::Unit::TestCase
   def setup
      File.rm_f "data/example.db"
   end
   
   def test_initialize
      client = LinkStorage::Client.new( "http://localhost/~masao/private/cvswork/linkstorage/api.cgi/example" )
      assert( client )
   end

   def test_store
      client = LinkStorage::Client.new( "http://localhost/~masao/private/cvswork/linkstorage/api.cgi/example", USER, PASSWD )
      set = [ 1, 2, 3 ]
      data = nil
      assert_nothing_raised("save") do 
         data = client.save( set )
      end
      assert_equal( [ "1", "2", "3" ], data.set )
      assert_equal( "1", data.delegate )

      set << 4
      assert_nothing_raised("save2") do 
         data = client.save( set )
      end
      assert_equal( [ "1", "2", "3", "4" ], data.set )
      assert_equal( "1", data.delegate )

      assert_nothing_raised("delegate change") do 
         data = client.save( set, "2" )
      end
      assert_equal( [ "1", "2", "3", "4" ], data.set )
      assert_equal( "2", data.delegate )
   end

   def test_query
      client = LinkStorage::Client.new( "http://localhost/~masao/private/cvswork/linkstorage/api.cgi/example", USER, PASSWD )
      set = [ "1", "2", "3" ]
      data = client.query( 1 )
      assert_nil( data )
      client.save( set )
      data = client.query( "1" )
      assert_equal( data.set, set )
   end

   def test_delete
      client = LinkStorage::Client.new( "http://localhost/~masao/private/cvswork/linkstorage/api.cgi/example", USER, PASSWD )
      set = [ "1", "2", "3" ]
      client.save( set )
      client.delete( set )
      assert_nil( client.query( set[0] ) )
   end
end
