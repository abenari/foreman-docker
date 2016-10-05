Foreman::Application.routes.draw do
  mount ForemanDocker::Engine, :at => '/', :as => 'foreman_docker'
end
