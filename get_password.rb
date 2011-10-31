# Simple snippet to retrieve password for a host using os x keychain
# If no password is available, ask for password and store it in os x keychain
# for future use.
def get_password(host)
  # Retrieve password from OS X KeyChain.
  osx =  (RUBY_PLATFORM =~ /darwin/)
  if(osx)then

    require 'osx_keychain'
    keychain = OSXKeychain.new
    user = ENV['USER']
    pass = keychain[host, user ]

    if(pass == nil) then
      puts "Password for '#{host}' not found on OS X KeyChain. "
      puts "Enter password to store new password on OS X KeyChain."
      require 'highline/import'

      pass = ask("Password: ") {|q| q.echo = "*"} # false => no echo
      keychain[host, user] = pass
      puts "Password for '#{user}' on '#{host}' stored on OS X KeyChain."
    end
    return pass

  else
    puts "Warning: Not running on OS X."
  end

end
