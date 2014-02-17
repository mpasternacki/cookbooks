actions :supervise, :start, :stop, :restart
default_action :supervise

attribute :name, :kind_of => String, :name_attribute => true
attribute :command, :kind_of => String, :required => true

attribute :service              # internal

class << self
  attr_reader :all_settings
  def setting(name, *args, &block)
    (@all_settings ||= {})[name] = block
    attribute(name, *args)
  end
end

def each_setting
  self.class.all_settings.sort.each do |setting, block|
    value = self.send(setting)
    next if value.nil?
    value = block.call(value) if block
    yield setting, value
  end
end

setting :process_name, kind_of: String, default: nil
setting :numprocs, kind_of: Integer, default: nil
setting :numprocs_start, kind_of: Integer, default: nil
setting :priority, kind_of: Integer, default: nil
setting :autostart, kind_of: [FalseClass, TrueClass], default: nil
setting :autorestart, equal_to: [true, false, :unexpected], default: nil
setting :startsecs, kind_of: Integer, default: nil
setting :startretries, kind_of: Integer, default: nil
setting :exitcodes, default: nil do |val|
  if val.respond_to? :map
    val.map(&:to_s).join(',')
  else
    val
  end
end
setting :stopsignal, equal_to: ["TERM", "HUP", "INT", "QUIT", "KILL", "USR1", "USR2"], default: nil
setting :stopwaitsecs, kind_of: Integer, default: nil
setting :user, kind_of: String, default: nil
setting :stdout_logfile, kind_of: String, default: nil
setting :stdout_logfile_maxbytes, kind_of: String, default: nil
setting :stdout_logfile_backups, kind_of: Integer, default: nil
setting :stdout_capture_maxbytes, kind_of: String, default: nil
setting :stdout_events_enabled, kind_of: [FalseClass, TrueClass], default: nil
setting :stdout_syslog, kind_of: [FalseClass, TrueClass], default: nil
setting :stderr_logfile, kind_of: String, default: nil
setting :stderr_logfile_maxbytes, kind_of: String, default: nil
setting :stderr_logfile_backups, kind_of: Integer, default: nil
setting :stderr_capture_maxbytes, kind_of: String, default: nil
setting :stderr_events_enabled, kind_of: [FalseClass, TrueClass], default: nil
setting :stderr_syslog, kind_of: [FalseClass, TrueClass], default: nil
setting :environment, kind_of: [Hash, Array, String], default: nil do |val|
  case val
  when String then val
  when Array then val.map(&:to_s).join(',')
  when Hash then val.map { |k, v| "#{k}=\"#{v}\"" }.join(',')
  end
end
setting :directory, kind_of: String, default: nil
setting :umask, kind_of: [String, Integer], default: nil do |val|
  case val
  when Integer then '%03o' % val
  else val
  end
end
setting :serverurl, kind_of: String, default: nil

