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
    class XenserverTemplateList < Knife

      include Knife::XenserverBase

      banner "knife xenserver template list"

      option :exclude_builtin,
        :long => "--exclude-builtin",
        :description => "Exclude built-in templates from listing",
        :boolean => true,
        :proc => Proc.new { true }

      def run
        $stdout.sync = true
        table = table do |t|
          t.headings = %w{NAME MEMORY GUEST_TOOLS NETWORKS}
          if config[:exclude_builtin]
            templates = connection.hosts.first.custom_templates
          else
            templates = connection.hosts.first.templates
          end
          templates.each do |vm|
            if vm.tools_installed?
              networks = []
              vm.guest_metrics.networks.each do |k,v|
                networks << v
              end
              networks = networks.join(",")
            else
              networks = "unknown"
            end
            mem = vm.memory_static_max.to_i.bytes.to.megabytes.round
            t << ["#{vm.name}\n  #{ui.color('uuid: ', :yellow)}#{vm.uuid}", mem, vm.tools_installed?, networks]
          end
        end
        puts table
      end

    end
  end
end
