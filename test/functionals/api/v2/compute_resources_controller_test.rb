require 'test_plugin_helper'

module Api
  module V2
    class ComputeResourcesControllerTest < ActionController::TestCase
      test_attributes :pid => 'f61c66c9-15f8-4b00-9e53-7ebfb09397cc'
      test "should create Docker compute resource" do
        attrs = { :name => "test", :provider => "Docker", :url => "unix:///var/run/docker.sock",
                  :location_ids => [Location.first.id], :organization_ids => [Organization.first.id] }
        assert_difference('ComputeResource.unscoped.count', +1) do
          post :create, params: { :compute_resource => attrs }
        end
        assert_response :created
        result =  JSON.parse(@response.body)
        assert_equal attrs[:name], result['name']
        assert_equal attrs[:provider], result['provider']
        assert_equal attrs[:url], result['url']
      end

      test_attributes :pid => 'f1f23c1e-6481-46b5-9485-787ae18d9ed5'
      test "should delete Docker compute resource" do
        docker_cr = ComputeResource.new(:name => "test", :provider => "Docker", :url => "unix:///var/run/docker.sock",
                                        :location_ids => [Location.first.id], :organization_ids => [Organization.first.id])
        docker_cr.save!
        assert_difference('ComputeResource.unscoped.count', -1) do
          delete :destroy, params: { :id => docker_cr.id }
        end
        assert_response :success
        refute ComputeResource.unscoped.exists?(docker_cr.id)
      end
    end
  end
end
