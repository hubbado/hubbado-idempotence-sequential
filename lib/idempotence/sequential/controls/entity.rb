module Idempotence
  module Sequential
    module Controls
      module Entity
        class SomeEntity
          include Schema::DataStructure
          include Idempotence::Sequential::EntitySequences

          attr_reader :instance_transform_write_called

          def transform_write(_data)
            @instance_transform_write_called = true
          end
        end

        def self.example
          SomeEntity.new
        end

        def self.id
          ID.example(increment: id_increment)
        end

        def self.id_increment
          5678
        end

        module WithSequences
          def self.example
            message = Controls::Message.example

            entity = Entity.example
            entity.record_sequence(message)
            entity
          end
        end
      end
    end
  end
end
