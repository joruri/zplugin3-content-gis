class Gis::EntriesFinder < ApplicationFinder
  def initialize(entries, user: nil, content: nil, categorizable_type: 'Gis::Entry')
    @entries = entries
    @user = user
    @content = content
    @categorizable_type = categorizable_type
  end

  def search(criteria)
    @entries = @entries.where(state: criteria[key]) if criteria[:state].present?
    search_db = target_db(criteria[:db_id]) || default_db

    if search_db
      @entries = @entries.where(db_id: search_db.id)
      @entries = Webdb::EntriesFinder.new(search_db, @entries)
        .search(criteria, Gis::Entry, criteria[:free_word], nil, :or)
    else
      @entries = @entries.where(arel_table[:title].matches(criteria[:free_word])) if criteria[:free_word].present?
    end

    if criteria[:category_ids].present? && criteria[:category_ids].reject(&:blank?).present?
      @entries = categorized_search(criteria[:category_ids], :or)
    end

    if criteria[:creator_user_name].present?
      @entries = operated_by_user_name(@entries, 'create', criteria[:creator_user_name])
    end

    if criteria[:creator_group_id].present?
      @entries = operated_by_group(@entries, 'create', criteria[:creator_group_id])
    end

    @entries
  end

  def public_search(criteria, keyword, sort_key, target, operator_type)
    search_queries = public_search_conditions(criteria, keyword, sort_key, target, operator_type: operator_type)
    if search_queries.present?
      search_queries.each{|q|
        @entries = @entries.merge(q)
       }
    end
    @entries
  end

  def recommend_search(recommends)
    recommends.to_unsafe_h.each do |key, value|
      configs = @content.recommends.where(id: value)
      result_ids = []
      configs.each do |c|
        search_queries = public_search_conditions(c.criteria, nil, nil, c.db_id, category_operator: c.operator_type.to_sym)
        next if search_queries.blank?
        result = @entries.dup
        search_queries.each_with_index do |q, i|
          result = result.merge(q) if i == 0
          result = result.or(q) if i != 0 && c.operator_type.to_sym == :and
          result = result.or(q) if i != 0 && c.operator_type.to_sym == :or
        end
        result_ids << result.select(:id, :state).pluck(:id)
      end
      next if result_ids.blank?
      resule_ids = result_ids.flatten.uniq
      @entries = @entries.where(id: resule_ids)
    end

    @entries
  end

  def public_search_conditions(criteria, keyword, sort_key, target, operator_type: :and, category_operator: :or)
    search_queries = []

    if target_db = target_db(target)
      db_queries = Webdb::EntriesFinder.new(target_db, @entries)
        .search_conditions(criteria, Gis::Entry, keyword, sort_key)
      search_queries += db_queries if db_queries.present?
    end

    if criteria[:lat].present? && criteria[:lng].present?
     search_queries << Gis::Entry.search_nearby(lat: criteria[:lat], lng: criteria[:lng])
    end

    if criteria[:category_ids].present? && criteria[:category_ids].reject(&:blank?).present?
      alls = category_operator == :and ? true : false
      search_queries << Gis::Entry.categorized_into(criteria[:category_ids], categorizable_type: @categorizable_type, alls: alls)
    end

    search_queries
  end

  def categorized_search(categories, operator_type)
    alls = operator_type == :and ? true : false
    @entries = @entries.categorized_into(categories, alls: alls, categorizable_type: @categorizable_type)
  end

  private

  def arel_table
    @entries.arel_table
  end

  def ordering(order)
    order == "desc" ? "DESC" : "ASC"
  end

  def operated_by_user_name(action, user_name)
    case action
    when 'create'
      users = Sys::User.arel_table
      @entries.joins(creator: :user)
               .where([users[:name].matches("%#{user_name}%"),
                       users[:name_en].matches("%#{user_name}%")].reduce(:or))
    else
      operation_logs = Sys::OperationLog.arel_table
      users = Sys::User.arel_table
      @entries.joins(operation_logs: :user)
               .where(operation_logs[:action].eq(action))
               .where([users[:name].matches("%#{user_name}%"),
                       users[:name_en].matches("%#{user_name}%")].reduce(:or))
    end
  end

  def operated_by_group(entries, action, group_id)
    case action
    when 'create'
      creators = Sys::Creator.arel_table
      entries.joins(:creator)
               .where(creators[:group_id].eq(group_id))
    else
      operation_logs = Sys::OperationLog.arel_table
      users_groups = Sys::UsersGroup.arel_table
      entries.joins(operation_logs: { user: :users_groups })
               .where(operation_logs[:action].eq(action))
               .where(users_groups[:group_id].eq(group_id))
    end
  end

  def target_db(target)
    return nil if target.blank?
    return nil if @content.blank?
    @content.form_dbs.find_by(id: target)
  end

  def default_db
    @content.default_db.present? && @content.form_dbs.size == 1 ? @content.default_db : nil
  end

  def registration_db
    @content.registration_db.present? ? @content.registration_db : nil
  end

end
