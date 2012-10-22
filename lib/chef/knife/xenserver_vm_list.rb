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

class Chef
  class Knife
    class XenserverVmList < Knife

      include Knife::XenserverBase
      
      banner "knife xenserver vm list (options)"
      
      option :csv,
        :long => "--csv",
        :description => "Comma separated list of VMs",
        :boolean => true,
        :default => false
      
      option :uuid,
        :long => "--[no-]uuid",
        :description => "Print/Hide VM UUID",
        :boolean => true,
        :default => true
      
      option :tools,
        :long => "--[no-]tools",
        :description => "Print/Hide XenTools Availability",
        :boolean => true,
        :default => true
      
      option :networks,
        :long => "--[no-]networks",
        :description => "Print/Hide VM Networks",
        :boolean => true,
        :default => true
      
      option :mem,
        :long => "--[no-]mem",
        :description => "Print/Hide VM Memory",
        :boolean => true,
        :default => true

      option :ips,
        :long => "--[no-]ips",
        :description => "Print/Hide VM IPs",
        :boolean => true,
        :default => true
      
      option :power_state,
        :long => "--[no-]power-state",
        :description => "Print/Hide VM Power State",
        :boolean => true,
        :default => true

      def gen_headings
        headings = %w{NAME}
        if config[:mem]
          headings << 'MEM'
        end
        if config[:power_state]
          headings << 'POWER'
        end
        if config[:tools]
          headings << 'TOOLS'
        end
        if config[:networks]
          headings << 'NETWORKS'
        end
        if config[:ips]
          headings << 'IPs'
        end
        headings
      end

      def gen_table
        # row format
        # [uuid, name, [ips], [networks], mem, power, tools]
        table = []
        connection.servers.each do |vm|
          row = [vm.uuid, vm.name] 
          if vm.tools_installed?
            ips = []
            vm.guest_metrics.networks.each do |k,v|
              ips << v
            end
            row << ips
          else
            row << []
          end
          networks = []
          vm.vifs.each do |vif|
            name = vif.network.name
            if name.size > 20
              name = name[0..16] + '...'
            end
            networks << name
          end
          row << networks
          row << vm.memory_static_max.to_i.bytes.to.megabytes.round
          row << vm.power_state
          row << vm.tools_installed?
          table << row
        end
        table
      end

      def print_table
        vm_table = table do |t|
          t.headings = gen_headings
          gen_table.each do |row|
            # [uuid, name, [ips], [networks], mem, power, tools]
            uuid, name, ips, networks, mem, power, tools = row
            elements = []
            if config[:uuid]
              elements << "#{uuid}\n  #{ui.color('name: ', :yellow)}#{name.ljust(32)}"
            else
              elements << "#{ui.color('name: ', :yellow)}#{name.ljust(32)}"
            end
            elements << mem if config[:mem]
            elements << power if config[:power_state]
            elements << tools if config[:tools]
            elements << networks.join("\n") if config[:networks]
            elements << ips.join("\n") if config[:ips]
            t << elements
          end
        end
        puts vm_table if connection.servers.size > 0
      end

      def print_csv
        lines = []
        header = ""
        gen_table.each do |row|
          uuid, name, ips, networks, mem, power, tools = row
          elements = []
          elements << name
          elements << mem if config[:mem]
          elements << power if config[:power_state]
          elements << tools if config[:tools]
          elements << networks.join(";") if config[:networks]
          elements << ips.join(";") if config[:ips]
          if config[:uuid]
            header = "UUID,#{gen_headings.join(',')}"
            lines << "#{uuid},#{elements.join(',')}"
          else
            header = "#{gen_headings.join(',')}"
            lines << "#{elements.join(',')}"
          end
        end

        puts header
        lines.each do |l| 
          puts l
        end
      end

      def run
        $stdout.sync = true
        if config[:csv]
          print_csv
        else
          print_table
        end
      end

    end
  end
end
