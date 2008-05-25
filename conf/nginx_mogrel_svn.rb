#
# General configuration
#
set :user, "you_ssh_name"
set :ssh_flags,    '-p 22'
set :sudo_cmd, 'sudo'
set :sudo_password, 'you_sudo_password'
set :application,   'yourapp'
set :domain, 'www.youdomain.com'
set :deploy_to,    '/home/www/webroot/youdomain'
set :repository,    'http://you_svn_url'
set :scm,         "svn"

#Config web app
set :web, "nginx"


#
# Mongrel configuration
#
set :mongrel_clean,         true
set :mongrel_command,    'mongrel_rails'
set :mongrel_group,         'www-data'
set :mongrel_port,          9000
set :mongrel_servers,       2
set :mongrel_address,       '127.0.0.1'
set(:mongrel_conf)          { '#{shared_path}/mongrel_cluster.conf' }
set :mongrel_config_script, nil
set :mongrel_environment,   'production'
set :mongrel_log_file,      nil
set :mongrel_pid_file,      nil
set :mongrel_prefix,        nil
set :mongrel_user,          'mongrel'

namespace :vlad do
  desc 'Runs vlad:update, vlad:symlink, vlad:migrate and vlad:start'
  task :deploy => ['vlad:update', 'vlad:symlink', 'vlad:migrate', 'vlad:stop_app', 'vlad:start_app']

  desc 'Symlinks your custom directories'
  remote_task :symlink, :roles => :app do
    run "ln -s #{shared_path}/database.yml #{current_release}/config/database.yml"
  end
end



