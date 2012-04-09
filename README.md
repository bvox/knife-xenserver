# knife-xenserver

Provision virtual machines with Citrix XenServer and Opscode Chef.

## Upgrading knife-xenserver

When upgrading knife-xenserver, it's very important to remove older knife-xenserver versions

    gem update knife-xenserver
    gem clean knife-xenserver

## Usage

    knife xenserver --help

## Examples

List all the VMs

    knife xenserver vm list --xenserver-host fooserver \
                            --xenserver-username root \
                            --xenserver-password secret


List custom templates

    knife xenserver template list --xenserver-host fooserver \
                                  --xenserver-username root \
                                  --xenserver-password secret

Include built-in tempaltes too

    knife xenserver template list --xenserver-host fooserver \
                                  --xenserver-username root \
                                  --xenserver-password secret \
                                  --include-builtin

Create a VM from template ed089e35-fb49-f555-4e20-9b7f3db8df2d and bootstrap it using the 'root' user and password 'secret'

   knife xenserver vm create --vm-template ed089e35-fb49-f555-4e20-9b7f3db8df2d \
                             --vm-name foobar --ssh-user root \
                             --ssh-password secret 

Create a VM from template and add two custom VIFs in networks 'Integration-VLAN' and 'Another-VLAN', with MAC address 11:22:33:44:55:66 for the first VIF

   knife xenserver vm create --vm-template ed089e35-fb49-f555-4e20-9b7f3db8df2d \
                             --vm-name foobar --ssh-user root \
                             --ssh-password secret \
                             --vm-networks 'Integration-VLAN,Another-VLAN' \
                             --mac-addresses 11:22:33:44:55:66

List hypervisor networks

   knife xenserver network list

## Sample .chef/knife.rb config

    knife[:xenserver_password] = "secret"
    knife[:xenserver_username] = "root"
    knife[:xenserver_host]     = "xenserver-real"


# Building the rubygem

    gem build knife-xenserver.gemspec
