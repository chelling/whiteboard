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
          pick.win == true ? afc_v_nfc_win += 1 : afc_v_nfc_loss += 1
          pick.tie == true ? afc_v_nfc_loss -= 1 : ""
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
