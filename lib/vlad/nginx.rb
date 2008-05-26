 
# 
# Author:IceskYsl@1sters!
# Blog:http://iceskysl.1sters.com
# Email:Iceskysl@gmail.com
# Date:2008.05.24
# 
# This file todo?
#this is a task to config nginx and mogrels..
#+config_nginx+ is to genrate nginx config files and upload it onto server via rsync
#+start_web+ is use to start nginx server.
#+stop_web+: stop nginx web server..
#+restart_web+: restart(stop && start)nginx web server...

 
require 'vlad'

namespace :vlad do
 
  #  VLAD_ROOT = File.dirname(__FILE__) + '/../../'
 
  # Nginx app server
  set :nginx_sites_available, "/etc/nginx/sites-available"
  set :nginx_sites_enabled, "/etc/nginx/sites-enabled"
  set :nginx_command, ' /etc/init.d/nginx'
  
  def sudo(command)
    run [sudo_cmd, sudo_flags, command].join(' ')
  end
 
  # Nginx web server on Gentoo/Debian init.d systems

 
  # iceskysl@IceskYsl:/opt/dev/1stlog$ rake vlad:start_web --trace
  #(in /opt/dev/1stlog)
  #** Invoke vlad:start_web (first_time)
  #** Execute vlad:start_web
  #cmd=ssh -p 22 1stlog.1sters.com sudo   /etc/init.d/nginx start
  #taojer@1stlog.xxxx.com's password: 
  #Starting nginx: nginx.
  
  desc "Start the web servers"
  remote_task :start_web, :roles => :web  do
    sudo  "#{nginx_command} start"
  end

 

  #iceskysl@IceskYsl:/opt/dev/1stlog$ rake vlad:stop_web --trace
  #(in /opt/dev/1stlog)
  #** Invoke vlad:stop_web (first_time)
  #** Execute vlad:stop_web
  #cmd=ssh -p 22 1stlog.xxxx.com sudo    /etc/init.d/nginx stop
  #taojer@1stlog.1sters.com's password: 
  #Stopping nginx: nginx.
  desc "Stop the web servers"

  remote_task :stop_web, :roles => :web  do
    sudo " #{nginx_command} stop"
  end

  
  
  desc "ReStart the web servers"
  remote_task :restart_web, :roles => :web  do
    Rake::Task['vlad:stop_web'].invoke
    Rake::Task['vlad:start_web'].invoke
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
 
  
  desc "Config Nginx servers with mogrels,and generate nginx config file ,then upload to server.."
  remote_task :config_nginx, :roles => :app do
    puts "VLAD_ROOT=#{VLAD_ROOT}"
    nginx_config ="#{VLAD_ROOT+'conf/nginx.template.erb'}"
    app_config = shared_path+'/config/'+application 
    # run the template  
    run_template(nginx_config,app_config)
    #move the config in to sites-available
    sudo "cp #{app_config} #{nginx_sites_available}/#{application}" 
    #add a symlink into sites enabled 
    sudo "ln -s -f #{nginx_sites_available}/#{application}  #{nginx_sites_enabled}/#{application}" 
  end
 
  
  #
  # Get the template from the server,
  # parse it, and place the new file back on the server
  # 
  def run_template(nginx_config_file,app_config)
    require 'tempfile'
    puts "nginx_config_file=#{nginx_config_file}"
    require 'erb'  #render not available in Capistrano 2
    #    get(remote_file_to_get,"template.tmp")      # get the remote file
    template =File.read(nginx_config_file)          # read it
    #    puts "nginx_config_file template=#{template}"
    buffer = ERB.new(template).result(binding)   # parse it
    #put it to server
    put app_config, application do
      buffer
    end
  end 
  
  #Not used now,but it could be use future via ssh&&sftp to upload files.
  def put_file_to_remote()
    require 'net/ssh'
    require 'net/sftp'
    Net::SSH.start(domain, user) do |ssh|
      ssh.sftp.connect do |sftp|
        Dir.foreach('.') do |file|
          puts file
        end
      end
    end
  end

  
 
end
 

 
