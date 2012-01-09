Vortex CMS Utilities
====================

A small set of utilities for publishing and managing files stored in the Vortex Content Managament System. Uses the 'net_dav' gem to communcate with WebDAV.

# Hello World

This script will prompt for username and password and publish a simple article.

```ruby
  require 'rubygems'
  require 'net/dav'
  require 'json'
  require 'vortex_utils'

  dav = Net::DAV.new('https://vortex-systest-dav.uio.no/test/')
  article = {
    "resourcetype" => "structured-article",
    "properties" =>    {
      "title" => "Hello world!",
      "introduction" => "This is the introduction.",
      "content" => "<p>And this is the main content.</p>"
    }
  }
  dav.put_string('hello-world.html', article.to_json)
  dav.vortex_publish!('hello-world.html')
```

The 'vortex_utils' library included in this script modifies the Net::DAV.new() method so it will prompt for username and password. The 'net/dav' library is used for communicating with the server using the WebDAV extensions to the HTTP protocol. Homepage for [Net::DAV](https://github.com/devrandom/net_dav) with [documentation]() and [wiki]().

If you are running OS X, 'vortex_utils' can store the password in the encrypted keychain store with the option :osx_keychain => true


```ruby
  require 'rubygems'
  require 'net/dav'
  require 'json'
  require 'vortex_utils'

  dav = Net::DAV.new('https://vortex-systest-dav.uio.no/test/', :osx_keychain => true)
```

Documents are generally stored as JSON encoded files in Vortex. JSON hashmaps are very similar to hashmaps in Ruby, and can be converted with the to_json method if the 'json' library is included. See also a [full list of properties for documents and collections in Vortex](https://www.uio.no/tjenester/it/web/vortex/drift-utvikling/arbeidsomrader/metadata/).

# Creating readable url's

To generate a filename from a title use the 'to_readable_url' method on strings. The output confirms to the policy at University of Oslo for translating nordic letters into standard letters. This script will print out the string "this-is-a-circumflexed-sentence".

```ruby
  require 'rubygems'
  require 'vortex_utils'
  print "this is a çircûmflexed senteñce".to_readable_url
  # => "this-is-a-circumflexed-sentence"
```

# Uploading graphics and other binary files


```ruby
  require 'rubygems'
  require 'net/dav'
  require 'json'
  require 'vortex_utils'

  dav = Net::DAV.new('https://vortex-systest-dav.uio.no')
  dav.cd('/test/')
  dav.put_string('dice_6.gif', open('dice_6.gif').read)
```

# Creating folders

Folders are called collections in WebDAV servers. In Vortex folders can for instance have titles, a type and be hidden from navigation.

```ruby
    @dav.mkdir('/test/test-folder')
    @dav.set_vortex_collection_title('/test/test-folder','En tittel')
    @dav.set_vortex_collection_type('/test/test-folder','article-listing')
    @dav.hide_vortex_collection('/test/test-folder')
    @dav.delete('/test/test-folder')
```

# Tip: Reverse engingeer Vortex

The document types in vortex can change over time. When creating a script that should publish something to vortex, it's good practice to create a document manually with the admin user interface and look at the generated JSON source. To do this visit the 'About' tab in the admin pages, then click the "Source address" link.

Author: Thomas Flemming

