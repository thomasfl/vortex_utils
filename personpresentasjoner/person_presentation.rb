# -*- coding: utf-8 -*-
require 'rubygems'
require 'vortex_client'
require 'uri'
require 'nokogiri'
require 'pry'
require './ldap_util'
require 'json'
require 'iconv'

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
    if(username)
      begin
        realname = ldap_realname(username)
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

end

# Test and example usage:
if __FILE__ == $0 then
  # url = 'https://www-dav.uio.no/personer/adm/usit/web/wapp/thomasfl/index.html'
  # url = 'https://www-dav.mn.uio.no/gammelt/cees-konvertert/cees-htmluendret/people/technical/tina-graceline/index.html'
  # url = 'https://www-dav.mn.uio.no/ifi/english/people/aca/amirh/index.html'
  # url = 'https://www-dav.mn.uio.no/kjemi/english/people/aca/boras/index.html'
  # url = 'https://www-dav.mn.uio.no/gammelt/cees-konvertert/cees/people/admin/torewall/index.html'

  # url = 'https://www-dav.tf.uio.no/personer/vit/faste/ingunm/index.html'
  # url = 'https://www-dav.tf.uio.no/gammelt/%7Ekonvertert-tf-0312a/aks/aksadm/person/index.html'
  url = 'https://www-dav.tf.uio.no/gammelt/%7Ekonvertert-tf-0312a/aks/aksadm/person/index.html'
  vortex = Vortex::Connection.new(url, :osx_keychain => true)
  person = PersonPresentation.new(vortex,url)

  puts "__________________________________________________"
  puts person.to_s

  if(person.realname != person.folder_title and person.realname)
    puts "Updating folder title..."
    person.update_folder_title
  end

  if(!person.folder_is_hidden?)
    puts "Hiding person folder..."
    person.hide_folder
  end

end
