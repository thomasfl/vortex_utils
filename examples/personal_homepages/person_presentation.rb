# -*- coding: utf-8 -*-
require 'rubygems'
require 'vortex_client'
require 'uri'
require 'nokogiri'
require 'pry'
require './ldap_util'
require 'json'
require 'iconv'
require 'pp'
require 'cgi'
require 'pathname'

# PersonPresentation - Query and update information about user presentations stored in Vortex CMS.
#
# Author: thomas.flemming(@)usit.uio.no 2011
#
# Usage:
#
#    person = PersonPresentation(vortex_connection, dav_url)
#    puts person.realname
# æøå
class PersonPresentation

  attr_accessor :path, :url, :path, :folder_path, :vortex

  def initialize(vortex, url)
    @vortex = vortex
    @url = url
    uri = URI.parse(@url)
    @path = uri.path
    @folder_path = @path.sub(/[^\/]*$/,'')
  end

  def is_published?
    if(@vortex.exists?(@path))
      begin
        props = @vortex.propfind(@path)
      rescue
        return false
      end
      if(props.xpath("//v:published", "v" => "vrtx").first)
        return props.xpath("//v:published", "v" => "vrtx").first.text == "true"
      end
    end
    return false
  end

  # Returns true if the folder where the presentation file is placed is hidden from navigation
  def folder_is_hidden?
    folder_url =  @url.sub(/[^\/]*$/,'')
    props = @vortex.propfind(@folder_path)
    response = props.xpath('//d:href[text()="' + folder_url + '"]/..','d'=>'DAV:')
    value = response.xpath("//a:hidden","a" => "http://www.uio.no/navigation").last
    return (not(value == nil or value.text == "false"))
  end

  # Hides folder where presentation file is placed from navigation
  def hide_folder
    begin
      @vortex.proppatch(@folder_path,'<hidden xmlns="http://www.uio.no/navigation">true</hidden>')
    rescue
      return false
    end
    return true
  end

  # Returns title displayed in navigation
  def folder_title
    props = @vortex.propfind(@folder_path)
    return props.xpath("//v:collectionTitle", "v" => "vrtx").last.text
  end

  # Users username
  def username
    begin
      userdata = JSON.parse(@vortex.get(@path))
      username = userdata['properties']['username']
      # username = Iconv.iconv('ascii//ignore//translit', 'utf-8', username).to_s
    rescue
      username = nil
    end
  end

  # Look up users realname from ldap directory
  def realname
    if(username())
      begin
        realname = ldap_realname(username())
        ## realname = Iconv.iconv('ascii//ignore//translit', 'utf-8', realname).first.gsub('["','').gsub('"]','')
        # if(realname[/Jakob/])
        #  binding.pry
        # end
      rescue
        realname = nil
      end
    else
      begin
        userdata = JSON.parse(@vortex.get(@path))
        if(userdata['properties']['firstName'])
          realname = userdata['properties']['firstName'] + ' ' + userdata['properties']['surname']
        else
          realname = nil
        end
      rescue Exception => exception
        # puts "Rescued from exception: " + exception.to_s
        realname = nil
      end
    end
    return realname
  end

  # Set folder title to same as users realname
  def update_folder_title
    @vortex.proppatch(@folder_path, '<v:userTitle xmlns:v="vrtx">' + realname + '</v:userTitle>')
  end

  # Prints debug information
  def to_s
    response  = "DAV URL      : " + @url + "\n"
    response += "Published    : " + is_published?.to_s + "\n"
    response += "Username     : '" + username.to_s + "'\n"
    response += "Folder title : '" + folder_title + "'\n"
    response += "Hidden?      : " + folder_is_hidden?.to_s + "\n"
    if(realname)
      response += "Realname     : '" + realname.to_s + "'\n"
    else
      response += "Realname     : *ldap error*\n"
    end
  end

  def create_english_from_norwegian(english_path)
    english_filename = (Pathname.new(english_path) + 'index.html').to_s
    if(@vortex.exists?(english_filename))
      # Do not overwrite!
      puts "Debug: Presentation exists: #{english_filename}"
      return false
    else

      # Create folder
      if(not(@vortex.exists?(english_path)))

        @vortex.mkdir(english_path)

        # Hide from navigation
        begin
          @vortex.proppatch(english_path,'<hidden xmlns="http://www.uio.no/navigation">true</hidden>')
        rescue
          binding.pry
          # TODO Log error
        end

        # Set realname as folder title
        folder_title = realname().to_s
        if(not(folder_title) or folder_title == "" )
          userdata = JSON.parse(@vortex.get(@path))
          folder_title = userdata['properties']['firstName'].to_s + " " + userdata['properties']['surname'].to_s
          folder_title = folder_title.strip
          if(not(folder_title) or folder_title == "")
            folder_title = username()
          end
        end

        puts "Set folder title: '" + folder_title + "'"
        if(not(folder_title) or folder_title == "" )
          binding.pry
          exit
        end
        @vortex.proppatch(english_path, '<v:userTitle xmlns:v="vrtx">' + folder_title + '</v:userTitle>')
      end

    end

    # Read existing data in norwegian
    data = JSON.parse( @vortex.get(@path) )
    # Remove norwegian language content
    data["properties"]["content"] = ""
    data["properties"]["tags"] = []
    data["properties"]["related-content"] = ""

    # Copy picture
    picture = data["properties"]["picture"]
    if(picture and picture != "")
      picture_basename = Pathname.new(picture).basename.to_s
      picture_basename = URI.escape(picture_basename)
      picture_src = @folder_path + picture_basename
      picture_content = nil
      begin
        picture_content = @vortex.get(picture_src)
      rescue
        puts "Error: could not find picture: " + picture_src
        binding.pry
      end
      if(picture_content)
        new_picture_filename = (Pathname.new(english_path) + picture_basename ).to_s
        puts "Copying picture: '" + new_picture_filename + "'"
        @vortex.put_string(new_picture_filename, picture_content)
      end
      data["properties"]["picture"] = picture_basename
    end

    # Create file
    @vortex.put_string(english_filename, data.to_json)

    # Publish
    @vortex.proppatch(english_filename, '<v:publish-date xmlns:v="vrtx">' + Time.now.httpdate.to_s + '</v:publish-date>')
  end

end

if __FILE__ == $0 then
  # url = 'https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/index.html'
  # url = 'https://www-dav.usit.uio.no/om/organisasjon/suaf/fus/ansatte/roynek/index.html'
  # url = 'https://www-dav.usit.uio.no/om/organisasjon/suaf/so/ansatte/karinar/index.html'
  # url = 'https://www-dav.usit.uio.no/om/organisasjon/sas/glit/ansatte/norara/index.html'

  url = 'https://www-dav.usit.uio.no/english/about/organisation/web/staff/harell/index.html'

  vortex = Vortex::Connection.new(url, :osx_keychain => true)
  person = PersonPresentation.new(vortex, url)
  puts person.to_s

  # english_path = 'https://www-dav.usit.uio.no/english/about/organisation/sas/glit/staff/norara/'
  english_path = '/english/about/organisation/web/staff/harell/'
  person.create_english_from_norwegian(english_path)
end
