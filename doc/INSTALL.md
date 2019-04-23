# JoruriCMS2017 地理情報プラグイン インストールマニュアル

## 1.想定環境

### システム

* OS: CentOS 7.2
* Webサーバ: nginx 1.12
* Appサーバ: unicorn 5.4
* Database: PostgreSQL 9.5
* Geospatial Database Module: PostGIS 2.4
* Ruby: 2.6
* Rails: 5.2
* JoruriCMS 2017 Release4

## 2.JoruriCMS2017インストール

JoruriCMS2017のインストールを実施する

## 3.PostGISのインストール
地理空間情報関連パッケージをインストールします。

    # yum -y install gd gd-devel proj proj-devel proj-epsg libicu libicu-devel unixODBC unixODBC-devel libxml2 libxml2-devel
    # yum -y install --enablerepo=epel gdal gdal-devel gdal-libs
    # yum -y install geos geos-devel
    # yum -y install postgis24_95 postgis24_95-utils postgis24_95-client
    # yum -y install postgis24_95-devel

PostGISを既存のJoruriCMS2017のデータベースにインストールします

    # su - postgres -c "psql joruri_production -f /usr/pgsql-9.5/share/contrib/postgis-2.4/postgis.sql"
    # su - postgres -c "psql joruri_production -f /usr/pgsql-9.5/share/contrib/postgis-2.4/spatial_ref_sys.sql"

## 4.地理情報プラグインのインストール

JoruriCMS2017管理画面にアクセスし、地理情報プラグインをインストール

* https://github.com/joruri/zplugin3-content-gis

ツール　＞　プラグイン　＞　新規作成から下記の内容を登録する。

|項目名|設定値|
|:----------|:---------------|
|URL|https://github.com/|
|プラグイン名|joruri/zplugin3-content-gis|
|タイトル|地理情報プラグイン|
|バージョン|master|

また、地理情報プラグインは下記のデータベースプラグインと連携しているため、併せてインストールする。

* https://github.com/joruri/zplugin3-content-webdb

ツール　＞　プラグイン　＞　新規作成から下記の内容を登録する。

|項目名|設定値|
|:----------|:---------------|
|URL|https://github.com/|
|プラグイン名|joruri/zplugin3-content-webdb|
|タイトル|データベース|
|バージョン|master|

登録後、一覧画面から「アプリ再起動」を実施する。

## 5.地理情報プラグインのマイグレーションを実行

gemの更新を行い、コンテンツプラグインをダウンロードする。
    # su - joruri -c 'export LANG=ja_JP.UTF-8; cd /var/www/joruri && bundle install'

データベースのアダプターをpostgisに変更する。
    $ vi config/database.yml
```
default: &default
  adapter: postgis #postgresqlからpostgisに変更する
```

マイグレーションを実施して地理情報・データベースコンテンツプラグインに必要なテーブルを作成する。
    # su - joruri -c 'export LANG=ja_JP.UTF-8; cd /var/www/joruri && bundle exec rake zplugin3_content_gis:install:migrations RAILS_ENV=production'
    # su - joruri -c 'export LANG=ja_JP.UTF-8; cd /var/www/joruri && bundle exec rake zplugin3_content_webdb_engine:install:migrations RAILS_ENV=production'
    # su - joruri -c 'export LANG=ja_JP.UTF-8; cd /var/www/joruri && bundle exec rake db:migrate RAILS_ENV=production'

地理情報プラグインに必要な画像等のファイルをコピー
    # su - joruri -c 'export LANG=ja_JP.UTF-8; cd /var/www/joruri && bundle exec rake zplugin3_content_gis:entry:copy_images RAILS_ENV=production'
    # su - joruri -c 'export LANG=ja_JP.UTF-8; cd /var/www/joruri && bundle exec rake joruri:maintenance:common_dir:copy RAILS_ENV=production'

## 6.サーバー再起動

unicornとdelayed_jobを再起動する。

    # su - joruri -c 'export LANG=ja_JP.UTF-8; cd /var/www/joruri && bundle exec rake delayed_job:restart RAILS_ENV=production'
    # su - joruri -c 'export LANG=ja_JP.UTF-8; cd /var/www/joruri && bundle exec rake unicorn:restart RAILS_ENV=production'