ZomekiCMS::Application.routes.draw do
  mod = "gis"

  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}/c:concept", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    resources :entries,
      :controller => 'admin/entries',
      :path => ':content/entries' do
        get 'file_contents/(*path)' => 'admin/entries/files#content'
        member do
          post :approve
          post :passback
          post :pullback
          post :publish
          get  :select
        end
        collection do
          post :geocode
        end
      end

    resources :registrations,
      :controller => 'admin/registrations',
      :path => ':content/registrations' do
        get 'file_contents/(*path)' => 'admin/registrations/files#content'
        member do
          post  :copy
          post  :publish
          post  :close
        end
        collection do
          post :geocode
        end
      end

    resources :portal_maps,
      :controller => 'admin/portal_maps',
      :path => ':content/portal_maps' do
        get 'file_contents/(*path)' => 'admin/layers/files#content'
        resources :folders, :controller => 'admin/portal_maps/folders'
        member do
          post :approve
          post :passback
          post :pullback
          post :publish
          get  :select
        end
      end

    resources :categories,
      :controller => 'admin/categories',
      :path => ':content/categories' do
      resources :categories,
        :controller => 'admin/categories'
      end

    resources :layers,
      :controller => 'admin/layers',
      :path => ':content/layers' do
        get 'file_contents/(*path)' => 'admin/layers/files#content'
        resources :draw_settings, :controller => 'admin/layers/draw_settings'
     end

    resources :recommends,
      :controller => 'admin/recommends',
      :path => ':content/recommends'

    resources :registrations,
     :controller => 'admin/registrations',
     :path => ':content/registrations'

    resources :imports,
     :controller => 'admin/imports',
     :path => ':content/imports'
    resources :exports,
     :controller => 'admin/exports',
     :path => ':content/exports'


    ## nodes
    resources :node_entries,
      :controller => 'admin/node/entries',
      :path       => ':parent/node_entries'
    resources :node_registrations,
      :controller => 'admin/node/registrations',
      :path       => ':parent/node_registrations'
    resources :node_change_requests,
      :controller => 'admin/node/change_requests',
      :path       => ':parent/node_change_requests'
    resources :node_portals,
      :controller => 'admin/node/portals',
      :path       => ':parent/node_portals'

    ## pieces
    resources :piece_recommends,      :controller => 'admin/piece/recommends'
    resources :piece_simple_forms,    :controller => 'admin/piece/simple_forms'
    resources :piece_forms,           :controller => 'admin/piece/forms'
    resources :piece_portals,         :controller => 'admin/piece/portals'
    resources :piece_facility_counts, :controller => 'admin/piece/facility_counts'

  end

   ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    get 'node_entries(/index)'        => 'public/node/entries#index'
    get 'node_entries/:name(/index)'  => 'public/node/entries#show'
    get 'node_entries/:name/detail(/index)'  => 'public/node/entries#detail'
    get 'node_entries/:name/edit(/index)'    => 'public/node/entries#edit'
    put 'node_entries/:name/update(/index)'  => 'public/node/entries#update'
    get 'node_entries/:name/file_contents/(*path)'            => 'public/node/entries#file_content'

    get 'node_entries/:name/preview/:id/file_contents/(*path)'    => 'public/node/entries#file_content'
    get 'node_entries/:name/preview/:id/qrcode.:extname'          => 'public/node/entries#qrcode'
    get 'node_entries/:name/preview/:id(/:filename_base.:format)' => 'public/node/entries#show'

    get  'node_registrations(/index)'          => 'public/node/registrations#index'
    get  'node_registrations/finish(/index)'   => 'public/node/registrations#finish'
    post 'node_registrations/confirm(/index)'  => 'public/node/registrations#confirm'
    post 'node_registrations/submit(/index)'   => 'public/node/registrations#send_request'
    post 'node_registrations/geocode(/index)'  => 'public/node/registrations#geocode'

    get  'node_change_requests(/index)'               => 'public/node/change_requests#index'
    get  'node_change_requests/:name(/index)'         => 'public/node/change_requests#show'
    post 'node_change_requests/:name/confirm(/index)' => 'public/node/change_requests#confirm'
    post 'node_change_requests/:name/submit(/index)'  => 'public/node/change_requests#send_request'
    post 'node_change_requests/geocode(/index)'       => 'public/node/change_requests#geocode'
  end
end

