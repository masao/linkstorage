#!/usr/bin/env ruby
# $Id$

require "cgi"
require "db"

module LinkStorage
   class API
      def initialize( cgi )
         @cgi = cgi
         @namespace = @cgi.path_info
         raise APIError, "empty namespace" if @namespace.nil?
         @namespace = @namespace[1..-1] if @namespace[0] == ?/
         @db = LinkStorage::DB.new( @namespace )
      end
      def process
         data = nil
         case @cgi.request_method
         when "POST" # store/update
            set = @cgi.params[ "set" ]
            delegate = @cgi.params[ "delegate" ][0]
            #STDERR.puts [ set, delegate ].inspect
            data = @db.store( set, delegate )
         when "GET"  # query
            query = @cgi.params[ "query" ][0]
            data = @db.query( query )
         when "DELETE"	# delete
            #STDERR.puts ENV.inspect
            @cgi.params = CGI::parse( ENV["QUERY_STRING"] )
            set = @cgi.params[ "set" ]
            #STDERR.puts "**"+set.inspect
            data = @db.delete( set )
         else
            raise "unknown operation"
         end
         if data.nil?
            xml = %q[<?xml version="1.0"?><LinkStorage/>]
         else
            xml = data.to_xml
         end
         raise APIError, "unknown error while API processing." if xml.nil?
         print @cgi.header( 'status' => CGI::HTTP_STATUS['OK'],
                            'type' => 'text/xml' )
         @cgi.print( xml )
      end
   end
   class APIError < Exception; end
end

begin
   @cgi = CGI.new
   app = LinkStorage::API.new( @cgi )
   app.process
rescue Exception
   if @cgi
      print @cgi.header( 'status' => CGI::HTTP_STATUS['SERVER_ERROR'],
                         'type' => 'text/html' )
   else
      print "Status: 500 Internal Server Error\n"
      print "Content-Type: text/xml\n\n"
   end
   puts %Q[<?xml version="1.0"?><LinkStorage><error>#{CGI::escapeHTML( "#{$!} (#{$!.class})" )}\n#{CGI::escapeHTML( $@.join( "\n" ) )}</error></LinkStorage>]
end
