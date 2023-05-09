require_relative '../../../test_init'

context "Idempotence" do
  context "Sequential" do
    context ".transient_attributes" do
      entity = Controls::Entity.example

      test "sequences are in transient_attributes" do
        assert entity.class.transient_attributes.include?(:sequences)
      end

      test "entity all_attributes includes :sequences" do
        assert entity.all_attributes.has_key?(:sequences)
      end

      test "entity attributes does not include :sequences" do
        refute entity.attributes.has_key?(:sequences)
      end
    end
  end
end
