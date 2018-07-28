json.extract! pool_entry, :id, :pool_id, :user_id, :name, :teams, :status, :created_at, :updated_at
json.url pool_entry_url(pool_entry, format: :json)
