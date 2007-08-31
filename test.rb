#!/usr/bin/env ruby
# $Id$

require "test/unit"
require "ftools"
require "db.rb"

class TC_DB < Test::Unit::TestCase
   def setup
      File.rm_f( "data/example.db" )
   end
   
   def test_initialize
      assert( LinkStorage::DB.new( "example" ), "first db" )
      db = LinkStorage::DB.new( "example" )
      if File.exist? db.filename
         File.rm_f( db.filename )
         assert( LinkStorage::DB.new( "example" ), "after remove old db" )
      end
      [ "example//", "../example", "\0example" ].each do |ns|
         assert_raise( LinkStorage::DBError, ns ) do
            LinkStorage::DB.new( ns )
         end
      end
   end

   def test_store
      db = LinkStorage::DB.new( "example" )
      data = [ 1, 2, 3 ]
      assert( db.store( data ) )

      data << 4
      assert( db.store( data ) )

      data << 5
      assert( db.store( data, data[2] ) )
      #p db.store( data, data[2] )
   end
end
