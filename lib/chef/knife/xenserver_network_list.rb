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
    class XenserverNetworkList < Knife

      include Knife::XenserverBase

      banner "knife xenserver network list"

      def run
        networks = connection.networks
        table = table do |t|
          t.headings = %w{NETWORK_NAME VIFs PIFs BRIDGE}
          networks.each do |net|
            pifs = net.pifs.map { |p| p.device }
            t << [net.name, net.__vifs.size, pifs.join(","), net.bridge]
          end
        end
        puts table if !networks.empty?
      end

    end
  end
end
