package "ca-certificates"

S3SYNC_TARBALL = "#{Chef::Config[:file_cache_path]}/s3sync.tar.gz"

execute "unpack s3sync" do
  command "tar -C /opt -xzf #{S3SYNC_TARBALL}"
  action :nothing
end

remote_file S3SYNC_TARBALL do
  source node[:s3sync][:tarball_url]
  checksum node[:s3sync][:tarball_sha256]
  notifies :run, resources(:execute => "unpack s3sync"), :immediately
end
