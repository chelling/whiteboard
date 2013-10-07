class Game < ActiveRecord::Base
  belongs_to :away_team, :class_name => "Team"
  belongs_to :home_team, :class_name => "Team"
  has_many :pickem_picks
  has_many :fooicide_picks

  after_save :update_pickem_wins
  after_save :update_fooicide_picks
  after_save :update_team_records
  
  attr_accessible :away_score, :date, :home_score, :location, :week, :year, :away_team_id, :home_team_id , :line
  accepts_nested_attributes_for :pickem_picks, :away_team, :home_team

  # global variables
  def self.divisional_binary
    divisional_matchup_binary = {
        "ne_v_ne" => 0b10001, "ne_v_nn" => 0b10010, "ne_v_ns" => 0b10011, "ne_v_nw" => 0b10100,
        "ne_v_ae" => 0b10101, "ne_v_an" => 0b10110, "ne_v_as" => 0b10111, "ne_v_aw" => 0b11000,
        "nn_v_ne" => 0b100001, "nn_v_nn" => 0b100010, "nn_v_ns" => 0b100011, "nn_v_nw" => 0b100100,
        "nn_v_ae" => 0b100101, "nn_v_an" => 0b100110, "nn_v_as" => 0b100111, "nn_v_aw" => 0b101000,
        "ns_v_ne" => 0b110001, "ns_v_nn" => 0b110010, "ns_v_ns" => 0b110011, "ns_v_nw" => 0b110100,
        "ns_v_ae" => 0b110101, "ns_v_an" => 0b110110, "ns_v_as" => 0b110111, "ns_v_aw" => 0b111000,
        "nw_v_ne" => 0b1000001, "nw_v_nn" => 0b1000010, "nw_v_ns" => 0b1000011, "nw_v_nw" => 0b1000100,
        "nw_v_ae" => 0b1000101, "nw_v_an" => 0b1000110, "nw_v_as" => 0b1000111, "nw_v_aw" => 0b1001000,
        "ae_v_ne" => 0b1100001, "ae_v_nn" => 0b1100010, "ae_v_ns" => 0b1100011, "ae_v_nw" => 0b1100100,
        "ae_v_ae" => 0b1100101, "ae_v_an" => 0b1100110, "ae_v_as" => 0b1100111, "ae_v_aw" => 0b1101000,
        "an_v_ne" => 0b10000001, "an_v_nn" => 0b10000010, "an_v_ns" => 0b10000011, "an_v_nw" => 0b10000100,
        "an_v_ae" => 0b10000101, "an_v_an" => 0b10000110, "an_v_as" => 0b10000111, "an_v_aw" => 0b10001000,
        "as_v_ne" => 0b11000001, "as_v_nn" => 0b11000010, "as_v_ns" => 0b11000011, "as_v_nw" => 0b11000100,
        "as_v_ae" => 0b11000101, "as_v_an" => 0b11000110, "as_v_as" => 0b11000111, "as_v_aw" => 0b11001000,
        "aw_v_ne" => 0b100000001, "aw_v_nn" => 0b100000010, "aw_v_ns" => 0b100000011, "aw_v_nw" => 0b100000100,
        "aw_v_ae" => 0b100000101, "aw_v_an" => 0b100000110, "aw_v_as" => 0b100000111, "aw_v_aw" => 0b100001000
    }
  end

  def self.divisional_names
    divisional_matchup_names = {
        "ne_v_ne" => "NFC East vs. NFC East", "ne_v_nn" => "NFC East vs. NFC North",
        "ne_v_ns" => "NFC East vs. NFC South", "ne_v_nw" => "NFC East vs. NFC West",
        "ne_v_ae" => "NFC East vs. AFC East", "ne_v_an" => "NFC East vs. AFC North",
        "ne_v_as" => "NFC East vs. AFC South", "ne_v_aw" => "NFC East vs. AFC West",
        "nn_v_ne" => "NFC North vs. NFC East", "nn_v_nn" => "NFC North vs. NFC North",
        "nn_v_ns" => "NFC North vs. NFC South", "nn_v_nw" => "NFC North vs. NFC West",
        "nn_v_ae" => "NFC North vs. AFC East", "nn_v_an" => "NFC North vs. AFC North",
        "nn_v_as" => "NFC North vs. AFC South", "nn_v_aw" => "NFC North vs. AFC West",
        "ns_v_ne" => "NFC South vs. NFC East", "ns_v_nn" => "NFC South vs. NFC North",
        "ns_v_ns" => "NFC South vs. NFC South", "ns_v_nw" => "NFC South vs. NFC West",
        "ns_v_ae" => "NFC South vs. AFC East", "ns_v_an" => "NFC South vs. AFC North",
        "ns_v_as" => "NFC South vs. AFC South", "ns_v_aw" => "NFC South vs. AFC West",
        "nw_v_ne" => "NFC West vs. NFC East", "nw_v_nn" => "NFC West vs. NFC North",
        "nw_v_ns" => "NFC West vs. NFC South", "nw_v_nw" => "NFC West vs. NFC West",
        "nw_v_ae" => "NFC West vs. AFC East", "nw_v_an" => "NFC West vs. AFC North",
        "nw_v_as" => "NFC West vs. AFC South", "nw_v_aw" => "NFC West vs. AFC West",
        "ae_v_ne" => "AFC East vs. NFC East", "ae_v_nn" => "AFC East vs. NFC North",
        "ae_v_ns" => "AFC East vs. NFC South", "ae_v_nw" => "AFC East vs. NFC West",
        "ae_v_ae" => "AFC East vs. AFC East", "ae_v_an" => "AFC East vs. AFC North",
        "ae_v_as" => "AFC East vs. AFC South", "ae_v_aw" => "AFC East vs. AFC West",
        "an_v_ne" => "AFC North vs. NFC East", "an_v_nn" => "AFC North vs. NFC North",
        "an_v_ns" => "AFC North vs. NFC South", "an_v_nw" => "AFC North vs. NFC West",
        "an_v_ae" => "AFC North vs. AFC East", "an_v_an" => "AFC North vs. AFC North",
        "an_v_as" => "AFC North vs. AFC South", "an_v_aw" => "AFC North vs. AFC West",
        "as_v_ne" => "AFC South vs. NFC East", "as_v_nn" => "AFC South vs. NFC North",
        "as_v_ns" => "AFC South vs. NFC South", "as_v_nw" => "AFC South vs. NFC East",
        "as_v_ae" => "AFC South vs. NFC East", "as_v_an" => "AFC South vs. NFC North",
        "as_v_as" => "AFC South vs. NFC South", "as_v_aw" => "AFC South vs. NFC East",
        "aw_v_ne" => "AFC West vs. NFC East", "aw_v_nn" => "AFC West vs. NFC North",
        "aw_v_ns" => "AFC West vs. NFC South", "aw_v_nw" => "AFC West vs. NFC East",
        "aw_v_ae" => "AFC West vs. NFC East", "aw_v_an" => "AFC West vs. NFC North",
        "aw_v_as" => "AFC West vs. NFC South", "aw_v_aw" => "AFC West vs. NFC East"
    }
  end

  # methods
  def date_eastern
    date.try(:in_time_zone, 'Eastern Time (US & Canada)')
  end

  def in_progress_or_complete?
      Time.now.in_time_zone('Eastern Time (US & Canada)') - 4 * 60 * 60 > date_eastern
  end
  
  # hooks
  def update_pickem_wins
    team_id = 0
    if !away_score.nil? && !home_score.nil?
      if away_score - home_score > line
        team_id = away_team_id
      elsif away_score - home_score < line
        team_id = home_team_id
      end
      # update all user picks for this game
      User.all.map do |user|
        pick = user.pickem_pick_by_game_id(id)
        if !pick.nil?
          if pick.try(:team_id) == team_id
            pick.win = true
            pick.tie = false
          elsif team_id == 0
            pick.win = false
            pick.tie = true
          else
            pick.win = false
            pick.tie = false
          end
          pick.save
        end
      end
    else
      User.all.map do |user|
        pick = user.pickem_pick_by_game_id(id)
        if !pick.nil?
          pick.win = nil
          pick.tie = nil
          pick.save
        end
      end
    end
  end

  def update_fooicide_picks
    team_id = 0
    if !home_score.nil? && !away_score.nil?
      if home_score > away_score
        team_id = home_team_id
      elsif away_score > home_score
        team_id = away_team_id
      end
    end

    User.all.map do |user|
      pick = user.fooicide_pick_by_game_id(id)
      if !pick.nil?
        if team_id != 0 && pick.try(:team_id) == team_id
          pick.win = true
        elsif team_id != 0
          pick.win = false
        else
          pick.win = nil
        end
        pick.save
      end
    end
  end

  def update_team_records
    away_team.try(:update_records_by_year, year)
    home_team.try(:update_records_by_year, year)
  end

  def home_win?
    home_score > away_score ? true : false
  end

  def away_win?
    home_score < away_score ? true : false
  end

  def home_cover?
    home_score + line > away_score ? true : false
  end

  def away_cover?
    home_score + line < away_score ? true : false
  end

  def division_matchup
    home = 0
    away = 0
    if home_team.conference == 'NFC' && home_team.division == 'EAST'
      home = 0b1
    elsif home_team.conference == 'NFC' && home_team.division == 'NORTH'
      home = 0b10
    elsif home_team.conference == 'NFC' && home_team.division == 'SOUTH'
      home = 0b11
    elsif home_team.conference == 'NFC' && home_team.division == 'WEST'
      home = 0b100
    elsif home_team.conference == 'AFC' && home_team.division == 'EAST'
      home = 0b101
    elsif home_team.conference == 'AFC' && home_team.division == 'NORTH'
      home = 0b110
    elsif home_team.conference == 'AFC' && home_team.division == 'SOUTH'
      home = 0x111
    elsif home_team.conference == 'AFC' && home_team.division == 'WEST'
      home = 0b1000
    end

    if away_team.conference == 'NFC' && away_team.division == 'EAST'
      away = 0b10000
    elsif away_team.conference == 'NFC' && away_team.division == 'NORTH'
      away = 0b100000
    elsif away_team.conference == 'NFC' && away_team.division == 'SOUTH'
      away = 0b110000
    elsif away_team.conference == 'NFC' && away_team.division == 'WEST'
      away = 0b1000000
    elsif away_team.conference == 'AFC' && away_team.division == 'EAST'
      away = 0b1100000
    elsif away_team.conference == 'AFC' && away_team.division == 'NORTH'
      away = 0b10000000
    elsif away_team.conference == 'AFC' && away_team.division == 'SOUTH'
      away = 0x11000000
    elsif away_team.conference == 'AFC' && away_team.division == 'WEST'
      away = 0b100000000
    end

    return home + away
  end

  def self.conference_stats(year)
    nfc_v_nfc_win = 0
    nfc_v_nfc_loss = 0
    afc_v_afc_win = 0
    afc_v_afc_loss = 0
    nfc_v_afc_win = 0
    nfc_v_afc_loss = 0
    afc_v_nfc_win = 0
    afc_v_nfc_loss = 0
    output = []
    Game.find_all_by_year(year).map do |game|
      if !game.home_score.nil? && !game.away_score.nil?
        if game.away_team.conference == 'NFC' && game.home_team.conference == 'NFC'
          game.home_cover? ? nfc_v_nfc_win += 1 : ""
          game.away_cover? ? nfc_v_nfc_loss += 1 : ""
        elsif game.away_team.conference == 'AFC' && game.home_team.conference == 'AFC'
          game.home_cover? ? afc_v_afc_win += 1 : ""
          game.away_cover? ? afc_v_afc_loss += 1 : ""
        elsif game.away_team.conference == 'AFC' && game.home_team.conference == 'NFC'
          game.home_cover? ? afc_v_nfc_win += 1 : ""
          game.away_cover? ? afc_v_nfc_loss += 1 : ""
        elsif game.away_team.conference == 'NFC' && game.home_team.conference == 'AFC'
          game.home_cover? ? nfc_v_afc_win += 1 : ""
          game.away_cover? ? nfc_v_afc_loss += 1 : ""
        end
      end
    end

    output.push("NFC vs. NFC (away cover-home cover): (#{nfc_v_nfc_loss}-#{nfc_v_nfc_win})")
    output.push("AFC vs. AFC (away cover-home cover): (#{afc_v_afc_loss}-#{afc_v_afc_win})")
    output.push("AFC vs. NFC (away cover-home cover): (#{afc_v_nfc_loss}-#{afc_v_nfc_win})")
    output.push("NFC vs. AFC (away cover-home cover): (#{nfc_v_afc_loss}-#{nfc_v_afc_win})")
    return output
  end

  def self.user_conference_stats(year,user_id)
    user = User.find(user_id)
    nfc_v_nfc_win = 0
    nfc_v_nfc_loss = 0
    afc_v_afc_win = 0
    afc_v_afc_loss = 0
    nfc_v_afc_win = 0
    nfc_v_afc_loss = 0
    afc_v_nfc_win = 0
    afc_v_nfc_loss = 0
    output = []
    Game.find_all_by_year(year).map do |game|
      pick = user.pickem_pick_by_game_id(game.id)
      pick.nil? ? next : ""
      if !game.home_score.nil? && !game.away_score.nil?
        if game.away_team.conference == 'NFC' && game.home_team.conference == 'NFC'
          pick.win == true ? nfc_v_nfc_win += 1 : nfc_v_nfc_loss += 1
          pick.tie == true ? nfc_v_nfc_loss -= 1 : ""
        elsif game.away_team.conference == 'AFC' && game.home_team.conference == 'AFC'
          pick.win == true ? afc_v_afc_win += 1 : afc_v_afc_loss += 1
          pick.tie == true ? afc_v_afc_loss -= 1 : ""
        elsif game.away_team.conference == 'AFC' && game.home_team.conference == 'NFC'
          pick.win == true ? afc_v_nfc_win += 1 : afc_v_nfc_loss += 1
          pick.tie == true ? afc_v_nfc_loss -= 1 : ""
        elsif game.away_team.conference == 'NFC' && game.home_team.conference == 'AFC'
          pick.win == true ? nfc_v_afc_win += 1 : nfc_v_afc_loss += 1
          pick.tie == true ? nfc_v_afc_loss -= 1 : ""
        end
      end
    end

    output.push("NFC vs. NFC: (#{nfc_v_nfc_win}-#{nfc_v_nfc_loss}) #{((nfc_v_nfc_win.to_f / (nfc_v_nfc_win + nfc_v_nfc_loss)) * 100).to_i}%") unless (nfc_v_nfc_win + nfc_v_nfc_loss) <= 0
    output.push("AFC vs. AFC: (#{afc_v_afc_win}-#{afc_v_afc_loss}) #{((afc_v_nfc_win.to_f / (afc_v_afc_win + afc_v_afc_loss)) * 100).to_i}%") unless (afc_v_afc_win + afc_v_afc_loss) <= 0
    output.push("AFC vs. NFC: (#{afc_v_nfc_win}-#{afc_v_nfc_loss}) #{((afc_v_nfc_win.to_f / (afc_v_nfc_win + afc_v_nfc_loss)) * 100).to_i}%") unless (afc_v_nfc_win + afc_v_nfc_loss) <= 0
    output.push("NFC vs. AFC: (#{nfc_v_afc_win}-#{nfc_v_afc_loss}) #{((nfc_v_afc_win.to_f / (nfc_v_afc_win + nfc_v_afc_loss)) * 100).to_i}%") unless (nfc_v_afc_win + nfc_v_afc_loss) <= 0

    return output
  end

  def self.division_stats(year)
    division = Hash.new
    output = []

    Game.find_all_by_year(year).map do |game|
      if !game.home_score.nil? && !game.away_score.nil?
        if game.home_cover? == true
          if division[Game.divisional_binary.rassoc(game.division_matchup).first + "__h"]
            division[Game.divisional_binary.rassoc(game.division_matchup).first + "__h"] += 1
          else
            division[Game.divisional_binary.rassoc(game.division_matchup).first + "__h"] = 1
          end
        elsif game.away_cover? == true
          if division[Game.divisional_binary.rassoc(game.division_matchup).first + "__a"]
            division[Game.divisional_binary.rassoc(game.division_matchup).first + "__a"] += 1
          else
            division[Game.divisional_binary.rassoc(game.division_matchup).first + "__a"] = 1
          end
        end
      end
    end

    division.each do |key, value|
      wins = 0
      losses = 0
      matchup = key.split("__")
      if matchup[1] == "h"
        losses = value
        wins = division[matchup[0] + "__a"] unless division[matchup[0] + "__a"].nil?
        division.delete(matchup[0] + "__a")
        output.push("#{Game.divisional_names[matchup[0]]}: (#{wins}-#{losses}) #{((wins.to_f / (wins + losses)) * 100).to_i}%") unless (wins + losses) <= 0
      elsif matchup[1] == "a"
        wins = value
        losses = division[matchup[0] + "__h"] unless division[matchup[0] + "__h"].nil?
        division.delete(matchup[0] + "__h")
        output.push("#{Game.divisional_names[matchup[0]]}: (#{wins}-#{losses}) #{((wins.to_f / (wins + losses)) * 100).to_i}%") unless (wins + losses) <= 0
      end
    end

    puts output
  end

  def self.game_stats(year)
    home_dog_win = 0
    away_dog_win = 0
    home_dog_loss = 0
    away_dog_loss = 0
    home_fav_win = 0
    home_fav_loss = 0
    away_fav_win = 0
    away_fav_loss = 0
    output = []
    Game.find_all_by_year(year).map do |game|
      if !game.home_score.nil? && !game.away_score.nil?
        # home favorites
        if game.line < 0
          if game.home_cover?
            home_fav_win += 1
            away_dog_loss += 1
          elsif game.away_cover?
            home_fav_loss += 1
            away_dog_win += 1
          end
        elsif game.line > 0 # home underdogs
          if game.home_cover?
            home_dog_win += 1
            away_fav_loss += 1
          elsif game.away_cover?
            home_dog_loss += 1
            away_fav_win += 1
          end
        end
      end
    end
    output.push("Home Favorites: (#{home_fav_win}-#{home_fav_loss}) #{((home_fav_win.to_f / (home_fav_win + home_fav_loss)) * 100).to_i}%") unless (home_fav_win + home_fav_loss) <= 0
    output.push("Away Favorites: (#{away_fav_win}-#{away_fav_loss}) #{((away_fav_win.to_f / (away_fav_win + away_fav_loss)) * 100).to_i}%") unless (away_fav_win + away_fav_loss) <= 0
    return output
  end

  def self.user_home_away_stats(year, user_id)
    user = User.find(user_id)
    home_dog_win = 0
    away_dog_win = 0
    home_dog_loss = 0
    away_dog_loss = 0
    home_fav_win = 0
    home_fav_loss = 0
    away_fav_win = 0
    away_fav_loss = 0
    home_dog_win_picked = 0
    away_dog_win_picked = 0
    home_dog_loss_picked = 0
    away_dog_loss_picked = 0
    home_fav_win_picked = 0
    home_fav_loss_picked = 0
    away_fav_win_picked = 0
    away_fav_loss_picked = 0
    output = []
    Game.find_all_by_year(year).map do |game|
      if !game.home_score.nil? && !game.away_score.nil?
        pick = user.pickem_pick_by_game_id(game.id)
        # home favorites
        if game.line < 0 && pick
          if pick.win == true
            home_fav_win += 1
            away_dog_win += 1
          elsif pick.win == false
            home_fav_loss += 1
            away_dog_loss += 1
          end
          if game.home_cover?
            if pick.team_id == game.home_team_id
              home_fav_win_picked += 1
            else
              away_dog_loss_picked += 1
            end
          elsif game.away_cover?
            if pick.team_id == game.home_team_id
              home_fav_loss_picked += 1
            else
              away_dog_win_picked += 1
            end
          end
        elsif game.line > 0 && pick # home underdogs
          if pick.win == true
            home_dog_win += 1
            away_fav_win += 1
          elsif pick.win == false
            home_dog_loss += 1
            away_fav_loss += 1
          end
          if game.home_cover?
            if pick.team_id == game.home_team_id
              home_dog_win_picked += 1
            else
              away_fav_loss_picked += 1
            end
          elsif game.away_cover?
            if pick.team_id == game.home_team_id
              home_dog_loss_picked += 1
            else
              away_fav_win_picked += 1
            end
          end
        end
      end
    end
    output.push("Home Favorites: (#{home_fav_win}-#{home_fav_loss}) #{((home_fav_win.to_f / (home_fav_win + home_fav_loss)) * 100).to_i}%") unless (home_fav_win + home_fav_loss) <= 0
    output.push("Away Favorites: (#{away_fav_win}-#{away_fav_loss}) #{((away_fav_win.to_f / (away_fav_win + away_fav_loss)) * 100).to_i}%") unless (away_fav_win + away_fav_loss) <= 0
    output.push("Home Favorite Picked: (#{home_fav_win_picked}-#{home_fav_loss_picked}) #{((home_fav_win_picked.to_f / (home_fav_win_picked + home_fav_loss_picked)) * 100).to_i}%") unless (home_fav_win_picked + home_fav_loss_picked) <= 0
    output.push("Away Favorite Picked: (#{away_fav_win_picked}-#{away_fav_loss_picked}) #{((away_fav_win_picked.to_f / (away_fav_win_picked + away_fav_loss_picked)) * 100).to_i}%") unless (away_fav_win_picked + away_fav_loss_picked) <= 0
    output.push("Home Underdog Picked: (#{home_dog_win_picked}-#{home_dog_loss_picked}) #{((home_dog_win_picked.to_f / (home_dog_win_picked + home_dog_loss_picked)) * 100).to_i}%") unless (home_dog_win_picked + home_dog_loss_picked) <= 0
    output.push("Away Underdog Picked: (#{away_dog_win_picked}-#{away_dog_loss_picked}) #{((away_dog_win_picked.to_f / (away_dog_win_picked + away_dog_loss_picked)) * 100).to_i}%") unless (away_dog_win_picked + away_dog_loss_picked) <= 0
    return output
  end

  def self.user_team_stats(year, user_id)
    user = User.find(user_id)
    output = []
    Team.all.map do |team|
      wins = 0
      losses = 0
      wins_picked = 0
      losses_picked = 0
      # find home teams
      Game.find_all_by_year_and_home_team_id(year,team.id).map do |game|
        pick = user.pickem_pick_by_game_id(game.id)
        if pick && pick.win == true
          wins += 1
          if pick.team_id == team.id
            wins_picked += 1
          end
        elsif pick && pick.win == false
          losses += 1
          if pick.team_id == team.id
            losses_picked += 1
          end
        end
      end
      # find away teams
      Game.find_all_by_year_and_away_team_id(year,team.id).map do |game|
        pick = user.pickem_pick_by_game_id(game.id)
        if pick && pick.win == true
          wins += 1
          if pick.team_id == team.id
            wins_picked += 1
          end
        elsif pick && pick.win == false
          losses += 1
          if pick.team_id == team.id
            losses_picked += 1
          end
        end
      end
      output.push("Games with #{team.name}: (#{wins}-#{losses}) #{((wins.to_f / (wins + losses)) * 100).to_i}%") unless (wins + losses) <= 0
      output.push("Picking #{team.name}: (#{wins_picked}-#{losses_picked}) #{((wins_picked.to_f / (wins_picked + losses_picked)) * 100).to_i}%\n\n") unless (wins_picked + losses_picked) <= 0
    end
    return output
  end

  def self.spread2011
    year = 0
    week = 0
    date = nil
    File.open("#{Rails.root}/public/spread2011.csv").each do |line|
      game = line.split(',')
      # Update the week
      if game.first == 'Week'
        week = game.last
      else
        date = game[0].split('/')
        time = game[1].split(':')
        time[0].to_i == 12 ? hour = time[0].to_i : hour = time[0].to_i + 12
        game_date = DateTime.new(date[2].to_i,date[0].to_i,date[1].to_i,hour,time[1].to_i)
        year = date[2]
        away_team = Team.team_id_from_string(game[2].tr('"','').upcase)
        puts away_team
        home_team = Team.team_id_from_string(game[3].tr('"','').upcase)
        puts home_team
        game_line = game[4]
        david_pick = game[6].tr('"','').upcase
        clint_pick = game[7].tr('"','').upcase
        nic_pick = game[8].tr('"','').upcase
        nick_pick = game[9].tr('"','').upcase
        away_score = game[11]
        home_score = game[12]
        g = Game.create(:year => year.to_i, :week => week.to_i, :home_team_id => home_team, :away_team_id => away_team, :line => game_line.to_f,
                    :date => game_date, :location => Team.find(home_team).location, :home_score => home_score.to_i, :away_score => away_score.to_i)
        if david_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(david_pick), :game_id => g.id, :user_id => 2)
        end
        if clint_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(clint_pick), :game_id => g.id, :user_id => 1)
        end
        if nic_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(nic_pick), :game_id => g.id, :user_id => 6)
        end
        if nick_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(nick_pick), :game_id => g.id, :user_id => 3)
        end
        g.save
      end
    end
  end

  def self.spread2012
    year = 0
    week = 0
    date = nil
    File.open("#{Rails.root}/public/spread2012.csv").each do |line|
      game = line.split(',')
      # Update the week
      if game.first == 'Week'
        week = game.last
      else
        date = game[0].split('/')
        time = game[1].split(':')
        time[0].to_i == 12 ? hour = time[0].to_i : hour = time[0].to_i + 12
        game_date = DateTime.new(date[2].to_i,date[0].to_i,date[1].to_i,hour,time[1].to_i)
        year = date[2]
        away_team = Team.team_id_from_string(game[2].tr('"','').upcase)
        puts away_team
        home_team = Team.team_id_from_string(game[3].tr('"','').upcase)
        puts home_team
        game_line = game[4]
        david_pick = game[7].tr('"','').upcase
        clint_pick = game[8].tr('"','').upcase
        nic_pick = game[9].tr('"','').upcase
        nick_pick = game[10].tr('"','').upcase
        gary_pick = game[11].tr('"','').upcase
        away_score = game[12]
        home_score = game[13]
        g = Game.create(:year => year.to_i, :week => week.to_i, :home_team_id => home_team, :away_team_id => away_team, :line => game_line.to_f,
                        :date => game_date, :location => Team.find(home_team).location, :home_score => home_score.to_i, :away_score => away_score.to_i)
        if david_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(david_pick), :game_id => g.id, :user_id => 2)
        end
        if clint_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(clint_pick), :game_id => g.id, :user_id => 1)
        end
        if nic_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(nic_pick), :game_id => g.id, :user_id => 6)
        end
        if nick_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(nick_pick), :game_id => g.id, :user_id => 3)
        end
        if gary_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(gary_pick), :game_id => g.id, :user_id => 10)
        end
        g.save
      end
    end
  end
end
