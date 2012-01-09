require 'rubygems'
require 'vortex_client'

vortex = Vortex::Connection.new('https://nyweb3-dav.uio.no/om/jobb/stillinger/', :osx_keychain => true)
docs = []
vortex.find('.', :recursive => true, :suppress_errors=>true) do |item|
  docs << item.url.to_s
  # item.proppatch('<v:unpublish-date xmlns:v="vrtx">'+Time.now.httpdate.to_s+'</v:unpublish-date>')
end

docs.each do |url|
  puts url
  path = URI.parse(url).path.to_s
  begin
    vortex.proppatch(path, '<v:unpublish-date xmlns:v="vrtx">'+Time.now.httpdate.to_s+'</v:unpublish-date>')
  rescue Exception => e
    puts e.to_s + " " + path
  end

end
