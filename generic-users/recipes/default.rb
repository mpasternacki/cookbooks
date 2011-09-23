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
  (node[:users][:active_groups] || node[:active_groups]).to_a | node[:users][:supergroup].to_a

log "Active groups: #{active_groups.join(', ')}" do
  level :info
end

GROUPS_IN_DATA_BAG = data_bag('groups')
GROUPS = {}
def get_group(group_name)
  GROUPS[group_name] ||= (
    GROUPS_IN_DATA_BAG.include?(group_name) ?
    data_bag_item('groups', group_name) :
    { 'id' => group_name } )
end

groups_q = active_groups.map{|g| "groups:#{g}"}.join(' OR ')
active_users = search(:users, "( #{groups_q} ) AND -shell:false")

managed_groups = Hash[
  active_users.
  inject([]) { |r, u| r|u['groups'].to_a }. # list of all groups any user belongs to
  map { |g| get_group(g) }.                 # get group hash
  map { |g| g['members'] = [] ; [ g['id'], g ] }
]

active_users.each do |u|
  username = u['username'] || u['id']
  u['groups'].to_a.each do |grp|
    managed_groups[grp]['members'] << username
  end

  # OpenID access is only for supergroup
  if node[:apache] and
      node[:apache][:allowed_openids] and
      u['groups'].include?(node[:users][:supergroup])
    Array(u['openid']).compact.each do |oid|
      node[:apache][:allowed_openids] << oid unless node[:apache][:allowed_openids].include?(oid)
    end
  end

  home_dir = "/home/#{username}"

  # fixes CHEF-1699
  ruby_block "reset group list" do
    block do
      Etc.endgrent
    end
    action :nothing
  end

  user username do
    uid u['uid']
    gid u['gid']
    shell u['shell'] == true ? nil : u['shell']
    comment u['comment']
    supports :manage_home => true
    home home_dir
    notifies :create, "ruby_block[reset group list]", :immediately
  end

  directory "#{home_dir}/.ssh" do
    owner u['id']
    group u['gid'] || u['id']
    mode "0700"
  end

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner u['id']
    group u['gid'] || u['id']
    mode "0600"
    variables :ssh_keys => (u['ssh_keys'].to_a | u['ssh_key'].to_a).join("\n")
  end
end

managed_groups.each_value do |grp|
  if grp['shell'] != false
    group grp['id'] do
      name grp['id']
      gid grp['gid']
      members grp['members']
    end
  end
end
