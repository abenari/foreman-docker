module Foreman
  module PermittedAttributes
    mattr_reader :container_attributes

    @@container_attributes = [:command, :repository_name, :name, :compute_resource_id, :entrypoint,
                  :cpu_set, :cpu_shares, :memory, :tty, :attach_stdin, :registry_id,
                  :attach_stdout, :attach_stderr, :tag, :uuid, :environment_variables_attributes,
                  :katello, :exposed_ports_attributes, :dns]
  end
end