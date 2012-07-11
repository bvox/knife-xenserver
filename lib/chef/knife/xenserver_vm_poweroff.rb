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
    class XenserverVmPoweroff < Knife

      include Knife::XenserverBase

      banner "knife xenserver vm poweroff VM_NAME [VM_NAME] (options)"
      
      option :hard,
        :long => "--hard",
        :description => "Force VM shutdown",
        :boolean => true,
        :default => false,
        :proc => Proc.new { true }

      def run
        powered_off = []
        connection.servers.each do |vm|
          @name_args.each do |vm_name|
            if (vm_name == vm.name) or (vm_name == vm.uuid)
              confirm("Do you really want to #{'poweroff'.bold.red} this virtual machine #{vm.name.bold.red}")
              if config[:hard]
                vm.stop 'hard' 
              else
                vm.stop 'clean'
              end
              powered_off << vm_name
              ui.info("#{'Powered off'.yellow} virtual machine #{vm.name.yellow} [uuid: #{vm.uuid}]")
            end
          end
        end
        @name_args.each do |vm_name|
          ui.warn "Virtual Machine #{vm_name} not found" if not powered_off.include?(vm_name)
        end
      end

    end
  end
end
