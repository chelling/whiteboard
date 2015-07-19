class WinPoolLeague < ActiveRecord::Base
  has_many :win_pool_picks

  validates :name, :uniqueness => {:scope => :year}
  #attr_accessor :name, :year

  # methods
  def draft_recap
    draft_picks = []

    self.win_pool_picks.order('starting_position DESC').each do |pick|
      draft_recap_string(draft_picks, pick.starting_position, pick.team_one, pick.user.name)
      draft_recap_string(draft_picks, TEAM_TWO_PICKS[pick.starting_position-1], pick.team_two, pick.user.name)
      draft_recap_string(draft_picks, TEAM_THREE_PICKS[pick.starting_position-1], pick.team_three, pick.user.name)
    end

    return draft_picks
  end

  def draft_recap_string(draft_picks, pick_number, team, user_name)
    draft_picks[pick_number - 1] = "#{pick_number}) #{team.try(:name)} #{team.try(:record_formatted, year)} (#{user_name})"
  end

  def standings
    record_list = Hash.new
    standings_list = []
    self.win_pool_picks.each do |pick|
      wins = pick.team_one.try(:wins_by_year,year).to_i + pick.team_two.try(:wins_by_year,year).to_i +
             pick.team_three.try(:wins_by_year,year).to_i
      record_list[pick.id] = wins
    end

    sorted_records = record_list.sort_by &:last
    reversed_sort = Hash[sorted_records.to_a.reverse]

    reversed_sort.each do |key, value|
      pick = self.win_pool_picks.find(key)
      standings_list << pick
    end

    return standings_list
  end

  def get_current_pick
    current_pick = 33
    self.win_pool_picks.order('starting_position DESC').each do |pick|
      if pick.team_one.nil? && current_pick > pick.starting_position
        current_pick = pick.starting_position
      elsif pick.team_two.nil? && current_pick > TEAM_TWO_PICKS[pick.starting_position-1]
        current_pick = TEAM_TWO_PICKS[pick.starting_position-1]
      elsif pick.team_three.nil? && current_pick > TEAM_THREE_PICKS[pick.starting_position-1]
        current_pick = TEAM_THREE_PICKS[pick.starting_position-1]
      end
    end

    return current_pick
  end

  def get_current_user
    user = nil
    self.win_pool_picks.order('starting_position DESC').each do |pick|
      if pick.team_one.nil? && current_pick > pick.starting_position
        user = pick.user
      elsif pick.team_two.nil? && current_pick > TEAM_TWO_PICKS[pick.starting_position-1]
        user = pick.user
      elsif pick.team_three.nil? && current_pick > TEAM_THREE_PICKS[pick.starting_position-1]
        user = pick.user
      end
    end

    return user
  end

  def teams_remaining
    teams = []
    picked_teams = []
    current_teams = Team.order("Name ASC")

    self.win_pool_picks.each do |pick|
      picked_teams << pick.team_one unless pick.team_one.nil?
      picked_teams << pick.team_two unless pick.team_two.nil?
      picked_teams << pick.team_three unless pick.team_three.nil?
    end

    current_teams.map do |t|
      teams << t unless picked_teams.include?(t)
    end

    return teams
  end
end
