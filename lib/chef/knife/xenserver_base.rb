#
# Author:: Sergio Rubio (<rubiojr@bvox.net>)
# Copyright:: BVox S.L. (c) 2012
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

require 'chef/knife'
$: << File.dirname(__FILE__) + "/../../../vendor/fog/lib/"
require 'fog'
require 'colored'

class Chef
  class Knife
    module XenserverBase

      def self.included(includer)
        includer.class_eval do

          deps do
            require 'net/ssh/multi'
            require 'readline'
            require 'chef/json_compat'
            require 'terminal-table/import'
            require 'alchemist'
          end

          option :xenserver_password,
            :long => "--xenserver-password PASSWORD",
            :description => "Your XenServer password"

          option :xenserver_username,
            :long => "--xenserver-username USERNAME",
            :default => "root",
            :description => "Your XenServer username (default 'root')"

          option :xenserver_host,
            :long => "--xenserver-host ADDRESS",
            :description => "Your XenServer host address"
        end
      end

      def connection
        if not @connection
          host = config[:xenserver_host] || Chef::Config[:knife][:xenserver_host]
          username = config[:xenserver_username] || Chef::Config[:knife][:xenserver_username]
          password = config[:xenserver_password] || Chef::Config[:knife][:xenserver_password]
          ui.info "Connecting to XenServer host #{host.yellow}..."
          begin
            @connection = Fog::Compute.new({
              :provider => 'XenServer',
              :xenserver_url => host,
              :xenserver_username => username,
              :xenserver_password => password,
            })
          rescue SocketError => e
            ui.error "Error connecting to the hypervisor: #{host}" 
            exit 1
          rescue Fog::XenServer::InvalidLogin => e
            ui.error "Error connecting to the hypervisor: #{host}" 
            ui.error "Check the username and password."
            exit
          rescue => e
            ui.error "Error connecting to the hypervisor" 
            ui.error "#{e.class} #{e.message}" 
            exit 1
          end

        else
          @connection
        end
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

    end
  end
end


