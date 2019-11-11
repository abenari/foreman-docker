require 'test_plugin_helper'

class DockerRegistryTest < ActiveSupport::TestCase
  subject { FactoryBot.create(:docker_registry) }

  test_attributes :pid => '8212ab15-8298-4a46-88ba-eaf71069e068'
  test 'should create with valid name' do
    docker_registry = FactoryBot.build(:docker_registry)
    valid_name_list.each do |name|
      docker_registry.name = name
      assert docker_registry.valid?, "Validation failed for create with valid name: #{name} length: #{name.length}"
      assert_equal name, docker_registry.name
    end
  end

  test_attributes :pid => 'fdd9c76b-43a7-4ece-8975-3b08241134c8'
  test 'should update with valid name' do
    assert DockerRegistry.exists?(subject.id)
    valid_name_list.each do |name|
      subject.name = name
      assert subject.valid?, "Validation failed for update with valid name: #{name} length: #{name.length}"
      assert_equal name, subject.name
    end
  end

  test 'used_location_ids should return correct location ids' do
    location = FactoryBot.build(:location)
    r = as_admin do
      FactoryBot.create(:docker_registry, :locations => ([location]))
    end
    assert r.used_location_ids.include?(location.id)
  end

  test 'used_organization_ids should return correct organization ids' do
    organization = FactoryBot.build(:organization)
    r = as_admin do
      FactoryBot.create(:docker_registry, :organizations => ([organization]))
    end
    assert r.used_organization_ids.include?(organization.id)
  end

  test 'password is stored encrypted' do
    registry = as_admin { FactoryBot.build(:docker_registry) }
    registry.password = 'encrypted-whatever'
    DockerRegistry.any_instance.expects(:encryption_key).at_least_once.returns('fakeencryptionkey')
    assert registry.is_decryptable?(registry.password_in_db)
  end

  should validate_presence_of(:name)
  should validate_presence_of(:url)
  should validate_uniqueness_of(:name)
  should validate_uniqueness_of(:url)

  describe 'registry validation' do
    setup do
      subject.unstub(:attempt_login)
    end

    test 'is valid when the api is ok' do
      subject.api.expects(:ok?).returns(true)
      assert subject.valid?
    end

    test 'is not valid when api is not ok' do
      subject.api.expects(:ok?)
        .raises(Docker::Error::AuthenticationError)
      refute subject.valid?
    end
  end

  describe '#api' do
    let(:api) { subject.api }

    test 'returns a RegistryApi instance' do
      assert_kind_of Service::RegistryApi, api
    end
  end
end
