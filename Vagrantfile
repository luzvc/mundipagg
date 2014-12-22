# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :private_network, ip: "10.11.12.13"
  config.ssh.forward_agent = true
  config.vm.synced_folder ".", "/vagrant", nfs: true
  config.vm.boot_timeout = 120

  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true

  config.vm.provider "virtualbox" do |v|
    host = RbConfig::CONFIG['host_os']
    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 2
    else
      cpus = `nproc`.to_i
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 2
    end

    v.customize ["modifyvm", :id, "--memory", mem]
    v.customize ["modifyvm", :id, "--cpus", cpus]
  end

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "docker"

    chef.json = {
      "docker" => {
        "group_members" => ["vagrant"],
        "image_cmd_timeout" => 3600
      }
    }
  end
end
