# 
# To change this template, choose Tools | Templates

require 'vlad'

namespace :vlad do
  ##
  # Nginx app server
  set :nginx_sites_available, "/etc/nginx/sites-available"
  set :nginx_sites_enabled, "/etc/nginx/sites-enabled"
  
  #Some cmd for nginx  
  set :nginx_command, ' /etc/init.d/nginx'
  
  def sudo(command)
    run [sudo_cmd, sudo_flags, command].join(' ')
  end

  desc "Start the web servers"
  remote_task :start_web, :roles => :web  do
    sudo  "#{nginx_command} start"
  end

  desc "Stop the web servers"
  remote_task :stop_web, :roles => :web  do
    sudo " #{nginx_command} stop"
  end
  
  desc "ReStart the web servers"
  remote_task :restart_web, :roles => :web  do
   sudo   "#{nginx_command} restart"
  end
  
  ##
  # Everything HTTP.

  desc "(Re)Start the web and app servers"

  remote_task :start do
    Rake::Task['vlad:start_app'].invoke
    Rake::Task['vlad:start_web'].invoke
  end

  desc "Stop the web and app servers"

  remote_task :stop do
    Rake::Task['vlad:stop_app'].invoke
    Rake::Task['vlad:stop_web'].invoke
  end
  
  desc "Config Nginx servers"
  remote_task :start_app, :roles => :app do
    # run the template  
    run_template(nginx_remote_template,nginx_remote_config)
    #move the config in to sites-available
    sudo "mv #{nginx_remote_config} /etc/nginx/sites-available/#{application}" 
    #add a symlink into sites enabled 
    sudo "ln -s -f /etc/nginx/sites-available/#{application}  /etc/nginx/sites-enabled/#{application}" 
  end
  
  def nginx(cmd) # :nodoc:
    cmd = "#{nginx_command} #{cmd} -C #{mongrel_conf}"
    cmd << ' --clean' if mongrel_clean
    cmd
  end

  desc "Restart the app servers"

  remote_task :start_app, :roles => :app do
    run mongrel("cluster::restart")
  end

  desc "Stop the app servers"

  remote_task :stop_app, :roles => :app do
    run mongrel("cluster::stop")
  end
  
  #
  # Get the template from the server,
  # parse it, and place the new file back on the server
  # 
  def run_template(remote_file_to_get,remote_file_to_put)
    require 'erb'  #render not available in Capistrano 2
    get(remote_file_to_get,"template.tmp")      # get the remote file
    template=File.read("template.tmp")          # read it
    buffer= ERB.new(template).result(binding)   # parse it
    put buffer,remote_file_to_put               # put the result
  end 
  
end


