require 'chef/mixin/shell_out'

include Chef::Mixin::ShellOut

def initialize(*args)
  super
  @run_context.include_recipe "supervisord"
end


action :supervise do
  template "/etc/supervisor/conf.d/#{new_resource.name}.conf" do
    source "supervised-program.conf.erb"
    cookbook "supervisord"
    owner "root"
    group "root"
    mode "0600"
    variables :program => new_resource
    notifies :reload, resources("service[supervisor]")
  end
  new_resource.updated_by_last_action(true)
end

[:start, :stop, :restart].each do |act|
  action act do
    shell_out! "supervisorctl #{act} #{new_resource.name}"
    new_resource.updated_by_last_action(true)
  end
end
