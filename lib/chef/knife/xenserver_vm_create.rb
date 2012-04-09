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
require 'singleton'

class Chef
  class Knife
    class XenserverVmCreate < Knife

      include Knife::XenserverBase

      deps do
        require 'readline'
        require 'alchemist'
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife xenserver vm create (options)"

      option :vm_template,
        :long => "--vm-template NAME",
        :description => "The Virtual Machine Template to use"
      
      option :vm_name,
        :long => "--vm-name NAME",
        :description => "The Virtual Machine name"
      
      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The Chef node name for your new node"

      option :bootstrap_version,
        :long => "--bootstrap-version VERSION",
        :description => "The version of Chef to install",
        :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_version] = v }

      option :distro,
        :short => "-d DISTRO",
        :long => "--distro DISTRO",
        :description => "Bootstrap a distro using a template; default is 'ubuntu10.04-gems'",
        :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
        :default => "ubuntu10.04-gems"

      option :template_file,
        :long => "--template-file TEMPLATE",
        :description => "Full path to location of template to use",
        :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
        :default => false

      option :run_list,
        :short => "-r RUN_LIST",
        :long => "--run-list RUN_LIST",
        :description => "Comma separated list of roles/recipes to apply",
        :proc => lambda { |o| o.split(/[\s,]+/) },
        :default => []

      option :ssh_user,
        :short => "-x USERNAME",
        :long => "--ssh-user USERNAME",
        :description => "The ssh username; default is 'root'",
        :default => "root"
      
      option :ssh_password,
        :short => "-P PASSWORD",
        :long => "--ssh-password PASSWORD",
        :description => "The ssh password"

      option :identity_file,
        :short => "-i IDENTITY_FILE",
        :long => "--identity-file IDENTITY_FILE",
        :description => "The SSH identity file used for authentication"
      
      option :no_host_key_verify,
        :long => "--no-host-key-verify",
        :description => "Disable host key verification",
        :boolean => true,
        :default => false,
        :proc => Proc.new { true }
      
      option :skip_bootstrap,
        :long => "--skip-bootstrap",
        :description => "Skip bootstrap process (Deploy only mode)",
        :boolean => true,
        :default => false,
        :proc => Proc.new { true }
      
      option :keep_template_networks,
        :long => "--keep-template-networks",
        :description => "Do no remove template inherited networks (VIFs)",
        :boolean => true,
        :default => false,
        :proc => Proc.new { true }
      
      option :batch,
        :long => "--batch script.yml",
        :description => "Use a batch file to deploy multiple VMs",
        :default => nil
      
      option :vm_networks,
        :short => "-N network[,network..]",
        :long => "--vm-networks",
        :description => "Network where nic is attached to"

      option :mac_addresses,
        :short => "-M mac[,mac..]",
        :long => "--mac-addresses",
        :description => "Mac address list",
        :default => nil

      def tcp_test_ssh(hostname)
        tcp_socket = TCPSocket.new(hostname, 22)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
          yield
          true
        else
          false
        end
      rescue Errno::ETIMEDOUT, Errno::EPERM
        false
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH
        sleep 2
        false
      ensure
        tcp_socket && tcp_socket.close
      end

      def run
        $stdout.sync = true

        unless config[:vm_template]
          ui.error("You have not provided a valid template name. (--vm-template)")
          exit 1
        end
        
        vm_name = config[:vm_name]
        if not vm_name
          ui.error("Invalid Virtual Machine name (--vm-name)")
          exit 1
        end

        template = connection.servers.templates.find do |s| 
          (s.name == config[:vm_template]) or (s.uuid == config[:vm_template])
        end

        if template.nil?
          ui.error "Template #{config[:vm_template]} not found."
          exit 1
        end

        puts "#{ui.color("Creating VM #{config[:vm_name]}... ", :magenta)}"
        puts "#{ui.color("Using template #{template.name} [uuid: #{template.uuid}]... ", :magenta)}"
        
        vm = connection.servers.new :name => config[:vm_name],
                                    :template_name => config[:vm_template]
        vm.save :auto_start => false
        if not config[:keep_template_networks]
        vm.vifs.each do |vif|
          vif.destroy
        end 
        end
        if config[:vm_networks]
          create_nics(config[:vm_networks], config[:mac_addresses], vm)
        end
        vm.start
        vm.reload

        puts "#{ui.color("VM Name", :cyan)}: #{vm.name}"
        puts "#{ui.color("VM Memory", :cyan)}: #{vm.memory_static_max.to_i.bytes.to.megabytes.round} MB"

        if !config[:skip_bootstrap]
          # wait for it to be ready to do stuff
          print "\n#{ui.color("Waiting server... ", :magenta)}"
          timeout = 180
          found = connection.servers.all.find { |v| v.name == vm.name }
          servers = connection.servers
          loop do 
            begin
              vm.refresh
              if not vm.guest_metrics.nil? and not vm.guest_metrics.networks.empty?
                networks = []
                vm.guest_metrics.networks.each do |k,v|
                  networks << v
                end
                networks = networks.join(",")
                puts
                puts "\n#{ui.color("Server IPs:", :cyan)} #{networks}"
                break
              end
            rescue Fog::Errors::Error
              print "\r#{ui.color('Waiting a valid IP', :magenta)}..." + "." * (100 - timeout)
            end
            sleep 1
            timeout -= 1
            if timeout == 0
              puts
              ui.error "Timeout trying to reach the VM. Couldn't find the IP address."
              exit 1
            end
          end
          print "\n#{ui.color("Waiting for sshd... ", :magenta)}"
          vm.guest_metrics.networks.each do |k,v|
            print "\n#{ui.color("Trying to SSH to #{v}... ", :yellow)}"
            print(".") until tcp_test_ssh(v) do
              sleep @initial_sleep_delay ||= 10; puts(" done") 
              @ssh_ip = v
            end
            break if @ssh_ip
          end

          bootstrap_for_node(vm).run 
          puts "\n"
          puts "#{ui.color("Name", :cyan)}: #{vm.name}"
          puts "#{ui.color("IP Address", :cyan)}: #{@ssh_ip}"
          puts "#{ui.color("Environment", :cyan)}: #{config[:environment] || '_default'}"
          puts "#{ui.color("Run List", :cyan)}: #{config[:run_list].join(', ')}"
          puts "#{ui.color("Done!", :green)}"
        else
          ui.warn "Skipping bootstrapping as requested."
        end

      end

      def bootstrap_for_node(vm)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = [@ssh_ip]
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:ssh_user] = config[:ssh_user] 
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:chef_node_name] = config[:chef_node_name] || vm.name
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:distro] = locate_config_value(:distro)
        # bootstrap will run as root...sudo (by default) also messes up Ohai on CentOS boxes
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        bootstrap.config[:template_file] = locate_config_value(:template_file)
        bootstrap.config[:environment] = config[:environment]
        bootstrap.config[:no_host_key_verify] = config[:no_host_key_verify]
        bootstrap.config[:ssh_password] = config[:ssh_password]
        bootstrap
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
