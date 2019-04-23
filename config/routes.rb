Zplugin3::Content::Gis::Engine.routes.draw do
  mod = "gis"
  root "#{mod}/contents#index"
  scope "/", :module => mod, :as => mod do
    resources :contents do
      collection do
        get :install
      end
    end
  end
end
