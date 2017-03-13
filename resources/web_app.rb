resource_name :spring_boot_web_app
actions :uninstall, :install
default_action :install

property :name, kind_of: String
property :user, kind_of: String, default: 'bootapp'
property :group, kind_of: String, default: 'bootapp'
property :port, kind_of: Integer, default: 8080
property :jar_remote_path, kind_of: String, required: true
property :java_opts, kind_of: String, default: ''
property :boot_opts, kind_of: String, default: ''
property :properties, kind_of: Hash
property :repo_user, kind_of: String
property :repo_password, kind_of: String

property :init_system, kind_of: String, default: 'systemd'

property :wait_for_http, kind_of: [TrueClass, FalseClass], default: true
property :wait_for_http_retries, kind_of: Integer, default: 24
property :wait_for_http_retry_delay, kind_of: Integer, default: 5

action :install do
  #  require "pry"; binding.pry
  jar_directory = "/opt/spring-boot/#{new_resource.name}"
  jar_path = jar_directory + '/' + new_resource.name + '.jar'
  logging_directory = jar_directory + '/logs'
  unless repo_user.nil? or repo_password.nil?
    basic_auth = "#{repo_user}:#{repo_password}"
  end
  declare_resource(:user, new_resource.user, caller[0]) do
    shell '/usr/sbin/nologin'
  end

  declare_resource(:group, new_resource.group, caller[0]) do
    append true
    members [new_resource.user]
  end

  directory jar_directory do
    owner new_resource.user
    group new_resource.group
    mode '0500'
    action :create
    recursive true
  end

  directory logging_directory do
    owner new_resource.user
    group new_resource.group
    mode '0700'
    action :create
    recursive true
  end

  remote_file jar_path do
    source new_resource.jar_remote_path
    owner new_resource.user
    group new_resource.group
    unless basic_auth.nil?
      headers ({"Authorization"=>"Basic #{ Base64.encode64("#{basic_auth}").strip }"})
    end
    mode '0500'
    action :create
    notifies :restart, "service[#{new_resource.name}]", :delayed
  end

  # TODO: Make JAR immutable and then make it removable in uninstall
  # execute 'Make jar immutable' do
  #   command "chattr +i #{jar_path}"
  #   user 'root'
  # end
  if property_is_set?(:properties)
    properties.each do |key, value|
      file "#{jar_directory}/#{key}.properties" do
        content value.map { |k, v| "#{k}=#{v}" }.join("\n")
      end
    end
  end
  if new_resource.init_system == 'systemd'
    template "/etc/systemd/system/#{new_resource.name}.service" do
      source 'bootapp.service.erb'
      mode '0664'
      owner 'root'
      group 'root'
      cookbook 'spring-boot'
      variables(
        description: new_resource.name,
        user: new_resource.user,
        jar_path: jar_path,
        java_opts: new_resource.java_opts,
        boot_opts: new_resource.boot_opts,
        port: new_resource.port,
        logging_directory: logging_directory
      )
      notifies :restart, "service[#{new_resource.name}]", :delayed
      notifies :run, 'execute[systemctl_daemon_reload]', :immediately
    end

    execute 'systemctl_daemon_reload' do
      command '/usr/bin/systemctl daemon-reload'
      action :nothing
    end

  elsif new_resource.init_system == 'init.d'
    template "#{jar_directory}/#{new_resource.name}.conf" do
      source 'bootapp.conf.erb'
      mode '0400'
      owner 'root'
      group 'root'
      cookbook 'spring-boot'
      variables(
        jar_path: jar_path,
        java_opts: new_resource.java_opts,
        boot_opts: new_resource.boot_opts,
        port: new_resource.port,
        logging_directory: logging_directory
      )
      notifies :restart, "service[#{new_resource.name}]", :delayed
    end

    link "/etc/init.d/#{new_resource.name}" do
      to jar_path
    end
  else
    Chef::Application.fatal!("Invalid init system specified: #{init_system}", 1)
  end

  service new_resource.name do
    action [:enable, :start]
  end

  execute "Ensure #{new_resource.name} web app is started up" do
    command "curl http://127.0.0.1:#{new_resource.port}"
    retries new_resource.wait_for_http_retries
    retry_delay new_resource.wait_for_http_retry_delay
    only_if { new_resource.wait_for_http }
  end
end

action :uninstall do
  service new_resource.name do
    action [:stop, :disable]
  end

  if new_resource.init_system == 'systemd'
    file "/etc/systemd/system/#{new_resource.name}.service" do
      action :delete
      notifies :run, 'execute[systemctl_daemon_reload]', :immediately
    end

    execute 'systemctl_daemon_reload' do
      command '/usr/bin/systemctl daemon-reload'
      action :nothing
    end
  elsif new_resource.init_system == 'init.d'
    link "/etc/init.d/#{new_resource.name}" do
      action :delete
    end
  else
    Chef::Application.fatal!("Invalid init system specified: #{init_system}", 1)
  end

  directory "/opt/spring-boot/#{new_resource.name}" do
    recursive true
    action :delete
    user 'root'
  end
end
