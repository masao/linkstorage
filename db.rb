#!/usr/bin/env ruby
# $Id$

require 'ftools'
require 'sqlite3'

module LinkStorage
   class DB
      CREATE_TABLE = <<-EOF
		CREATE TABLE map( aid INTEGER, id );
		CREATE TABLE delegate( aid INTEGER PRIMARY KEY, id );
      EOF
      def initialize( ns )
         @namespace = ns
         case @namespace
         when /[\/\.]/, /[^\w]/
            raise DBError, "invalid namespace: #{ @namespace }"
         end
         if FileTest.exist? filename
            @dbh = SQLite3::Database.new( filename )
         else
            @dbh = SQLite3::Database.new( filename )
            @dbh.transaction do
               @dbh.execute_batch(CREATE_TABLE)
            end
         end
      end
      def filename
         "data/#{ @namespace }.db"
      end

      def store( set, delegate = nil )
         aid = nil
         #STDERR.puts [ set, delegate ].inspect
         delegate = set.first if delegate.nil?
         # FIXME: if set.nil? or set.empty?
         # FIXME: if set.inlude? delegate
         @dbh.transaction do
            aid = @dbh.get_first_value( "SELECT aid FROM map WHERE id = ?",
                                        set[0] )
            if aid.nil?
               aid = @dbh.get_first_value( "SELECT max(aid) FROM map" ).to_i
               aid += 1
            else
               @dbh.execute( "DELETE FROM map WHERE aid = ?", aid )
               @dbh.execute( "DELETE FROM delegate WHERE aid = ?", aid )
            end
            @dbh.execute( "INSERT INTO delegate VALUES(?, ?)", aid, delegate )
            sth = @dbh.prepare( "INSERT INTO map VALUES(?, ?)" )
            set.each do |e|
               sth.execute( aid, e )
            end
         end
         [ aid, set, delegate ]
      end
   end
   class DBError < Exception; end
end

if $0 == __FILE__
   db = LinkStorage::DB.new( "example" )
   p db
end
