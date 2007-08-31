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
         case @cgi.request_method
         when "POST" # store/update
            set = @cgi.params[ "set" ]
            delegate = @cgi.params[ "delegate" ][0]
            #STDERR.puts [ set, delegate ].inspect
            aid, set, delegate = @db.store( set, delegate )
            xml = to_xml( aid, set, delegate )
         when "GET"  # query
         else
            raise "unknown operation"
         end
         raise APIError, "unknown error while API processing." if xml.nil?
         print @cgi.header( 'status' => CGI::HTTP_STATUS['SERVER_ERROR'],
                            'type' => 'text/xml' )
         @cgi.print( xml )
      end
      def to_xml( aid, set, delegate )
         set_xml = set.map do |e|
            "<e>#{ CGI.escapeHTML( e ) }</e>"
         end.join
         <<EOF
<?xml version="1.0"?><LinkStorage><set id="#{ aid }">#{ set_xml }</set><delegate>#{ CGI.escapeHTML( delegate ) }</delegate></LinkStorage>
EOF
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
      print "Content-Type: text/html\n\n"
   end
   puts "<h1>500 Internal Server Error</h1>"
   puts "<pre>"
   puts CGI::escapeHTML( "#{$!} (#{$!.class})" )
   puts ""
   puts CGI::escapeHTML( $@.join( "\n" ) )
   puts "</pre>"
end
