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

class Chef
  class Knife
    class XenserverSrList < Knife

      include Knife::XenserverBase

      banner "knife xenserver sr list (options)"
      
      option :sr_type,
        :long => "--sr-types",
        :description => "List only the types specified (comma separated types)",
        :default => 'ext,lvm'
      
      option :numeric_utilisation,
        :long => "--[no-]numeric-utilisation",
        :description => "Print SR utilisation in bytes",
        :default => false,
        :boolean => true

      def run
        # Finding the current host (the one we used to get the connection)
        #xshost = config[:xenserver_host] || Chef::Config[:knife][:xenserver_host]
        #address = Resolv.getaddress xshost
        #host = connection.hosts.find { |h| h.address == address }

        # Storage Repositories belong to the pool,
        # There's no way to list host storage repositories AFAIK
        repositories = connection.storage_repositories
        table = table do |t|
          t.headings = %w{NAME TYPE UTILISATION UUID}
          valid_types = config[:sr_type].split(',').map { |t| t.strip }
          repositories.each do |sr|
            # we only list LVM and EXT repositories by default
            next unless valid_types.include? sr.type
            if config[:numeric_utilisation]
              utilisation = sr.physical_utilisation
            else
              if sr.physical_size.to_i > 0
                utilisation = (sr.physical_utilisation.to_i * 100)/sr.physical_size.to_f * 100
                utilisation = "%.2f%" % utilisation
              else
                utilisation = "100%"
              end
            end
            t << [sr.name, sr.type, utilisation, sr.uuid]
          end
        end
        puts table if !repositories.empty?
      end

    end
  end
end
