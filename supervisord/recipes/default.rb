package "supervisor"            # FIXME: work with custom debian package

service "supervisor" do
  # Sleep a few seconds to ensure the xmlrpc interface is available again.
  # Without this the restarting of supervisor_program's will randomly fail.
  reload_command "supervisorctl reload && sleep 5"
  action [ :enable, :start ]
end
