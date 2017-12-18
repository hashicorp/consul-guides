# coding: utf-8
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

ENV['VAGRANT_NO_COLOR'] = 'true'

# Provisions a set of Consul Server nodes with differing node metadata. The node
# metadata is used to coordinate a safe (leader + quorum) rolling upgrade
# of the Consul cluster. This is a feature of Consul Enterprise.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  %w(consula0 consula1 consula2 consulb0 consulb1 consulb2).each do |nodename|
    
    config.vm.define "#{nodename}", autostart: true do |thisnode|
      thisnode.vm.box = "ubuntu/xenial64"
      thisnode.vm.provider "virtualbox" do |vb|
        vb.memory = "512"
      end

      thisnode.vm.hostname = "#{nodename}"
      thisnode.vm.network :private_network, :auto_network => true
      thisnode.vm.provision :hosts, :autoconfigure => true, :sync_hosts => true

      if "#{nodename}".include? "consula0" then
        thisnode.vm.network "forwarded_port", guest: 8500, host: 8500 # Consul UI for consula0
      end

      if "#{nodename}".include? "consulb0" then
        thisnode.vm.network "forwarded_port", guest: 8500, host: 8501 # Consul UI for consulb0
      end

      thisnode.vm.provision "install"  , type: "shell", keep_color: false, run: "once",  path: "vms/consul/install.sh"
      thisnode.vm.provision "configure", type: "shell", keep_color: false, run: "never", path: "vms/consul/configure.sh"
      thisnode.vm.provision "validate" , type: "shell", keep_color: false, run: "never", path: "vms/consul/validate.sh"
    end
  end
end
