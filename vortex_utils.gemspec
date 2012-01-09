Gem::Specification.new do |s|
  s.name = %q{vortex_utils}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas Flemming"]
  s.date = %q{2012-01-01}
  s.description = %q{Utilities for managing content on Vortex web content management system through webdav}
  s.email = %q{thomas.flemming@usit.uio.no}
  s.files = [
     "VERSION",
     "lib/vortex_utils.rb",
     "lib/vortex_utils/string_extensions.rb",
  ]
  s.homepage = %q{http://github.com/thomasfl/vortex_utils}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.8.10}
  s.summary = %q{Vortex CMS utilites}
  s.test_files = [
    "test/helper.rb",
    "test/test_net_dav_extensions.rb",
    "test/test_string_extensions.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<net_dav>, [">= 0.5.0"])
      s.add_runtime_dependency(%q<highline>, [">= 1.6.9"])
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 2.11.1"])
    else
      s.add_dependency(%q<net_dav>, [">= 0.5.0"])
      s.add_dependency(%q<highline>, [">= 1.6.9"])
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 2.11.1"])
    end
  else
    s.add_dependency(%q<net_dav>, [">= 0.5.0"])
    s.add_dependency(%q<highline>, [">= 1.6.9"])
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 2.11.1"])
  end
end

