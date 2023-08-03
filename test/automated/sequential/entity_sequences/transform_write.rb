require_relative '../../../test_init'

context "Idempotence" do
  context "Sequential" do
    context "EntitySequences" do
      context '#transform_write' do
        entity = Controls::Entity::WithSequences.example
        attributes = entity.attributes

        context 'transform_write duplicates sequences' do
          test 'has same values' do
            assert attributes[:sequences] == entity.sequences
          end

          test 'is different object' do
            refute attributes[:sequences].equal?(entity.sequences)
          end
        end

        test "entity's transform_write is called" do
          assert entity.instance_transform_write_called
        end
      end
    end
  end
end
