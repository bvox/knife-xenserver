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
    class XenserverTemplateList < Knife

      include Knife::XenserverBase

      banner "knife xenserver template list"

      option :include_builtin,
        :long => "--include-builtin",
        :description => "Include built-in templates",
        :boolean => true,
        :proc => Proc.new { true }

      def run
        $stdout.sync = true
        templates = connection.servers.custom_templates || []
        table = table do |t|
          t.headings = %w{NAME MEMORY GUEST_TOOLS NETWORKS}
          if templates.empty? and !config[:include_builtin]
            ui.warn "No custom templates found. Use --include-builtin to list them all."
          end
          if config[:include_builtin]
            templates += connection.servers.builtin_templates
          end
          templates.each do |vm|
            networks = []
            vm.vifs.each do |vif|
              name = vif.network.name
              if name.size > 20
                name = name[0..16] + '...'
              end
              networks << name
            end
            networks = networks.join("\n")
            mem = bytes_to_megabytes(vm.memory_static_max)
            t << ["#{vm.name}\n  #{ui.color('uuid: ', :yellow)}#{vm.uuid}", mem, vm.tools_installed?, networks]
          end
        end
        puts table if !templates.empty?
      end

    end
  end
end
