# -*- coding: utf-8 -*-
# Search and replace a set of sentences in a set of folders on vortex webdav server.
#
#
# for alle forside-dokumenter på jus.uio.no, tf.uio.no, hf.uio.no, uv.uio.no, sv.uio.no, odontologi.uio.no
#
#
# Author: Thomas Flemming 2010 thomasfl@usit.uio.no

require 'rubygems'
require 'vortex_client'
require 'json'
require 'scrape_vortex_search'
require 'pp'
require 'uri'

replacements = {
   "Ansettelsesforhold ved UiO" => "Ansettelsesforhold for alle ansatte ved UiO",
   "Arbeidsstøtte ved UiO" => "Arbeidsstøtte for alle ansatte ved UiO",
   "Drift og servicefunksjoner ved UiO" =>"Drift og servicefunksjoner for alle ansatte ved UiO",
   "Kompetanseutvikling ved UiO" => "Kompetanseutvikling for alle ansatte ved UiO"
}

hosts = [
  "https://www-dav.hf.uio.no/",
  "https://www-dav.odont.uio.no",
  "https://www-dav.jus.uio.no/",
  "https://www-dav.tf.uio.no/",
  "https://www-dav.uv.uio.no/",
  "https://www-dav.sv.uio.no/"
]

# Opens a json document in vortex.
#
# Example:
#
#     with_json_doc(path) do |dav_item, json_data|
#        puts json_data["resourcetype"]
#        dav_item.content = dav_item.content.sub('Oxford','UiO')
#     end

def with_json_doc(url)
  vortex = Vortex::Connection.new(url,:use_osx_keychain => true)
  if(not(vortex.exists?(url)))then
    puts "Warning: Can't find " + url
    return -1
  end
  vortex.find(url) do |item|
    begin
      data = JSON.parse(item.content)
      yield item, data
    rescue
      return -1
    end
  end
end

hosts.each do |host|
  search_host = host.sub("www-dav","www")
  replacements.each do |from, to|
    puts "Replacing: '#{from}' => '#{to}'"
    search_results = vortex_search(search_host, from)
    # TODO remove not( /(\.html)|\// alt untatt '.../' eller 'html'
    search_results.delete_if {|x| x =~ /\.pdf$/} # Remove pdf files
    count = 0
    search_results.each do |path|
      if(not(path =~ /\.html$/))then
        path = path + "index.html"
      end
      # count = count + replace(host, path, from, to, "frontpage")
      path = path.sub(/^http:/, 'https:').sub(/\/\/www\./,'//www-dav.')
      with_json_doc(path) do |item, data|
        if(data["resourcetype"] == "frontpage")then
          puts "Updating:" + path
          item.content = item.content.sub(from,to)

          if(item.content.to_s =~ Regexp.new(from))then
            puts "Warning: Not updated."
          else
            count = count + 1
          end
        end
      end
    end
    puts "Updated #{count.to_s} documents."
    puts
  end
end
