# 1.3.0 - Thy 06 Jun 2013 

* New **sr list** command to list storage repositories.
* Experimental **sr create** command to create a Storage Repository.
* The **vm create** command now supports --extra-vdis option to
  create additional VDIs and attach them to the VM.
* New **host list** command: currently lists UUID only.


# 1.2.3 - Fri 07 Dec 2012

* Drop alchemist gem, fixing some compat issues with some ruby 1.9
  implementations. See #6.

# 1.2.2 - Thu 06 Dec 2012 

* Fixed --storage-repository parameter in 'template create' command

# 1.2.1 - Mon 12 Nov 2012

* Maks3w patches for xenserver-automated related stuff

* Added --match flag to the 'vm delete' command.

  If --match is used, every VM matching VM_NAME will be deleted

* Deprecate --force-delete option in 'vm delete' since --yes should
  be used to confirm (force).

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
