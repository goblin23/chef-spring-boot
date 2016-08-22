use_inline_resources

action :install do

  if new_resource.jar_remote_path.to_s.empty?
    Chef::Application.fatal!('jar_remote_path may not be empty', 1)
  end

  jar_directory = "/opt/spring-boot/#{new_resource.name}"
  jar_path = jar_directory + '/' + new_resource.name + '.jar'
  logging_directory = jar_directory + '/logs'

  user new_resource.user

  group new_resource.group do
    append true
    members [new_resource.user]
  end

  directory jar_directory do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    action :create
    recursive true
  end

  directory logging_directory do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    action :create
    recursive true
  end

  bootapp_remote_file = remote_file jar_path do
    source new_resource.jar_remote_path
    owner new_resource.user
    group new_resource.group
    mode '0755'
    action :create
  end

  bootapp_service_template = template "/etc/systemd/system/#{new_resource.name}.service" do
    source 'bootapp.service.erb'
    mode '0755'
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
  end

  service new_resource.name do
    action :enable
  end

  execute '/usr/bin/systemctl daemon-reload' do
    only_if { bootapp_service_template.updated_by_last_action? }
  end

  service new_resource.name do
    action :restart
    only_if { bootapp_service_template.updated_by_last_action? || bootapp_remote_file.updated_by_last_action? }
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

  file "/etc/systemd/system/#{new_resource.name}.service" do
    action :delete
  end

  directory "/opt/spring-boot/#{new_resource.name}" do
    recursive true
    action :delete
  end

end
