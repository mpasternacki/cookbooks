package "xvfb"

template "/etc/init.d/xvfb" do
  source "xvfb.init.erb"
  mode "0755"
end

service "xvfb" do
  action [:start, :enable]
end
