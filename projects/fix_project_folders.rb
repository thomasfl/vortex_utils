require 'rubygems'
require 'vortex_client'
require './project.rb'

# ProjectsChecker - Fixes common errors with project presentations stored in Vortex CMS.
#                  Takes as input a file with urls to project presentations.
#
# Author: thomas.flemming(@)usit.uio.no 2011
class ProjectFixer

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
      project = ProjectDocument.new(@vortex, dav_url)

      puts "_____"
      puts dav_url
      puts project.to_s

      if(!project.folder_is_hidden?)
        puts "  Hiding folder from navigation"
        log("hiding:#{dav_url.strip}")
        project.hide_folder
      end

    end

  end

end


if __FILE__ == $0 then
  # project = ProjectFixer.new('logs/projects_www.jus.uio.no.log', 'logs/changes_www.jus.uio.no.log')
  project = ProjectFixer.new('logs/projects_www.tf.uio.no.log', 'logs/changes_www.tf.uio.no.log')
  project.fix_errors
end
