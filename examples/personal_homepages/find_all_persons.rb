# -*- coding: utf-8 -*-
require 'rubygems'
require 'selenium-webdriver'
require 'pry'
require 'nokogiri'
require 'paint'
require 'uri'
require './get_password.rb'

# Lage en liste over alle personpresentasjoner ved å logge inn på adminsidene til
# vortex, og kjør screenscraping av alle personpresentasjonene.
#
# Dette scriptet krever ruby 1.9.2 eller høyere.

class VortexAdminScraper

  attr_accessor :driver

  def initialize(host,driver)
    @host = host
    @logfile = "personerpresentasjoner_#{host}.log"
    @adm_host = host.sub('www.','www-adm.')
    if(driver)
      @driver = driver
    else
      @driver = Selenium::WebDriver.for :firefox  # Virer!!!!
    end

    vortex_login() # Login to vortex login page
  end

  def find_persons
    @driver.navigate.to "https://#{@adm_host}/?vrtx=admin&mode=report&report-type=personReporter"
    count = 0
    wait = Selenium::WebDriver::Wait.new(:timeout => 600) # seconds

    next_link = true
    while(next_link) do

      doc = Nokogiri::HTML(@driver.page_source)
      doc.css("tr.person td[1] a").each do |link|
        link.attributes["href"].value
        uri = URI.parse(  link.attributes["href"].value.to_s )
        log(@host, uri.path)
        count = count + 1
        puts count.to_s + ":" + uri.path
      end

      begin
        next_link = @driver.find_element(:link_text => 'Neste side')
      rescue
        next_link = false
      end
      if(next_link)
        next_link.click
      end
    end
    puts Paint["Done. Logged to '#{@logfile}'.", :green]
  end

  # Dead simple logger
  def log(host, path)
    # Empty logfile first:
    if(@dirty_logfile == false)then
      File.open(@logfile, 'w') do |f|
        f.write('')
      end
    end
    File.open(@logfile, 'a') do |f|
      host = host.sub('www.','www-dav.')
      f.write( "https://#{host}#{path}\n" )
    end
    @dirty_logfile = true
  end

  # Login if necessary
  def vortex_login
    @driver.navigate.to "https://#{@adm_host}/?vrtx=admin&mode=report&report-type=personReporter"
    password_field = false
    begin
      password_field = @driver.find_element(:id => 'password')
    rescue
      password_field = false
    end

    if(password_field)
      wait = Selenium::WebDriver::Wait.new(:timeout => 600) # seconds timeout
      username = ENV['USER']
      password = get_password(@adm_host)
      @driver.find_element(:id => 'username').send_keys(username)
      @driver.find_element(:id => 'password').send_keys(password)
      @driver.find_element(:css => 'button').click
    end
  end
end

if __FILE__ == $0 then
  # hosts = ['www.uio.no', 'www.uv.uio.no', 'www.hf.uio.no', 'www.mn.uio.no', 'www.sv.uio.no',
  #          'www.jus.uio.no', 'www.uv.uio.no','www.med.uio.no','www.odont.uio.no','www.tf.uio.no']
  hosts = ['www.usit.uio.no']
  driver = nil
  hosts.each do |host|
    scraper = VortexAdminScraper.new(host,driver)
    driver = scraper.driver
    scraper.find_persons()
  end
  driver.quit
end
