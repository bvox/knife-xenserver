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

      def run
        $stdout.sync = true
        vm_table = table do |t|
          t.headings = %w{NAME MEM POWER TOOLS NETWORKS IPs}
          connection.servers.each do |vm|
            if vm.tools_installed?
              ips = []
              vm.guest_metrics.networks.each do |k,v|
                ips << v
              end
              ips = ips.join(",\n")
            else
              ips = "unknown"
            end
            networks = []
            vm.vifs.each do |vif|
              name = vif.network.name
              if name.size > 20
                name = name[0..16] + '...'
              end
              networks << name
            end
            networks = networks.join(",\n")
            mem = vm.memory_static_max.to_i.bytes.to.megabytes.round
            t << ["#{vm.uuid}\n#{ui.color('name: ', :yellow)}#{vm.name.ljust(32)}", mem, vm.power_state, vm.tools_installed?, networks,ips]
          end
        end
        puts vm_table if connection.servers.size > 0
      end
    end
  end
end
