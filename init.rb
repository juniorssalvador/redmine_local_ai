require_dependency File.expand_path('../lib/hooks', __FILE__)

Redmine::Plugin.register :redmine_local_ai do
  name 'Redmine Local Ai plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end
