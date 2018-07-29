# frozen_string_literal: true

json.array! @pool.entries, partial: 'entries/entry', as: :entry
