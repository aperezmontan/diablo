# frozen_string_literal: true

json.array! @pool_entries, partial: 'pool_entries/pool_entry', as: :pool_entry
