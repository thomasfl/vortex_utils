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


vortex = Vortex::Connection.new('https://www-dav.usit.uio.no', :osx_keychain => true)
vortex.cd '/om/organisasjon/sas/glit/ansatte/norara/'
binding.pry
