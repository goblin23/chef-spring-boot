web_app_jar = 'https://github.com/EtienneK/spring-boot-web-sample/raw/master/dist/spring-boot-web-sample-0.0.1-SNAPSHOT.jar'

######################## systemd ########################

spring_boot_web_app 'app_0' do
  jar_remote_path web_app_jar
end

spring_boot_web_app 'app_1' do
  jar_remote_path web_app_jar
  user 'another_bootapp_user'
  group 'another_bootapp_group'
  port 8091

  java_opts '-Xmx256m -Xms128m'
  boot_opts '--spring.application.name=app_1'

  wait_for_http true
  wait_for_http_retries 60
  wait_for_http_retry_delay 2
end

spring_boot_web_app 'app_2' do
  jar_remote_path web_app_jar
  port 8092
  
  java_opts '-Xmx256m -Xms128m'
  boot_opts '--spring.application.name=app_2'
end

spring_boot_web_app 'app_0' do
  action :uninstall
end

spring_boot_web_app 'no-such-app' do
  action :uninstall
end
