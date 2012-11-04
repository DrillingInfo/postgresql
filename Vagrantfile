# vim:ft=ruby:ts=2:sw=2

require 'berkshelf/vagrant'

ubuntu_runlist = [
  "recipe[apt]",
  "recipe[postgresql::server]",
  "recipe[postgresql::sysctl]"
]

redhat_runlist = [
  "recipe[postgresql::server]",
]

all_boxes = {
  'ubuntu-10-04' =>  {
    :url => "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-10.04.box",
    :runlist => ubuntu_runlist
  },
  'ubuntu-12-04' => {
    :url => "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box",
    :runlist => ubuntu_runlist
  },
  'centos-5-8' => {
    :url => "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-5.8.box",
    :runlist => redhat_runlist
  },
  'centos-6-3' => {
    :url => "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-6.3.box",
    :runlist => redhat_runlist
  },
}

Vagrant::Config.run do |config|
  all_boxes.each do | box, details |
    config.vm.define box.to_sym do | box_config |
      box_config.vm.box = box
      box_config.vm.box_url = details[:url]

      box_config.ssh.max_tries = 40
      box_config.ssh.timeout   = 120

      box_config.vm.provision :chef_solo do |chef|    
        chef.log_level = :debug
        chef.json = {
          :postgresql => {
            :ssl => 'off'
          }
        }
        chef.run_list = details[:runlist]
      end
    end
  end
end
