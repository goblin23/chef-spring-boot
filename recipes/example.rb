web_app_jar = 'file:///' + Chef::Config[:file_cache_path] + '/cookbooks/spring-boot/files/spring-boot-hello-world.jar'

spring_boot_web_app 'app_0' do
	jar_remote_path web_app_jar
end

spring_boot_web_app 'app_1' do
	jar_remote_path web_app_jar
	user 'another_bootapp_user'
	group 'another_bootapp_group'
	port 8091
	
	wait_for_http true
	wait_for_http_retries 30
	wait_for_http_retry_delay 2
end

spring_boot_web_app 'app_0' do
	action :uninstall
end

spring_boot_web_app 'no-such-app' do
	action :uninstall
end