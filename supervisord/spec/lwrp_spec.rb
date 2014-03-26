require_relative './spec_helper'

describe 'supervisord_program' do
  let(:chef_run) { ChefSpec::Runner.new(step_into: ['supervisord_program']).converge('supervisord::example') }

  it 'automatically includes supervisord recipe' do
    expect(chef_run).to include_recipe('supervisord')
  end

  it 'registers a minimal program' do
    expect(chef_run).to render_file('/etc/supervisor/conf.d/minimal.conf').with_content <<EOF
[program:minimal]
command = cat
EOF
    expect(chef_run.template('/etc/supervisor/conf.d/minimal.conf')).to notify('service[supervisor]').to(:reload)
  end

  it 'supports all the parameters' do
    conf_lines = <<EOF.lines.map(&:strip)
[program:maximal]
command = cat
process_name = procname
numprocs = 2
numprocs_start = 3
priority = 777
autostart = true
autorestart = false
startsecs = 4
startretries = 5
exitcodes = 0,6,7
stopsignal = QUIT
stopasgroup = false
killasgroup = false
user = nobody
stdout_logfile = /out
stdout_logfile_maxbytes = 10M
stdout_logfile_backups = 99
stdout_capture_maxbytes = 11M
stdout_events_enabled = true
stdout_syslog = true
stderr_logfile = /serr
stderr_logfile_maxbytes = 12M
stderr_logfile_backups = 88
stderr_capture_maxbytes = 13M
stderr_events_enabled = true
stderr_syslog = true
environment = FOO="bar"
directory = /
umask = 022
serverurl = /some.sock
EOF
    conf_lines.each do |line|
      expect(chef_run).to render_file('/etc/supervisor/conf.d/maximal.conf').
        with_content(line)
    end
  end

  it 'renders environment provided as an array' do
    expect(chef_run).to render_file('/etc/supervisor/conf.d/env_a.conf').
      with_content('environment = FOO=1,BAR=2,BAZ=3')
  end

  it 'renders environment provided as a hash' do
    expect(chef_run).to render_file('/etc/supervisor/conf.d/env_hash.conf').
      with_content('environment = FOO="1",BAR="2",BAZ="3"')
  end

  it 'renders umask provided as an integer' do
    expect(chef_run).to render_file('/etc/supervisor/conf.d/umask_int.conf').
      with_content('umask = 002')
  end

  it 'renders exitcodes provided as an array' do
    expect(chef_run).to render_file('/etc/supervisor/conf.d/exitcodes_a.conf').
      with_content('exitcodes = 0,6,7')
  end
end
