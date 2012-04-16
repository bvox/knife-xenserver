#
# Author:: Sergio Rubio (<rubiojr@frameos.org>)
# Copyright:: Copyright (c) 2011 Sergio Rubio
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
    class XenserverVmDelete < Knife

      include Knife::XenserverBase

      banner "knife xenserver vm delete VM_NAME [VM_NAME] (options)"

      option :force_delete,
        :long => "--force-delete NO",
        :default => 'no',
        :description => "Do not confirm VM deletion when yes"

      def run
        deleted = []
        connection.servers.each do |vm|
          @name_args.each do |vm_name|
            if (vm_name == vm.name) or (vm_name == vm.uuid)
              if config[:force_delete] =~ /(no|NO|false|FALSE)/
                confirm("Do you really want to #{'delete'.bold.red} this virtual machine #{vm.name.bold.red}")
              end
              vm.destroy
              deleted << vm_name
              ui.info("#{'Deleted'.yellow} virtual machine #{vm.name.yellow} [uuid: #{vm.uuid}]")
            end
          end
        end
        @name_args.each do |vm_name|
          ui.warn "Virtual Machine #{vm_name} not found" if not deleted.include?(vm_name)
        end
      end

    end
  end
end
