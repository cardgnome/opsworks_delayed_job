# Adapted from unicorn::rails: https://github.com/aws/opsworks-cookbooks/blob/master/unicorn/recipes/rails.rb

include_recipe "delayed_job::service"

# setup delayed_job service per app
node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping delayed_job::setup application #{application} as it is not a Rails app")
    next
  end

  # opsworks_deploy_user do
  #   deploy_data deploy
  # end

  # opsworks_deploy_dir do
  #   user deploy[:user]
  #   group deploy[:group]
  #   path deploy[:deploy_to]
  # end

  directory "/srv/www/tmp" do
    mode 0755
    owner deploy[:user]
    group deploy[:group]
    action :create
  end

  # Allow deploy user to restart workers
  template "/etc/sudoers.d/#{deploy[:user]}" do
    mode 0440
    source "sudoer.erb"
    variables :user => deploy[:user]
  end

  template "/etc/monit.d/delayed_job_#{application}.monitrc" do
    mode 0644
    source "delayed_job.monitrc.erb"
    variables(:deploy => deploy, :application => application, :delayed_job => node[:delayed_job][application])

    notifies :reload, resources(:service => "monit"), :immediately
  end
end
