require_dependency File.expand_path('../lib/hooks', __FILE__)

Redmine::Plugin.register :redmine_local_ai do
  name 'Redmine Local Ai plugin'
  author 'Evandro Salvador'
  description 'Local AI into redmine'
  version '0.0.1'
  url 'https://github.com/juniorssalvador/redmine_local_ai'
  author_url 'https://github.com/juniorssalvador/redmine_local_ai'
end
