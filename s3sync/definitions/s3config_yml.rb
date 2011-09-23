define :s3config_yml,
       :aws_access_key_id => nil, :aws_secret_access_key => nil,
       :aws_calling_format => nil,
       :http_proxy_host => nil, :http_proxy_port => nil,
       :http_proxy_user => nil, :http_proxy_passsword => nil,
       :s3sync_waitonerror => nil, :s3sync_native_charset => nil,
       :group => "root", :owner => "root", :mode => "0600" do
  template params[:name] do
    source "s3config.yml.erb"
    cookbook "s3sync"
    group params[:group]
    owner params[:owner]
    mode params[:mode]
    variables :aws_access_key_id => params[:aws_access_key_id],
              :aws_secret_access_key => params[:aws_secret_access_key],
              :aws_calling_format => params[:aws_calling_format],
              :http_proxy_host => params[:http_proxy_host],
              :http_proxy_port => params[:http_proxy_port],
              :http_proxy_user => [:http_proxy_user],
              :http_proxy_passsword => params[:http_proxy_passsword],
              :s3sync_waitonerror => params[:s3sync_waitonerror],
              :s3sync_native_charset => params[:s3sync_native_charset]
  end
end
