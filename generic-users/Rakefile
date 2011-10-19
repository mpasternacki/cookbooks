# -*- ruby -*-

desc "Regenerate HTML docs"
task :doc do
  sh "bundle exec yard doc libraries/user.rb"
end

desc "Serve HTML docs locally"
task :servedoc do
  sh "bundle exec yard server --reload"
end

desc "Run tests"
task :test do
  sh "bundle exec rspec -c -f d spec.rb"
end

task :share do
  sh "cd .. ; knife cookbook site share generic-users other"
end
