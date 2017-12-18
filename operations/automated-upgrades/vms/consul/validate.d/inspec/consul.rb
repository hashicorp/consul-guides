describe file("/usr/local/bin/consul") do
  it { should exist }
end

describe file('/etc/hashicorp/consul/consul.hcl') do
  it { should exist }
end

describe processes('consul') do
  it { should exist }
end

ipaddress = %x(facter ipaddress_enp0s8).chomp

describe http("http://#{ipaddress}:8500/v1/status/leader") do
  its('status') { should cmp 200 }
  its('body') { should match /.+\:8300.*/ }
end

#describe command("http get http://#{ipaddress}:8500/v1/status/leader") do
#  its('stdout') { should match /.+\:8300.*/ }
#end

describe http("http://#{ipaddress}:8500/v1/status/peers") do
  its('status') { should cmp 200 }
  its('body') { should match /.+\:8300.*/ }
end

#describe command("http get http://#{ipaddress}:8500/v1/status/peers") do
#  its('stdout') { should match /.+\:8300.*/ }
#end
