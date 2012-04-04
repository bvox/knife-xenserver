# knife-xenserver

Provision virtual machines with Citrix XenServer and Opscode Chef.

## Usage

    knife xenserver --help

## Examples

List all the VMs

    knife xenserver vm list --xenserver-host fooserver \
                            --xenserver-username root \
                            --xenserver-password secret


List all the templates

    knife xenserver template list --xenserver-host fooserver \
                                  --xenserver-username root \
                                  --xenserver-password secret

Include only custom templates

    knife xenserver template list --xenserver-host fooserver \
                                  --xenserver-username root \
                                  --xenserver-password secret \
                                  --exclude-builtin

## Sample .chef/knife.rb config

    knife[:xenserver_password] = "secret"
    knife[:xenserver_username] = "root"
    knife[:xenserver_host]     = "xenserver-real"


# Building the rubygem

    gem build knife-xenserver.gemspec
