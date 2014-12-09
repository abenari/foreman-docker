require 'test_plugin_helper'

class DockerRepositoryTest < ActiveSupport::TestCase
  test 'destroy docker repo with tags is successful' do
    tag = FactoryGirl.create(:docker_tag)
    repo = FactoryGirl.create(:docker_repository)
    repo.tags << tag
    assert repo.destroy
    refute DockerRepository.exists?(repo.id)
    refute DockerTag.exists?(tag.id)
  end

  context 'validations' do
    test 'without name is invalid' do
      refute FactoryGirl.build(:docker_repository, :name => '').valid?
    end

    test 'name is unique per registry' do
      registry = FactoryGirl.create(:docker_registry)
      assert FactoryGirl.create(:docker_repository, :name => 'test', :registry => registry).valid?
      refute FactoryGirl.build(:docker_repository, :name => 'test', :registry => registry).valid?
    end
  end
end
