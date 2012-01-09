require_relative 'vortex_utils/string_extensions'

# Utilites used to access the Vortex CMS from the WebDAV protocol and do common tasks

require 'net/dav'
require 'uri'
require 'highline/import'
require 'time'
require 'json'

module Net

  class DAV

    def initialize(uri, *args)
      @uri = uri
      @uri = URI.parse(@uri) if @uri.is_a? String
      @have_curl = false # This defaults to true in Net::DAV
      @handler = NetHttpHandler.new(@uri)
      @handler.verify_server = false # This defaults to true in Net::DAV
      if(args != [])
        if(args[0][:use_osx_keychain] or args[0][:osx_keychain])then

          # Retrieve password from OS X KeyChain.
          osx =  (RUBY_PLATFORM =~ /darwin/)
          if(osx)then
            require 'osx_keychain'
            keychain = OSXKeychain.new
            user = ENV['USER']

            if(args[0][:prompt_for_password])
              response = `security delete-generic-password -s #{@uri.host}`
              require 'pry'
              binding.pry
            end

            pass = keychain[@uri.host, user ]

            if(pass == nil) then
              puts "Password not found on OS X KeyChain. "
              puts "Enter password to store new password on OS X KeyChain."
              ## @handler.user = ask("Username: ") {|q| q.echo = true}
              ## Todo: store username in a config file so we can have
              ## different username locally and on server
              pass = ask("Password: ") {|q| q.echo = "*"} # false => no echo
              keychain[@uri.host, user] = pass
              puts "Password for '#{user}' on '#{@uri.host}' stored on OS X KeyChain."
              @handler.user = user
              @handler.pass = pass
            else
              @handler.user = user
              @handler.pass = pass
            end
            return @handler

          else
            puts "Warning: Not running on OS X."
          end

        end
        @handler.user = args[0]
        @handler.pass = args[1]
      else
        @handler.user = ask("Username: ") {|q| q.echo = true}
        @handler.pass = ask("Password: ") {|q| q.echo = "*"} # false => no echo
      end
      return @handler
    end

    # Set the publish date to current timestamp
    def vortex_publish!(uri)
      proppatch(uri, '<v:publish-date xmlns:v="vrtx">' + Time.now.httpdate.to_s + '</v:publish-date>')
    end

    def vortex_publish(uri,time)
      proppatch(uri, '<v:publish-date xmlns:v="vrtx">' + time.httpdate.to_s + '</v:publish-date>')
    end

    def vortex_unpublish!(uri)
      proppatch(uri, '<v:unpublish-date xmlns:v="vrtx">' +Time.now.httpdate.to_s + '</v:unpublish-date>')
    end

    def vortex_unpublish(uri, time)
      proppatch(uri, '<v:unpublish-date xmlns:v="vrtx">' + time.httpdate.to_s + '</v:unpublish-date>')
    end

    # Create path - create all folders in the given path if they do not exist.
    #
    # Default is article-listing folder and the foldername used as title.
    #
    # Example:
    #
    #   create_path('/folders/to/be/created/')
    #   create_path('/folders/to/be/created/', :type => "event-listing", :title => "Testing")
    def create_path(dest_path, *args)
      title = nil
      if(args.size > 0)then
        type = args[0][:type]
        title = args[0][:title]
      end
      if(not(type))then
        type = "article-listing"
      end

      destination_path = "/"
      dest_path.split("/").each do |folder|
        if(folder != "")then
          folder = folder.downcase
          destination_path = destination_path + folder + "/"
          if( not(exists?(destination_path)) )then
            mkdir(destination_path)
            proppatch(destination_path,'<v:collection-type xmlns:v="vrtx">' + type + '</v:collection-type>')
            if(title)then
              proppatch(destination_path,'<v:userTitle xmlns:v="vrtx">' + title.to_s +  '</v:userTitle>')
            end
          end
        end
      end
      return destination_path
    end

    def set_vortex_collection_title(uri, title)
      proppatch(uri,'<v:userTitle xmlns:v="vrtx">' + title.to_s +  '</v:userTitle>')
    end

    def set_vortex_collection_type(uri, type)
      proppatch(uri,'<v:collection-type xmlns:v="vrtx">' + type + '</v:collection-type>')
    end

    def hide_vortex_collection(uri)
      proppatch(uri, '<hidden xmlns="http://www.uio.no/navigation">true</hidden>')
    end

  end


end

