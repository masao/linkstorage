#!/usr/bin/env ruby
# $Id$

require "rexml/document"
require "net/http"
Net::HTTP.version_1_2

require "data.rb"

module LinkStorage
   class Client
      def initialize( baseurl, user = nil, password = nil )
         @http = HTTPConnection.new( baseurl, user, password )
      end
      def save( set, delegate = nil )
         delegate = set[0] if delegate.nil?
         data = [ set.map{|e| "set=#{e}" },
                  "delegate=#{delegate}" ].flatten.join("&")
         @http.request( :post, data )
      end
      def query( query )
         @http.request( :get, "query=#{query}" )
      end
      def delete( set )
         data = set.map{|e| "set=#{e}" }.join("&")
         @http.request( :delete, data )
      end

      class HTTPConnection
         def initialize( baseurl, user = nil, password = nil )
            @uri = URI.parse( baseurl )
            @http = Net::HTTP.new( @uri.host, @uri.port )
            @user, @password = user, password
         end
         def request( method, data = nil )
            response = nil
            if not @user.nil? and not @password.nil?
               auth = [ "#{@user}:#{@password}" ].pack('m').gsub(/\n/, '')
               header = { "Authorization" => "Basic " + auth }
            end
            case method
            when :post
               response = @http.post( @uri.path, data, header )
            when :get
               response = @http.get( @uri.path + "?" + data, header )
            when :delete
               response = @http.delete( @uri.path + "?" + data, header )
            else
               raise "unknown request method"
            end
            unless response.code == "200"
               raise "error occured: #{response.code}: #{response.body}"
            end
            Data.load_xml( response.body )
         end
      end
   end
end
