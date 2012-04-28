module Fog
  module Compute
    class XenServer

      class Real
        
        require 'fog/xenserver/parser'
        
        def add_attribute( klass, ref, attr_name, *value )
          @connection.request({:parser => Fog::Parsers::XenServer::Base.new, :method => "#{klass}.add_#{attr_name.gsub('-','_')}"}, ref, *value)
        end
        
      end
      
      class Mock
        
        def add_attribute( klass, ref, attr_name, value )
          Fog::Mock.not_implemented
        end
        
      end

    end
  end
end
