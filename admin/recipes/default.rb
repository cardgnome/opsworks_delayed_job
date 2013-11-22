# # Clear the cache when clear_cache is passed from the CLI
# case @configuration[:clear_cache]
# when "all" then run "cd #{release_path} && bundle exec rake memcached:clear &"
# when "homepage" then run "cd #{release_path} && bundle exec rake memcached:clear_homepage &"
# when "homepage_and_header" then run "cd #{release_path} && bundle exec rake memcached:clear_homepage_and_header &"
# end

env = node[:deploy]['staging'][:rails_env].strip
repo = node[:deploy]['staging'][:scm][:repository].strip
revision = node[:deploy]['staging'][:scm][:revision].strip

# Notify Airbrake of deploy
run "cd #{release_path} && bundle exec rake airbrake:deploy RAILS_ENV=#{env} TO=#{env} SCM_REVISION=#{revision} SCM_REPOSITORY=#{repo} &"

# Notify NewRelic of deploy
run "cd #{release_path} && bundle exec newrelic deployments --revision=#{revision} &"

# Notify dev team of deploy
run "cd #{release_path} && RAILS_ENV=#{env} bundle exec rake deploy:notify TO=#{env} REVISION=#{revision} REPO=#{repo} &"