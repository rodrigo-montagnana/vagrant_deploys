# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  config.vm.define "kvm" do |kvm|
    kvm.vm.box = "centos8Stream"
	kvm.vm.network "public_network", ip: "192.168.15.40", nic_type: "82540EM", bridge: "Intel(R) Dual Band Wireless-AC 3165"
    kvm.vm.synced_folder ".", "/vagrant", disabled: true
    kvm.ssh.private_key_path = "etc/id_rsa"
    kvm.ssh.dsa_authentication = false
	kvm.vm.provider :virtualbox do |v|
	   v.customize ["modifyvm", :id, "--memory", 6144]
	   v.customize ["modifyvm", :id, "--vrde", "off"]
	   v.customize ["modifyvm", :id, "--paravirt-provider", "kvm"]
	   v.name = "kvmhost"
	   controller_name = 'SATA Controller'
	   disk_name = "data.vmdk"
       if(!File.exists?(disk_name))
          v.customize [ "createmedium", "disk", "--filename", disk_name, "--format", "VMDK", "--size", 40960 ]
          #v.customize [ "storagectl", :id, "--name", controller_name, "--add", "sata" ]
          v.customize [ "storageattach", :id, "--storagectl", controller_name, "--port", "1", "--device", "0", "--type", "hdd", "--medium", disk_name ]
       end
	end
	config.vm.provision "shell", path: "scripts/firstboot.bash"
  end
end
