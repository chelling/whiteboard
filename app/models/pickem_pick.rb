class PickemPick < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  belongs_to :team
  has_one :wager

  before_save :update_wager
  
  attr_accessible :game_id, :team_id, :user_id, :week, :year, :win, :recommended, :recommended_points, :tie

  # before_save
  def update_wager
    if self.win.nil? || self.wager.nil?
      return
    end

    if self.win && !self.tie
      self.wager.win = 1
      self.wager.save
    elsif !self.win && self.tie
      self.wager.win = 0
      self.wager.save
    elsif !self.win && !self.tie
      self.wager.win = -1
      self.wager.save
    end
  end

  def get_user_record_on_teams(year, start_week, end_week)
    wins = 0
    losses = 0
    user = User.find(user_id)
    game = Game.find(game_id)
    games = Game.where("(home_team_id = ? or away_team_id = ?) and year = ? and week >= ? and week <= ?",
                      game.home_team_id, game.home_team_id, year, start_week, end_week)

    games.map do |g|
      pick = user.pickem_pick_by_game(g)
      if !pick.try(:win).nil?
        pick.win == true ? wins += 1 : losses += 1
        if pick.tie
          losses -= 1
        end
      end
    end

    games = Game.where("(home_team_id = ? or away_team_id = ?) and year = ? and week >= ? and week <= ?",
                       game.away_team_id, game.away_team_id, year, start_week, end_week)
    games.map do |g|
      pick = user.pickem_pick_by_game(g)
      if !pick.try(:win).nil?
        pick.win == true ? wins += 1 : losses += 1
        if pick.tie
          losses -= 1
        end
      end
    end
    return "(#{wins}-#{losses})"
  end

  def get_user_record_on_team_home(year, start_week, end_week)
    wins = 0
    losses = 0
    user = User.find(user_id)
    game = Game.find(game_id)
    games = Game.where("home_team_id = ? and year = ? and week >= ? and week <= ?",
                       game.home_team_id, year, start_week, end_week)
    games.map do |g|
      pick = user.pickem_pick_by_game(g)
      if !pick.try(:win).nil?
        pick.win == true ? wins += 1 : losses += 1
        if pick.tie
          losses -= 1
        end
      end
    end

    return "(#{wins}-#{losses})"
  end

  def get_user_record_on_team_away(year, start_week, end_week)
    wins = 0
    losses = 0
    user = User.find(user_id)
    game = Game.find(game_id)
    games = Game.where("away_team_id = ? and year = ? and week >= ? and week <= ?",
                       game.away_team_id, year, start_week, end_week)
    games.map do |g|
      pick = user.pickem_pick_by_game(g)
      if !pick.try(:win).nil?
        pick.win == true ? wins += 1 : losses += 1
        if pick.tie
          losses -= 1
        end
      end
    end

    return "(#{wins}-#{losses})"
  end

  def get_user_record_on_team_picked(year, start_week, end_week)
    wins = 0
    losses = 0
    user = User.find(user_id)

    picks = user.pickem_picks.where("year = ? and week >= ? and week <= ? and team_id = ?",
                                    year, start_week, end_week, team_id)
    picks.map do |pick|
      if !pick.try(:win).nil?
        pick.win == true ? wins += 1 : losses += 1
        if pick.tie
          losses -= 1
        end
      end
    end

    return "(#{wins}-#{losses})"
  end

  def get_user_record_on_team_not_picked(year, start_week, end_week)
    wins = 0
    losses = 0
    user = User.find(user_id)
    game = Game.find(game_id)
    game.home_team_id == team_id ? t_id = game.away_team_id : t_id = game.home_team_id
    picks = user.pickem_picks.where("year = ? and week >= ? and week <= ? and team_id = ?",
                                    year, start_week, end_week, t_id)
    picks.map do |pick|
      if !pick.try(:win).nil?
        pick.win == true ? wins += 1 : losses += 1
        if pick.tie
          losses -= 1
        end
      end
    end

    return "(#{wins}-#{losses})"
  end

  def get_user_record_on_favorites(year, start_week, end_week)
    home_fav = false
    away_fav = false
    wins = 0
    losses = 0
    user = User.find(user_id)
    g = Game.find(game_id)

    if g.line < 0
      home_fav = true
    elsif g.line > 0
      away_fav = true
    end

    Game.where("year = ? and week >= ? and week <= ?", year, start_week, end_week).map do |game|
      if !game.home_score.nil? && !game.away_score.nil?
        # home favorites
        if game.line < 0 && home_fav
          pick = user.pickem_pick_by_game(game)
          if !pick.try(:win).nil?
            pick.win == true ? wins += 1 : losses += 1
            if pick.tie
              losses -= 1
            end
          end
        elsif game.line > 0 && away_fav
          pick = user.pickem_pick_by_game(game)
          if !pick.try(:win).nil?
            pick.win == true ? wins += 1 : losses += 1
            if pick.tie
              losses -= 1
            end
          end
        end
      end
    end

    return "(#{wins}-#{losses})"
  end

  def get_user_record_on_favorites_picked(year, start_week, end_week)
    home_fav = false
    home_dog = false
    away_fav = false
    away_dog = false
    wins = 0
    losses = 0
    user = User.find(user_id)
    g = Game.find(game_id)

    if g.line < 0 && g.home_team_id == team_id
      home_fav = true
    elsif g.line < 0 && g.away_team_id == team_id
      away_dog = true
    elsif g.line > 0 && g.home_team_id == team_id
      home_dog = true
    elsif g.line > 0 && g.away_team_id == team_id
      away_fav = true
    end

    Game.where("year = ? and week >= ? and week <= ?", year, start_week, end_week).map do |game|
      if !game.home_score.nil? && !game.away_score.nil?
        pick = user.pickem_pick_by_game(game)
        if !pick.try(:win).nil?
          # home favorites
          if game.line < 0 && home_fav && pick.team_id == game.home_team_id
              pick.win == true ? wins += 1 : losses += 1
              if pick.tie
                losses -= 1
              end
          elsif game.line > 0 && home_dog && pick.team_id == game.home_team_id
            pick.win == true ? wins += 1 : losses += 1
            if pick.tie
              losses -= 1
            end
          elsif game.line > 0 && away_fav && pick.team_id == game.away_team_id
            pick.win == true ? wins += 1 : losses += 1
            if pick.tie
              losses -= 1
            end
          elsif game.line < 0 && away_dog && pick.team_id == game.away_team_id
            pick.win == true ? wins += 1 : losses += 1
            if pick.tie
              losses -= 1
            end
          end
        end
      end
    end

    return "(#{wins}-#{losses})"
  end

  def get_user_record_on_conference(year, start_week, end_week)
    wins = 0
    losses = 0
    g = Game.find(game_id)
    user = User.find(user_id)

    Game.where("year = ? and week >= ? and week <= ?", year, start_week, end_week).map do |game|
      # compare the divisions to the pick
      if game.away_team.conference == g.away_team.conference && game.home_team.conference == g.home_team.conference
        pick = user.pickem_pick_by_game(game)
        if !pick.try(:win).nil?
          pick.win == true ? wins += 1 : losses += 1
          if pick.tie
            losses -= 1
          end
        end
      end
    end

    return "(#{wins}-#{losses})"
  end

  def get_user_record_on_division(year, start_week, end_week)
    wins = 0
    losses = 0
    g = Game.find(game_id)
    user = User.find(user_id)

    Game.where("year = ? and week >= ? and week <= ?", year, start_week, end_week).map do |game|
      # compare the divisions to the pick
      if game.away_team.conference == g.away_team.conference && game.away_team.division == g.away_team.division &&
         game.home_team.conference == g.home_team.conference && game.home_team.division == g.home_team.division

        pick = user.pickem_pick_by_game(game)
        if !pick.try(:win).nil?
          pick.win == true ? wins += 1 : losses += 1
          if pick.tie
            losses -= 1
          end
        end

      end
    end

    return "(#{wins}-#{losses})"
  end

  def get_user_record_on_time(year, start_week, end_week)
    wins = 0
    losses = 0
    g = Game.find(game_id)
    user = User.find(user_id)

    Game.where("year = ? and week >= ? and week <= ?", year, start_week, end_week).map do |game|
      # compare the divisions to the pick
      if game.date.strftime("%A") == g.date.strftime("%A") && game.date.strftime("%H") == g.date.strftime("%H")
        pick = user.pickem_pick_by_game(game)
        if !pick.try(:win).nil?
          pick.win == true ? wins += 1 : losses += 1
          if pick.tie
            losses -= 1
          end
        end
      end
    end

    return "(#{wins}-#{losses})"
  end
end
