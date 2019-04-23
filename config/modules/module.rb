Cms::Lib::Modules::ModuleSet.draw :gis, '地理情報', 10 do |mod|
  ## contents
  mod.content :entries, '地理情報', publishable: true

  ## directories
  mod.directory :entries,         '検索結果一覧', dynamic: true
  #mod.directory :portals,         '個別地図ポータル', dynamic: true
  mod.directory :registrations,   '登録申請', dynamic: true
  mod.directory :change_requests, '変更申請', dynamic: true

  ## pieces
  mod.piece :recommends,      'ダイレクト検索'
  mod.piece :simple_forms,    'かんたん検索'
  mod.piece :forms,           '検索フォーム'
  #mod.piece :portals,         '個別地図一覧'
  mod.piece :facility_counts, '施設登録件数'

  ## public models
  mod.public_model :entries
  mod.public_model :maps
  mod.public_model :layers
  mod.public_model :icons
  mod.public_model :layer_drawing_settings
  mod.public_model :folders
  mod.public_model :recommends
end
