# -*- coding: utf-8 -*-
require_relative 'helper'
require 'json'

class NetDAVExtensions < Test::Unit::TestCase

  def setup
    uri = 'https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/vortex-script/test/'
    @dav = Net::DAV.new(uri,:osx_keychain => true)
  end

  should "delete password from keychain and prompt for password" do
    # dav = Net::DAV.new("https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/vortex-script/test/",
    #                      :osx_keychain => true, :prompt_for_password => true)
  end

  should "publish article" do
    tittel = "My little testing article ÆØÅ"

    article = {
      "resourcetype" => "structured-article",
      "properties" =>    {
        "title" => tittel,
        "introduction" => "Dette er innledningen til artikkelen",
        "content" => "<p>Her er innholdet i artikkelen</p>"
      }
    }

    filename = tittel.to_readable_url + '.html'
    @dav.put_string(filename, article.to_json)
    @dav.vortex_publish!(filename)
    assert @dav.exists?(filename)
  end

  should "set publish date to 2 days ahead and unpublish date to 3 days" do
    article = {
      "resourcetype" => "structured-article",
      "properties" =>    {
        "title" => "Test article",
        "introduction" => "Dette er innledningen til artikkelen",
        "content" => "<p>Her er innholdet i artikkelen</p>"
      }
    }
    @dav.put_string('test-article.html', article.to_json)
    @dav.vortex_publish('test-article.html', Time.now + (2*24*60*60))
    @dav.vortex_unpublish('test-article.html', Time.now + (3*24*60*60))
  end

  should "create paths and set type" do
    path = '/om/organisasjon/web/wapp/ansatte/thomasfl/vortex-script/test/'
    @dav.create_path(path + 'folders/to/be/created', :type => "article-listing")
    assert(@dav.exists?(path + 'folders/to/be/created'))
    @dav.delete(path + 'folders')
    assert( !@dav.exists?(path + 'folders') )

    folder_path = path + 'test_folder'
    if(@dav.exists?(folder_path))
      @dav.delete(folder_path)
    end
    @dav.mkdir(folder_path)
    @dav.set_vortex_collection_title(folder_path,'En tittel')
    @dav.set_vortex_collection_type(folder_path,'article-listing')
    @dav.hide_vortex_collection(folder_path)
    @dav.delete(folder_path)
  end

end
