json.extract! game, :id, :home_team, :away_team, :status, :winner, :created_at, :updated_at, :loser, :week, :year
json.url game_url(game, format: :json)
