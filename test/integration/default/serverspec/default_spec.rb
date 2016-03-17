require 'spec_helper'

describe service('app_0') do
  it { should_not be_enabled }
  it { should_not be_running.under('systemd') }
end

describe service('app_1') do
  it { should be_enabled }
  it { should be_running.under('systemd') }
end

describe service('app_2') do
  it { should be_enabled }
  it { should be_running.under('systemd') }
end

describe port(8080) do
  it { should_not be_listening }
end

describe port(8091) do
  it { should be_listening }
end

describe port(8092) do
  it { should be_listening }
end

describe user('bootapp') do
  it { should exist }
  it { should belong_to_group 'bootapp' }
end

describe user('another_bootapp_user') do
  it { should exist }
  it { should belong_to_group 'another_bootapp_group' }
end

describe file('/opt/spring-boot/app_0') do
  it { should_not exist }
end

describe file('/opt/spring-boot/app_1/logs/spring.log') do
  it { should exist }
end

describe file('/opt/spring-boot/app_2/logs/spring.log') do
  it { should exist }
end
