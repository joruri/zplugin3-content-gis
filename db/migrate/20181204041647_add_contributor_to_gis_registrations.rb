class AddContributorToGisRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :gis_registrations, :contributor ,:string
    add_column :gis_registrations, :remote_addr ,:string
    add_column :gis_registrations, :user_agent ,:string
  end
end
