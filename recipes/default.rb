#
# Cookbook Name:: spring-boot-app
# Recipe:: default
#
# Copyright (c) 2016 Etienne Koekemoer, All Rights Reserved.

include_recipe 'java'

spring_boot_web_app 'hello-world' do
	jar_remote_path 'file:///' + Chef::Config[:file_cache_path] + '/cookbooks/spring-boot/files/spring-boot-hello-world.jar'
	port 8090
end

spring_boot_web_app 'hello-world' do
	action :uninstall
end

spring_boot_web_app 'no-such-app' do
	action :uninstall
end