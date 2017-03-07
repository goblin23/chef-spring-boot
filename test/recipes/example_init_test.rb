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

describe port(9092) do
  it { should be_listening }
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
