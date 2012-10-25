# 1.2 - Thu 25 Oct 2012 

* Greatly improved 'vm list' command

  - Table columns can now be disabled in output:
  
      knife xenserver vm list --no-uuid \
                              --no-power \
                              --no-networks \
                              --no-tools 
  
  - Print CSV output with --csv instead of a regular ASCII table
    
    knife xenserver vm list --csv

* Added --match option to 'vm list'

  Print only VMs whose name matches the given regex:

    knife xenserver vm list --match '^my-vm.*?devel.bvox.net$'

* FIX: Set exit status to 1 when XenServer auth fails
* FIX: Print error if XenServer host is not defined

# 1.1 - 2012/10/21

* Fixed --no-host-key-verify vm create flag
* added power on/off commands
* Allow setting of network information on create for Ubuntu systems 
  (@krobertson, @adamlau)

  See https://github.com/bvox/knife-xenserver/pull/1

# 0.1.0 - 2012/04/04

* Initial release
