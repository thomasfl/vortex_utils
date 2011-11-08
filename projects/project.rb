require 'rubygems'
require 'vortex_client'
require 'uri'
require 'nokogiri'
require 'pry'
require 'json'

class ProjectDocument

  def initialize(vortex, url)
    @vortex = vortex
    @url = url
    uri = URI.parse(@url)
    @path = uri.path
    @folder_path = @path.sub(/[^\/]*$/,'')
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

  # Prints debug information
  def to_s
    response  = "DAV URL      : " + @url + "\n"
    response += "Published    : " + is_published?.to_s + "\n"
    response += "Folder title : '" + folder_title + "'\n"
    response += "Hidden?      : " + folder_is_hidden?.to_s + "\n"
  end
end

if __FILE__ == $0 then
  url = 'https://www-dav.jus.uio.no/english/research/areas/intrel/projects/judicial-dialogues-ecrp/index.html'
  vortex = Vortex::Connection.new(url, :osx_keychain => true)
  project = ProjectDocument.new(vortex,url)
  puts project.to_s

end
