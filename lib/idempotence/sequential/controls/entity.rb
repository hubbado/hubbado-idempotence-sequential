module Idempotence
  module Sequential
    module Controls
      module Entity
        class SomeEntity
          include Idempotence::Sequential::EntitySequences
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
      end
    end
  end
end
