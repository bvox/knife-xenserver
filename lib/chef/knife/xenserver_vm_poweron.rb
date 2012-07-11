#
# Author:: Sergio Rubio (<rubiojr@bvox.net>)
# Copyright:: Copyright (c) 2012 Sergio Rubio
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
    class XenserverVmPoweron < Knife

      include Knife::XenserverBase

      banner "knife xenserver vm poweron VM_NAME [VM_NAME] (options)"
      
      def run
        powered_on = []
        connection.servers.each do |vm|
          @name_args.each do |vm_name|
            if (vm_name == vm.name) or (vm_name == vm.uuid)
              vm.start
              powered_on << vm_name
              ui.info("#{'Powered on'.yellow} virtual machine #{vm.name.yellow} [uuid: #{vm.uuid}]")
            end
          end
        end
        @name_args.each do |vm_name|
          ui.warn "Virtual Machine #{vm_name} not found" if not powered_on.include?(vm_name)
        end
      end

    end
  end
end
