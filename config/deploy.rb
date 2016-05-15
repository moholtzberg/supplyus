set :user, "rails"
set :use_sudo, false
# set :application, "twenty-four-seven"
set :repo_url, 'git@github.com:moholtzberg/recurring.git'
set :branch, "master"
set :deploy_to, "/home/rails/twenty_four_seven"

set :log_level, :debug
# set :rvm1_ruby_version, "ruby-2.1.5-p273"
set :ssh_options, {:forward_agent => true}
set :pty, false
set :deploy_via, :copy
set :bundle, 'source $HOME/.bashrc && bundle'
set :default_env, { rvm_bin_path: '/usr/local/rvm/rubies/ruby-2.2.1/bin/ruby' }
set :default_shell, '/bin/bash'
set :shell, '/bin/bash'
# default_environment["RAILS_ENV"] = 'production'
# set :linked_files, %w{config/database.yml config/newrelic.yml app/views/spree/shared/_lucky_orange.html.erb public/google98548de7465bed0f.html}
set :linked_files, %w{config/application.rb config/database.yml}
# set :linked_dirs, %W{public/spree}

task :init do
  on roles(:all) do
    rvm_path = fetch(:rvm_custom_path)
    rvm_path ||= case fetch(:rvm_type)
    when :auto
      if test("[ -d #{RVM_SYSTEM_PATH} ]")
        RVM_SYSTEM_PATH
      else
        RVM_USER_PATH
      end
    when :system, :mixed
      RVM_SYSTEM_PATH
    else # :user
      RVM_USER_PATH
    end
    set :rvm_path, rvm_path
    set :rvm_bins_path, fetch(:rvm_type) == :mixed ? RVM_USER_PATH : rvm_path

    rvm_ruby_version = fetch(:rvm_ruby_version)
    rvm_ruby_version ||= capture(:rvm, "current")
    set :rvm_ruby_version, rvm_ruby_version
  end
end

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      within release_path do
        execute :rake, 'cache:clear'
      end
    end
  end
  
  # after 'deploy:publishing', 'deploy:restart'
  # task :restart do
  #   invoke 'unicorn:legacy_restart'
  # end
  
end