supervisord_program "minimal" do
  command "cat"
end

supervisord_program "maximal" do
  command "cat"
  process_name 'procname'
  numprocs 2
  numprocs_start 3
  priority 777
  autostart true
  autorestart false
  startsecs 4
  startretries 5
  exitcodes '0,6,7'
  stopsignal 'QUIT'
  user 'nobody'
  stdout_logfile '/out'
  stdout_logfile_maxbytes '10M'
  stdout_logfile_backups 99
  stdout_capture_maxbytes '11M'
  stdout_events_enabled true
  stdout_syslog true
  stderr_logfile '/serr'
  stderr_logfile_maxbytes '12M'
  stderr_logfile_backups 88
  stderr_capture_maxbytes '13M'
  stderr_events_enabled true
  stderr_syslog true
  environment 'FOO="bar"'
  directory '/'
  umask '022'
  serverurl '/some.sock'
end

supervisord_program 'env_a' do
  command 'cat'
  environment [ 'FOO=1', 'BAR=2', 'BAZ=3' ]
end

supervisord_program 'env_hash' do
  command 'cat'
  environment 'FOO' => 1, 'BAR' => 2, 'BAZ' => 3
end

supervisord_program 'umask_int' do
  command 'cat'
  umask 2
end

supervisord_program 'exitcodes_a' do
  command 'cat'
  exitcodes [ 0, 6, 7 ]
end
