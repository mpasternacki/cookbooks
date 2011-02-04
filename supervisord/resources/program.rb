actions :supervise, :start, :stop, :restart

attribute :name, :kind_of => String, :name_attribute => true
attribute :command, :kind_of => String, :required => true
# attribute :numprocs, :kind_of => Integer
# attribute :numprocs_start, :kind_of => Integer

# private
attribute :service
