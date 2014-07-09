class WinPoolLeague < ActiveRecord::Base
  has_many :win_pool_picks

  validates :name, :uniqueness => {:scope => :year}
  attr_accessible :name, :year

  # methods
  def draft_recap(year)
    draft_picks = []

    self.win_pool_picks.order('starting_position DESC').each do |pick|
      draft_recap_string(draft_picks, pick.starting_position, pick.team_one, pick.user.name, year)
      draft_recap_string(draft_picks, TEAM_TWO_PICKS[pick.starting_position-1], pick.team_two, pick.user.name, year)
      draft_recap_string(draft_picks, TEAM_THREE_PICKS[pick.starting_position-1], pick.team_three, pick.user.name, year)
    end

    return draft_picks
  end

  def draft_recap_string(draft_picks, pick_number, team, user_name, year)
    draft_picks[pick_number - 1] = "#{pick_number}) #{team.try(:name)} #{team.try(:record_formatted, year)} (#{user_name})"
  end

  def standings(year)
    record_list = Hash.new
    standings_list = Hash.new
    self.win_pool_picks.each do |pick|
      wins = pick.team_one.wins_by_year(year) + pick.team_two.wins_by_year(year) + pick.team_three.wins_by_year(year)
      record_list[pick.id] = wins
    end

    sorted_records = record_list.sort_by &:last

    sorted_records.each do |key, value|
      pick = self.win_pool_picks.find(key)
      standings_list[pick] = value
    end

    return standings_list
  end

  def get_current_pick(year)
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

  def teams_remaining
    teams = Team.all

    self.win_pool_picks.each do |pick|
      teams.delete(pick.team_one) unless pick.team_one.nil?
      teams.delete(pick.team_two) unless pick.team_two.nil?
      teams.delete(pick.team_three) unless pick.team_three.nil?
    end

    return teams
  end
end
