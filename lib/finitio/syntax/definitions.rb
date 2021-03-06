module Finitio
  module Syntax
    module Definitions
      include Node

      def compile(system)
        captures[:type_def].each do |node|
          node.compile(system)
        end
        system
      end

      def to_ast
        captures[:type_def].map(&:to_ast)
      end

    end # module Definitions
  end # module Syntax
end # module Finitio
