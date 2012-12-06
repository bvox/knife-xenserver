#
# Author:: Sergio Rubio (<rubiojr@bvox.net>)
# Copyright:: Copyright (c) 2012 BVox S.L.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/xenserver_base'
require 'net/scp'
require 'uuidtools'

class Chef
  class Knife
    class XenserverTemplateCreate < Knife

      include Knife::XenserverBase

      banner "knife xenserver template create"

      option :hvm,
        :long => "--hvm",
        :description => "Use HVM (default is PV)",
        :boolean => false,
        :proc => Proc.new { true }
      
      option :vm_name,
        :long => "--vm-name NAME",
        :description => "The template name"
      
      option :vm_tags,
        :long => "--vm-tags tag1[,tag2..]",
        :description => "Comma separated list of tags"
      
      option :vm_disk,
        :long => "--vm-disk DISK",
        :description => "The disk file to use"
      
      option :vm_template,
        :long => "--vm-template NAME",
        :description => "The Virtual Machine to clone (TODO)"
      
      option :vm_memory,
        :long => "--vm-memory AMOUNT",
        :description => "The memory limits of the Virtual Machine",
        :default => '512'
      
      option :storage_repository,
        :long => "--storage-repository SR",
        :description => "The storage repository to use",
        :default => 'Local storage'
      
      option :vm_networks,
        :short => "-N network[,network..]",
        :long => "--vm-networks",
        :description => "Network where nic is attached to"

      option :mac_addresses,
        :short => "-M mac[,mac..]",
        :long => "--mac-addresses",
        :description => "Mac address list",
        :default => nil
      
      def run
        source = config[:vm_disk]
        vm_name = config[:vm_name]
        host = config[:xenserver_host] || Chef::Config[:knife][:xenserver_host]
        user = config[:xenserver_username] || Chef::Config[:knife][:xenserver_username]
        password = config[:xenserver_password] || Chef::Config[:knife][:xenserver_password]
        if host.nil?
          ui.error "Invalid Xen host. Use #{'--xenserver-host'.red.bold} argument."
          exit 1
        end
        if user.nil?
          ui.error "Invalid Xen username. Use #{'--xenserver-username'.red.bold} argument."
          exit 1
        end
        if password.nil?
          ui.error "Invalid Xen password. Use #{'--xenserver-password'.red.bold} argument."
          exit 1
        end
        
        if vm_name.nil?
          ui.error "Invalid name for the template. Use #{'--vm-name'.red.bold} argument."
          exit 1
        end

        if source.nil? or not File.exist?(source)
          ui.error "Invalid source disk #{(source || '').bold}."
          ui.error "#{'--vm-disk'.red.bold} argument is mandatory" \
            if source.nil?
          exit 1
        end
        if source !~ /\.vhd$/
          ui.error "Invalid source disk #{source.red.bold}. I need a VHD file."
          exit 1
        end
        
        # Create the VM but do not start/provision it
        if config[:hvm]
          ui.info "HVM".yellow + " template selected"
          pv_bootloader = 'eliloader'
          hvm_boot_policy = 'BIOS order'
          pv_args = ''
        else
          ui.info "PV".yellow + " template selected"
          pv_bootloader = 'pygrub'
          hvm_boot_policy = ''
          pv_args = '-- console=hvc0'
        end

        ui.info "Creating VM #{vm_name.yellow} on #{host.yellow}..."
        
        # We will create the VDI in this SR
        sr = connection.storage_repositories.find { |sr| sr.name == config[:storage_repository] }
        # Upload and replace the VDI with our template
        uuid = UUIDTools::UUID.random_create.to_s
        dest = "/var/run/sr-mount/#{sr.uuid}/#{uuid}.vhd"
        Net::SSH.start(host, user, :password => password) do |ssh|
          puts "Uploading file #{File.basename(source).yellow}..." 
          puts "Destination SR #{sr.name.yellow}"
          ssh.scp.upload!(source, dest) do |ch, name, sent, total|
            p = (sent.to_f * 100 / total.to_f).to_i.to_s
            print "\rProgress: #{p.yellow.bold}% completed"
          end
        end
        
        sr.scan
        # Create a ~8GB VDI in storage repository 'Local Storage'
        #vdi = connection.vdis.create :name => "#{vm_name}-disk1", 
        #                       :storage_repository => sr,
        #                       :description => "#{vm_name}-disk1",
        #                       :virtual_size => '8589934592' # ~8GB in bytes

        vdi = nil
        sr.vdis.each do |v| 
          if v.uuid == uuid
            v.set_attribute 'name_label', "#{vm_name}-template"
            vdi = v
            break
          end
        end
        
        mem = (config[:vm_memory].to_i * 1024 * 1024).to_s
        vm = connection.servers.new :name => "#{vm_name}",
                              :affinity => connection.hosts.first,
                              :other_config => {},
                              :pv_bootloader => pv_bootloader,
                              :hvm_boot_policy => hvm_boot_policy,
                              :pv_args => pv_args,
                              :memory_static_max => mem,
                              :memory_static_min => mem,
                              :memory_dynamic_max => mem,
                              :memory_dynamic_min => mem
        vm.save
        if config[:vm_tags]
          vm.set_attribute 'tags', config[:vm_tags].split(',')
        end

        if config[:vm_networks]
          create_nics(config[:vm_networks], config[:mac_addresses], vm)
        end
        # Add the required VBD to the VM 
        connection.vbds.create :server => vm, :vdi => vdi
        puts "\nDone."
        
      end
      
      def create_nics(networks, macs, vm)
        net_arr = networks.split(/,/).map { |x| { :network => x } }
        nics = []
        if macs
          mac_arr = macs.split(/,/)
          nics = net_arr.each_index { |x| net_arr[x][:mac_address] = mac_arr[x] if mac_arr[x] and !mac_arr[x].empty? }
        else
          nics = net_arr
        end
        networks = connection.networks
        highest_device = 0
        vm.vifs.each { |vif| highest_device = vif.device.to_i if vif.device.to_i > highest_device }
        nic_count = 0
        nics.each do |n|
          net = networks.find { |net| net.name == n[:network] }
          if net.nil?
            ui.error "Network #{n[:network]} not found"
            exit 1
          end
          nic_count += 1
          c = {
           'MAC_autogenerated' => n[:mac_address].nil? ? 'True':'False',
           'VM' => vm.reference,
           'network' => net.reference,
           'MAC' => n[:mac_address] || '',
           'device' => (highest_device + nic_count).to_s,
           'MTU' => '0',
           'other_config' => {},
           'qos_algorithm_type' => 'ratelimit',
           'qos_algorithm_params' => {}
          }
          connection.create_vif_custom c
        end
      end

    end
  end
end
