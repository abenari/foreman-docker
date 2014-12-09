require 'test_plugin_helper'

class DockerTagTest < ActiveSupport::TestCase
  test 'creating fails if no repo is provided' do
    tag = FactoryGirl.build(:docker_tag, :repository => nil)
    refute tag.valid?
    assert tag.errors.size >= 1
  end

  test 'creating succeeds if an repo is provided' do
    tag = FactoryGirl.build(:docker_tag)
    tag.repository = FactoryGirl.build(:docker_repository)

    assert tag.valid?
    assert tag.save
  end

  context 'validations' do
    test 'tag has to be present' do
      refute FactoryGirl.build(:docker_tag, :tag => '').valid?
    end

    test 'tag is unique within repo scope' do
      repo           = FactoryGirl.create(:docker_repository)
      tag            = FactoryGirl.create(:docker_tag, :repository => repo)
      duplicated_tag = FactoryGirl.build(:docker_tag,  :repository => repo, :tag => tag.tag)
      refute duplicated_tag.valid?
    end

    test 'tag is not unique for different repos' do
      tag = FactoryGirl.create(:docker_tag)
      assert FactoryGirl.build(:docker_tag, :tag => tag.tag).valid?
    end
  end
end
