namespace :zplugin3_content_gis do
  namespace :entry do
    desc "Migrate CSV"
    task :copy_images => :environment do
      src_dir = "#{Zplugin3::Content::Gis::Engine.root}/app/assets/images/zplugin3/content/gis/"
      dst_dir = Rails.root.join("public/_common/themes/openlayers/images/")
      (2..11).each{|n|
        filename = "ic-#{format('%02d', n)}.png"
        src_path = "#{src_dir}#{filename}"
        dst_path = "#{dst_dir}#{filename}"
        puts ::File.exists?(src_path)
        if ::File.exists?(src_path) && !::File.exists?(dst_path)
          FileUtils.mkdir_p(dst_dir) unless FileTest.exist?(dst_dir)
          FileUtils.cp(src_path, dst_path)
        end
      }
    end

    desc "Create Index Cache"
    task :make_index => :environment do
      Gis::CacheHtmlJob.perform_now
    end
  end
end