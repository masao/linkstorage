#!/usr/bin/env ruby
# $Id$

require "cgi"

module LinkStorage
   class Data
      attr_reader :aid, :set, :delegate
      def initialize( aid, set, delegate )
         @aid, @set, @delegate = aid, set, delegate
      end
      def self.load_xml( xml )
         doc = REXML::Document.new( xml )
         if doc.root.elements.empty?
            nil
         else
            aid = doc.root.elements[1].attributes["id"] 
            set = doc.elements.to_a( "/LinkStorage/set/e" ).map do |e|
               e.text
            end
            delegate = doc.get_elements( "/LinkStorage/delegate" )[0].text
            self.new( aid, set, delegate )
         end
      end
      def to_xml
         set_xml = @set.map do |e|
            "<e>#{ CGI.escapeHTML( e ) }</e>"
         end.join
         <<EOF
<?xml version="1.0"?><LinkStorage><set id="#{ @aid }">#{ set_xml }</set><delegate>#{ CGI.escapeHTML( @delegate ) }</delegate></LinkStorage>
EOF
      end
   end
end
