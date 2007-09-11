#!/usr/bin/env ruby
# $Id$

require "rexml/document"
require "net/http"
Net::HTTP.version_1_2

require "data.rb"

module LinkStorage
   class Client
      def initialize( baseurl, user = nil, password = nil )
         @baseurl = baseurl
         @uri = URI.parse( @baseurl )
         @user, @password = user, password
      end
      def save( set, delegate = nil )
         delegate = set[0] if delegate.nil?
         data = [ set.map{|e| "set=#{e}" },
                  "delegate=#{delegate}" ].flatten.join("&")
         http = Net::HTTP.new( @uri.host, @uri.port )
         if not @user.nil? and not @password.nil?
            auth = [ "#{@user}:#{@password}" ].pack('m').gsub(/\n/, '')
            header = { "Authorization" => "Basic " + auth }
         end
         response = http.post( @uri.path, data, header )
         #p response.body
         unless response.code == "200"
            raise "error"
         end
         Data.load_xml( response.body )
      end
   end
end
