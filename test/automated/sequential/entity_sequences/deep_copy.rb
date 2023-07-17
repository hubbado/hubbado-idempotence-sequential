require_relative '../../../test_init'

context "Idempotence" do
  context "Sequential" do
    context "EntitySequences" do
      context "#deep_copy" do
        entity = Controls::Entity::WithSequences.example
        duplicate = entity.deep_copy
        
        test 'duplicate and entity are equal' do
          assert entity == duplicate
        end

        test 'duplicate and entity are different objects' do
          assert entity.object_id != duplicate.object_id
        end

        test 'sequences attribute of duplicate and entity are equal' do
          assert entity.sequences == duplicate.sequences
        end

        test 'sequences attribute of duplicate and entity are different objects' do
          assert entity.sequences.object_id != duplicate.sequences.object_id
        end
      end
    end
  end
end
