module Finitio
  module Syntax
    module AdType
      include Node

      capture :builtin_type_name

      def compile(factory)
        name  = builtin_type_name
        clazz = name ? resolve_ruby_const(name.to_s) : nil
        factory.adt(clazz, compile_contracts(factory, clazz))
      end

      def compile_contracts(factory, clazz)
        contracts = {}
        captures[:contract].each do |node|
          contract = node.compile(factory, clazz)
          contracts.merge!(contract) do |k,_,_|
            raise Error, "Duplicate contract name `#{k}`"
          end
        end
        contracts
      end

      def to_ast
        [ 
          :ad_type,
          builtin_type_name ? builtin_type_name.to_s : nil
        ] + captures[:contract].map(&:to_ast)
      end

    end # module AdType
  end # module Syntax
end # module Finitio