actions :uninstall, :install
default_action :install

property :name, String, name_property: true
property :user, String, default: 'bootapp'
property :group, String, default: 'bootapp'
property :port, Integer, default: 8080
property :jar_remote_path, String
