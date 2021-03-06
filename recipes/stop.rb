# Adapted from nginx::stop: https://github.com/aws/opsworks-cookbooks/blob/master/nginx/recipes/stop.rb

include_recipe "delayed_job::service"

node[:deploy].each do |application, deploy|
  
  execute "stop Delayed Job processes for app #{application}" do
    command "sudo monit stop -g delayed_job_#{application}_group"
  end
  
end
