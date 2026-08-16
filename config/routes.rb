# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
post 'local_ai/summarize', :to => 'local_ai#summarize'
get  'local_ai/similar/:issue_id', :to => 'local_ai#similar'
