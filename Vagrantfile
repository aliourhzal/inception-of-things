# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end

  config.vm.define "aourhzalS" do |aourhzalS|
    aourhzalS.vm.hostname = "aourhzalS"
    aourhzalS.vm.network "private_network", ip: "192.168.56.110"
    aourhzalS.vm.provider "virtualbox" do |v|
      v.name = "aourhzalS"
    end
    aourhzalS.vm.provision "shell", inline: <<-SHELL
      sudo apt update
      sudo apt install curl -y
      curl -sfL https://get.k3s.io | sh - &&
      sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token
    SHELL
  end

  config.vm.define "aourhzalSW" do |aourhzalSW|
    aourhzalSW.vm.hostname = "aourhzalSW"
    aourhzalSW.vm.network "private_network", ip: "192.168.56.111"
    aourhzalSW.vm.provider "virtualbox" do |v|
      v.name = "aourhzalSW"
    end
    aourhzalSW.vm.provision "shell", inline: <<-SHELL
      sudo apt update
      sudo apt install curl -y
      curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$(cat /vagrant/node-token) sh -
      # rm -rf /vagrant/node-token
    SHELL
  end

end
