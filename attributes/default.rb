include_attribute "deploy"

default[:delayed_job] = {}
default[:delayed_job][:pool_size] = case node[:opsworks][:instance][:instance_type]
	when 'm1.small' then 2
	when 'c1.medium' then 4
	when 'c1.xlarge' then 8
	when 'm1.large' then 8
	else 
	  2
end

node[:deploy].each do |application, deploy|
  
  default[:delayed_job][application] = {}
  default[:delayed_job][application][:pools] = {}
  
  # Default to node[:delayed_job][:pool_size] workers, each with empty ({}) config.
  default[:delayed_job][application][:pools][:default] = Hash[node[:delayed_job][:pool_size].times.map{|i| [i.to_s, {}] }]
  
  # Use node[:delayed_job][application][:pools][HOSTNAME] if provided.
  default[:delayed_job][application][:pool] = node[:delayed_job][application][:pools][node[:opsworks][:instance][:hostname]] || node[:delayed_job][application][:pools][:default]
  Chef::Log.debug("Set delayed_job attributes for #{application} to #{node[:delayed_job][application].to_hash.inspect}")
  
  default[:delayed_job][application][:restart_command] = "sudo monit restart -g delayed_job_#{application}_group"
  
end

