#
# Cookbook Name:: generic-users
# Recipe:: default
#
# Copyright 2011, Maciej Pasternacki
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

active_groups =
  Array(node[:users][:active_groups] || node[:active_groups]) | Array(node[:users][:supergroup])

log "Active groups: #{active_groups.join(', ')}" do
  level :info
end

groups_q = active_groups.map{|g| "groups:#{g}"}.join(' OR ')
active_users = GenericUsers::User::search("( #{groups_q} ) AND -shell:false")

managed_groups = Hash[
  active_users.
  inject([]) { |r, u| r|u[:groups] }.       # list of all groups any user belongs to
  map { |g| [ g, [] ] }
]

active_users.each do |u|
  u.data[:groups].each do |grp|
    managed_groups[grp] << u[:username]
  end

  # OpenID access is only for supergroup
  if node[:apache] and
      node[:apache][:allowed_openids] and
      u['groups'].include?(node[:users][:supergroup])
    Array(u['openid']).compact.each do |oid|
      node[:apache][:allowed_openids] << oid unless node[:apache][:allowed_openids].include?(oid)
    end
  end

  home_dir = "/home/#{u[:username]}"

  # fixes CHEF-1699
  ruby_block "reset group list" do
    block do
      Etc.endgrent
    end
    action :nothing
  end

  user u[:username] do
    uid u[:uid]
    gid u[:gid]
    shell u[:shell] == true ? nil : u[:shell]
    comment u[:comment]
    supports :manage_home => true
    home home_dir
    notifies :create, "ruby_block[reset group list]", :immediately
  end

  directory "#{home_dir}/.ssh" do
    owner u[:username]
    group u[:gid] || u[:username]
    mode "0700"
  end

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner u[:username]
    group u[:gid] || u[:username]
    mode "0600"
    variables :ssh_keys => (Array(u['ssh_keys']) | Array(u['ssh_key'])).join("\n")
  end
end

managed_groups.each_pair do |grp_id, grp_members|
  grp = GenericUsers::get_group(grp_id)
  if grp['shell'] != false
    group grp['id'] do
      name grp['id']
      gid grp['gid']
      members grp_members
    end
  end
end
