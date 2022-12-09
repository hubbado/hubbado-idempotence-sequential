module Idempotence
  module Sequential
    module Controls
      module Category
        def self.example
          Messaging::Controls::StreamName::NamedCategory.example.category
        end

        module Command
          def self.example
            category = Category.example

            "#{category}:command"
          end
        end
      end
    end
  end
end
