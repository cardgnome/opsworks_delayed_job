include_attribute 'deploy'

default[:delayed_job] = {}
default[:delayed_job][:pool_size] =
  case node[:opsworks][:instance][:instance_type]
  when 'm3.medium' then 2
  when 'm3.large' then 4
  when 'c3.large' then 4
  when 'c3.xlarge' then 8
  when 'c3.2xlarge' then 16
  when 'c3.4xlarge' then 32
  when 'c3.8xlarge' then 64
  else
    2
  end

node[:deploy].each do |application, deploy|
  default[:delayed_job][application] = {}
  default[:delayed_job][application][:pools] = {}

  # Default to node[:delayed_job][:pool_size] workers, each with empty ({}) config.
  default[:delayed_job][application][:pools][:default] =
    Hash[node[:delayed_job][:pool_size].times.map { |i| [i.to_s, {}] }]

  # Use node[:delayed_job][application][:pools][HOSTNAME] if provided.
  default[:delayed_job][application][:pool] =
    node[:delayed_job][application][:pools][node[:opsworks][:instance][:hostname]] ||
    node[:delayed_job][application][:pools][:default]

  default[:delayed_job][application][:restart_command] = "sudo monit restart -g delayed_job_#{application}_group"
end
