![BVox](http://bvox.net/images/logo-bvox-big.png)
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

Include built-in templates too

    knife xenserver template list --xenserver-host fooserver \
                                  --xenserver-username root \
                                  --xenserver-password secret \
                                  --include-builtin

Create a new template from a VHD file (PV by default, use --hvm otherwise) 

    knife xenserver template create --vm-name ubuntu-precise-amd64 \
                                    --vm-disk ubuntu-precise.vhd \
                                    --vm-memory 512 \
                                    --vm-networks 'Integration-VLAN' \
                                    --storage-repository 'Local storage' \
                                    --xenserver-password changeme \
                                    --xenserver-host 10.0.0.2 


Create a VM from template ed089e35-fb49-f555-4e20-9b7f3db8df2d and bootstrap it using the 'root' user and password 'secret'. The VM is created without VIFs, inherited VIFs from template are removed by default (use --keep-template-networks to avoid that)

    knife xenserver vm create --vm-template ed089e35-fb49-f555-4e20-9b7f3db8df2d \
                              --vm-name foobar --ssh-user root \
                              --ssh-password secret 

Create a VM from template and add two custom VIFs in networks 'Integration-VLAN' and 'Another-VLAN', with MAC address 11:22:33:44:55:66 for the first VIF

    knife xenserver vm create --vm-template ed089e35-fb49-f555-4e20-9b7f3db8df2d \
                              --vm-name foobar --ssh-user root \
                              --ssh-password secret \
                              --vm-networks 'Integration-VLAN,Another-VLAN' \
                              --mac-addresses 11:22:33:44:55:66

Create a VM from template and supply ip/host/domain configuration. Requires installation of xe-automater scripts (https://github.com/adamlau/xenserver-automater)

    knife xenserver vm create   --vm-template my-template -x root --keep-template-networks \
                                --vm-name my-hostname \
                                --vm-ip 172.20.1.25 --vm-netmask 255.255.0.0 --vm-gateway 172.20.0.1 --vm-dns 172.20.0.3 \
                                --vm-domain my-domain.local

List hypervisor networks

    knife xenserver network list

## Sample .chef/knife.rb config

    knife[:xenserver_password] = "secret"
    knife[:xenserver_username] = "root"
    knife[:xenserver_host]     = "xenserver-real"


# Building the rubygem

    gem build knife-xenserver.gemspec
