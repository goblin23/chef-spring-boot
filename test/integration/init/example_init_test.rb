describe sysv_service('app_0_initd') do
  it { should_not be_enabled }
end

describe sysv_service('app_1_initd') do
  it { should be_enabled }
end

describe sysv_service('app_2_initd') do
  it { should be_enabled }
end

describe port(9080) do
  it { should_not be_listening }
end

describe port(9091) do
  it { should be_listening }
end

describe port(9991) do
  it { should be_listening }
end

describe port(9092) do
  before do
    sleep(5)
  end
  it { should be_listening }
end

describe user('another_bootapp_user') do
  its('shell') { should eq '/bin/sh' }
end

describe file('/opt/spring-boot/app_1_initd/app_1_initd.jar') do
  it { should be_owned_by  'another_bootapp_user' }
  it { should be_grouped_into 'another_bootapp_group' }
  its('mode') { should cmp '0500' }
end

describe file('/opt/spring-boot/app_1_initd/app_1_initd.conf') do
  it { should be_owned_by  'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should cmp '0400' }
end

describe file('/opt/spring-boot/app_1_initd/jmxremote.access') do
  it { should be_owned_by  'another_bootapp_user' }
  it { should be_grouped_into 'another_bootapp_group' }
  its('mode') { should cmp '0400' }
end

describe file('/opt/spring-boot/app_1_initd/jmxremote.password') do
  it { should be_owned_by  'another_bootapp_user' }
  it { should be_grouped_into 'another_bootapp_group' }
  its('mode') { should cmp '0400' }
end

describe file('/opt/spring-boot/app_0_initd') do
  it { should_not exist }
end

describe file('/opt/spring-boot/app_1_initd/logs/spring.log') do
  it { should exist }
end

describe file('/opt/spring-boot/app_2_initd/logs/spring.log') do
  it { should exist }
end
