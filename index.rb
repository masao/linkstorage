#!/usr/bin/env ruby
# $Id$

require "cgi"
require "db"

module LinkStorage
   def to_xml( aid, set, delegate )
      set_xml = set.map do |e|
         "<e>#{ CGI.escapeHTML( e ) }</e>"
      end
      <<EOF
<?xml version="1.0"?><LinkStorage><set id="#{ CGI.escapeHTML( aid ) }">#{ set_xml }</set><delegate>#{ CGI.escapeHTML( delegate ) }</delegate></LinkStorage>
EOF
   end
end

begin
   @cgi = CGI.new
   namespace = @cgi.path_info
   db = LinkStorage::DB.new( namespace )
   case @cgi.request_method
   when "POST" # store/update
      set = @cgi.params[ "set" ]
      delegate = @cgi.params[ "delegate" ][0]
      aid, set, delegate = db.store( set, delegate )
      xml = LinkStorage.to_xml( aid, set, delegate )
   when "GET"  # query
   else
      raise "unknown operation"
   end
   print @cgi.header( 'status' => CGI::HTTP_STATUS['SERVER_ERROR'],
                      'type' => 'text/xml' )
   @cgi.print( xml )
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
