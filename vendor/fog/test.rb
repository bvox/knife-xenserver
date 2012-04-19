require 'fog'
require 'pp'

conn = Fog::Compute.new({
  :provider => 'XenServer',
  :xenserver_url => 'xenserver-test',
  :xenserver_username => 'root',
  :xenserver_password => 'changeme',
})

# http://docs.vmd.citrix.com/XenServer/6.0.0/1.0/en_gb/api/?c=VBD

# List VBDs and properties
conn.vbds.each do |vbd|
  # VbdMetrics
  # http://docs.vmd.citrix.com/XenServer/6.0.0/1.0/en_gb/api/?c=VBD_metrics
  pp vbd
  puts vbd.server.name
  vbd.metrics
  vbd.allowed_operations
  vbd.device
  vbd.type # CD or Disk
  vbd.mode # RW/RO
  vbd.bootable
end

