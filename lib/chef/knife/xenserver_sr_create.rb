#
# Author:: Sergio Rubio (<rubiojr@frameos.org>)
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
require 'resolv'

class Chef
  class Knife
    class XenserverSrCreate < Knife

      include Knife::XenserverBase

      banner "knife xenserver sr create (options)"

      option :sr_name,
        :long => "--sr-name NAME",
        :description => "The Storage Repository name"
      
      option :sr_type,
        :long => "--sr-type TYPE",
        :description => "The Storage Repository type (ext|lvm)"
      
      option :sr_device,
        :long => "--sr-device PATH",
        :description => "Block device path in host"
      
      option :sr_host,
        :long => "--sr-host UUID",
        :description => "Host where the Storage Repository will be created"
      
      def run
        sr_name = config[:sr_name]
        if not sr_name
          ui.error("Invalid Storage Repository name (--sr-name)")
          exit 1
        end
        
        sr_type = config[:sr_type]
        if not sr_type
          ui.error("Invalid Storage Repository type (--sr-type)")
          exit 1
        end
        
        sr_device = config[:sr_device]
        if not sr_device
          ui.error("Invalid Storage Repository device (--sr-device)")
          exit 1
        end
        
        hosts = connection.hosts
        sr_host = config[:sr_host]
        if sr_host.nil? and hosts.size > 1
          if not sr_host
            ui.error("More than one host found in the pool.")
            ui.error("--sr-host parameter is mandatory")
            exit 1
          end
        end

        if sr_host
          # Find the host in the pool
          host = connection.hosts.find { |h| h.uuid == sr_host }
        else
          # We only have one hosts
          host = hosts.first
        end

        # The given host was not found in the pool
        if host.nil?
          ui.error "Host #{sr_host} not found in the pool"
          exit 1
        end
        
        dconfig = { :device => sr_device }
        puts "Creating SR #{sr_name.yellow} in host #{host.name} (#{sr_type}, #{sr_device})..."
        vm = connection.storage_repositories.create :name => sr_name,
                                                    :host => host,
                                                    :device_config => dconfig,
                                                    :type => sr_type

      end

    end
  end
end
