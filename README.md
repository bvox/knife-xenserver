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

## Sample .chef/knife.rb config

    knife[:xenserver_password] = "secret"
    knife[:xenserver_username] = "root"
    knife[:xenserver_host]     = "xenserver-real"


# Building the rubygem

    gem build knife-xenserver.gemspec
