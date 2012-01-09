# -*- coding: utf-8 -*-
require 'rubygems'
require 'find'
require 'nokogiri'
require 'vortex_client'
require 'pathname'
require 'pp'

# Make all internal absolute links relative

class Relativize

  def initialize(url)
    @path = URI.parse(url).path
    @vortex = Vortex::Connection.new(url, :osx_keychain => true)
  end

  def get_json_content(path)
    item = @vortex.get(path)
    src = JSON.parse(item)
    return src["properties"]["content"]
  end

  def find_links(doc, &block)
    doc.css('a').each do |element|
      link = element['href']
      if(link =~ /^\/\?/)then
        link = "/"
      end
      if(not(link =~ /^#/ ) and (link.to_s != "") and (not(link.to_s =~ /^mailto:/)))then
        yield element
      end
    end

  end

  def relativize_file(path)
    html = get_json_content(path)
    puts html
    puts "----------------"
    doc = Nokogiri::HTML.parse(html)
    find_links(doc) do |link|
      puts link['href']
    end

    # puts html

  end

end

relativize = Relativize.new('https://www-dav.uio.no/om/samarbeid/samfunn-og-naringsliv/partnerforum/konv/')
relativize.relativize_file('/om/samarbeid/samfunn-og-naringsliv/partnerforum/konv/aktiviteter/konferanser/2011/2011-05-26_test.html')
