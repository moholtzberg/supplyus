# worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
# timeout 15
# preload_app true
# before_fork do |server, worker|
#   Signal.trap 'TERM' do
#     puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
#     Process.kill 'QUIT', Process.pid
#   end
# 
#   defined?(ActiveRecord::Base) and
#     ActiveRecord::Base.connection.disconnect!
# end
# after_fork do |server, worker|
#   Signal.trap 'TERM' do
#     puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
#   end
# 
#   defined?(ActiveRecord::Base) and
#     ActiveRecord::Base.establish_connection
# end

# https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-unicorn-and-nginx-on-ubuntu-14-04
# set path to application
# app_dir = File.expand_path("../..", __FILE__)
app_dir = "/home/rails/supplyus/current"
shared_dir = "/home/rails/shared"
working_directory app_dir

# Set unicorn options
worker_processes 4
preload_app true
timeout 30

# Set up socket location
listen "#{shared_dir}/sockets/unicorn.sock", :backlog => 64

# Logging
stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

# Set master PID location
pid "#{shared_dir}/pids/unicorn.pid"

before_fork do |server, worker|
  Signal.trap 'TERM' do
  puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
  Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
  puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.establish_connection
end

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  ENV['BUNDLE_GEMFILE'] = File.join(root, 'Gemfile')
end

