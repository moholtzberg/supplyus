require 'mina/rails'
require 'mina/git'
require 'mina/rvm'    # for rvm support. (https://rvm.io)

set :application_name, 'supply.us'
set :domain, '162.243.54.198'

set :deploy_to, '/home/rails/supplyus'
set :repository, 'git://github.com/moholtzberg/supplyus.git'
set :branch, 'master'

# Optional settings:
set :user, 'rails'          # Username in the server to SSH to..
set :rvm_use_path, '/usr/local/rvm/scripts/rvm'

# set :shared_dirs, fetch(:shared_dirs, []).push('somedir')
set :shared_files, fetch(:shared_files, []).push('config/application.rb', 'config/database.yml', 'config/sunspot.yml')

task :environment do
  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use', 'ruby-2.3.0@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0}
end


# desc "Copy files"
# task :copy do
#   on roles(:all) do |host|
#      %w[ supplyus_secrets.yml ].each do |f|
#         upload! '../shared/' + f , '../../shared/' + f
#      end
#   end
# end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    in_path(fetch(:current_path)) do
      command %{gem install json -v '1.8.6'}
    end
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'
    
    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'foreman start' }
end
