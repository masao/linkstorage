#!/usr/bin/env ruby
# $Id$

require "test/unit"
require "ftools"

require "db.rb"
require "client.rb"

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
      assert( result = db.store( data ) )
      assert_equal( [1, 2, 3], result.set )

      data << 4
      result = db.store( data )
      assert_equal( [1, 2, 3, 4], result.set )

      data << 5
      result = db.store( data )
      assert_equal( [1, 2, 3, 4, 5], result.set )
      assert_equal( 1, result.delegate )

      data = [ "6" ]
      assert_nothing_raised do
         result = db.store( data )
      end
      assert_equal( [ "6" ], result.set )
      assert_equal( "6", result.delegate )

      data = [ "1", "6" ]
      result = db.store( data )
      assert_equal( [ "1", "6" ], result.set )
      result = db.query( "6" )
      assert_equal( [ "1", "6" ], result.set )
      result = db.query( "1" )
      assert_equal( [ "1", "6" ], result.set )
   end

   def test_query
      db = LinkStorage::DB.new( "example" )
      assert_nil( db.query( 1 ) )

      data = [ 1, 2, 3 ]
      db.store( data )
      data = db.query( 1 )
      #p data
      assert_equal( "1", data.aid )
      assert_equal( %w[ 1 2 3 ], data.set )
      assert_equal( "1", data.delegate )
   end

   def test_delete
      db = LinkStorage::DB.new( "example" )
      data = [ "1", "2", "3" ]
      db.store( data )
      assert_raise(LinkStorage::DBError){  db.delete( "1" )  }
      db.delete( data )
      assert_nil( db.query( data[0] ) )
   end
end
