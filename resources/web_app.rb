actions :uninstall, :install
default_action :install

property :name, String, name_property: true
property :user, String, default: 'bootapp'
property :group, String, default: 'bootapp'
property :port, Integer, default: 8080
property :jar_remote_path, String

property :wait_for_http, [TrueClass, FalseClass], default: true
property :wait_for_http_retries, Integer, default: 12
property :wait_for_http_retry_delay, Integer, default: 5
