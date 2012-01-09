# -*- coding: utf-8 -*-
require 'rubygems'
require 'vortex_client'
require 'nokogiri'
require 'pry'
require 'json'
require './person_presentation.rb'
require 'uri'

host = "https://www-dav.usit.uio.no"
@vortex = Vortex::Connection.new(host, :osx_keychain => true)

def norwegian_to_english_path(norwegian_url)
  path = URI.parse(norwegian_url).path.to_s
  path = path.gsub("/ansatte/", "/staff/")
  path = path.gsub(/^\/om\/organisasjon\//, '/english/about/organisation/')
  path = path.sub(/[^\/]*$/,'')
  return path
end

filename = "logs/personerpresentasjoner_www.usit.uio.no.log"
open(filename).each do |dav_url|
  dav_url = dav_url.strip

  english_path = norwegian_to_english_path(dav_url)
  puts dav_url
  puts " => " + english_path

  folder = english_path.sub(/[^\/]*\//,'')
  # puts "=> " + folder
  if(not(@vortex.exists?(folder)))
    puts "Error. Does not exists: " + folder
    exit
  end

  person = PersonPresentation.new(@vortex, dav_url)
  person.create_english_from_norwegian(english_path)
  puts
end


