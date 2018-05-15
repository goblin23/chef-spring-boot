resource_name :spring_boot_web_app
default_action :install

property :user, String, default: 'bootapp'
property :group, String, default: 'bootapp'
property :port, Integer, default: 8080
property :jar_remote_path, String, required: true
property :java_opts, String, default: ''
property :boot_opts, String, default: ''
property :properties, Hash
property :repo_user, String
property :repo_password, String
property :jmx_port, Integer
property :jmx_ssl, [TrueClass, FalseClass], default: false
property :jmx_credentials, Hash, default: {
  'monitorRole' => {
    'password' => '',
    'access' => 'readonly',
  },
}
property :init_system, String, default: 'systemd'
property :wait_for_http, [TrueClass, FalseClass], default: true
property :wait_for_http_retries, Integer, default: 24
property :wait_for_http_retry_delay, Integer, default: 5

action :install do
  jar_directory = "/opt/spring-boot/#{new_resource.name}"
  jar_path = jar_directory + '/' + new_resource.name + '.jar'
  logging_directory = jar_directory + '/logs'
  jmx_access_path = jar_directory + '/jmxremote.access'
  jmx_password_path = jar_directory + '/jmxremote.password'
  unless new_resource.repo_user.nil? || new_resource.repo_password.nil?
    basic_auth = "#{new_resource.repo_user}:#{new_resource.repo_password}"
  end
  declare_resource(:user, new_resource.user) do
    shell '/usr/sbin/nologin'
  end

  declare_resource(:group, new_resource.group) do
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

  unless new_resource.jmx_port.nil?
    content_jmx_access = ''
    new_resource.jmx_credentials.each do |username, values|
      content_jmx_access << "#{username} #{values['access']}\n"
    end
    declare_resource(:file, jmx_access_path) do
      content content_jmx_access
      owner new_resource.user
      group new_resource.group
      mode '0400'
    end

    content_jmx_password = ''
    new_resource.jmx_credentials.each do |username, values|
      content_jmx_password << "#{username} #{values['password']}\n"
    end
    declare_resource(:file, jmx_password_path) do
      content content_jmx_password
      owner new_resource.user
      group new_resource.group
      mode '0400'
    end

    new_resource.java_opts << ' -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=' + new_resource.jmx_port.to_s
    new_resource.java_opts << if property_is_set?(:jmx_credentials)
                                " -Dcom.sun.management.jmxremote.password.file=#{jmx_password_path} -Dcom.sun.management.jmxremote.authenticate=true"
                              else
                                ' -Dcom.sun.management.jmxremote.authenticate=false'
                              end
    new_resource.java_opts << ' -Dcom.sun.management.jmxremote.ssl=' + new_resource.jmx_ssl.to_s
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
      headers('Authorization' => "Basic #{Base64.encode64(basic_auth).strip}")
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
    new_resource.properties.each do |key, value|
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
      command 'systemctl daemon-reload'
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
    Chef::Application.fatal!("Invalid init system specified: #{new_resource.init_system}", 1)
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
      command 'systemctl daemon-reload'
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
