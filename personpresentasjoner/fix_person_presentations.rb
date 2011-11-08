# -*- coding: utf-8 -*-
require 'rubygems'
require 'vortex_client'
require './ldap_util.rb'
require './person_presentation.rb'


# PersonsChecker - Fixes common errors with person presentations stored in Vortex CMS.
#                  Takes as input a file with urls to person presentations.
#
# Author: thomas.flemming(@)usit.uio.no 2011
class PersonsChecker

  attr_accessor :filename, :host

  def initialize(filename, logfile)
    @filename = filename
    @dav_host = open(@filename).first.strip
    @vortex = Vortex::Connection.new(@dav_host, :osx_keychain => true)
    @logfile = logfile
  end

  def log(string)
    # Empty logfile first:
    if(@dirty_logfile == false)then
      File.open(@logfile, 'w') do |f|
        f.write('')
      end
    end
    File.open(@logfile, 'a') do |f|
      f.write("#{string}\n")
    end
    @dirty_logfile = true
  end

  def fix_errors
    open(@filename).each do |dav_url|
      dav_url = dav_url.strip
      person = PersonPresentation.new(@vortex, dav_url)
      puts dav_url
      # puts person.to_s

      if(person.is_published?)


        if(person.realname != person.folder_title)
          if(person.realname == nil or person.realname == "")
            if(person.username and !person.realname)
              log("ldap-error:#{dav_url.strip}:#{person.folder_title}:#{person.realname}:#{person.username}")
              puts "  Ldap error for user #{person.username}. Title '#{person.folder_title.to_s}' unchecked."
            else
              log("unable-to-rename-error:#{dav_url.strip}:#{person.folder_title}:#{person.realname}")
              puts "  Unable to upate folder title from #{person.folder_title.to_s} to #{person.realname.to_s}"
            end

          else
            puts "  Updating folder title from #{person.folder_title} to #{person.realname}"
            log("renaming:#{dav_url.strip}:#{person.folder_title}:#{person.realname.strip}")
            person.update_folder_title
          end
        end


        if(!person.folder_is_hidden?)
          puts "  Hiding folder from navigation"
          log("hiding:#{dav_url.strip}")
          person.hide_folder
        end

      else
        puts "  Ignoring unpublished person presentation."
        log("unpublished-error:#{dav_url.strip}")
      end
    end

  end

end


if __FILE__ == $0 then
  hosts = ['www.uio.no', 'www.uv.uio.no', 'www.hf.uio.no', 'www.mn.uio.no', 'www.sv.uio.no',
           'www.jus.uio.no', 'www.uv.uio.no','www.med.uio.no','www.odont.uio.no','www.tf.uio.no']

  hosts.each do |host|
    person = PersonsChecker.new("logs/personerpresentasjoner_#{host}.log", "logs/changes_#{host}.log")
    person.fix_errors
  end
end
