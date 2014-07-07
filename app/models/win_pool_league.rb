class WinPoolLeague < ActiveRecord::Base
  has_many :win_pool_picks

  validates :name, :uniqueness => {:scope => :year}
  attr_accessible :name, :year

  # methods
  def draft_recap(year)
    draft_picks = []

    self.win_pool_picks.order('starting_position DESC').each do |pick|
      draft_recap_string(draft_picks, pick.starting_position, pick.team_one, pick.user.name, year)
      draft_recap_string(draft_picks, TEAM_TWO_PICKS[pick.starting_position], pick.team_two, pick.user.name, year)
      draft_recap_string(draft_picks, TEAM_THREE_PICKS[pick.starting_position], pick.team_three, pick.user.name, year)
    end

    return draft_picks
  end

  def draft_recap_string(draft_picks, pick_number, team, user_name, year)
    draft_picks[pick_number - 1] = "#{pick_number}) #{team.name} #{team.record_formatted(year)} (#{user_name})"
  end

  def standings(year)
    record_list = Hash.new
    standings_list = Hash.new
    self.win_pool_picks.each do |pick|
      wins = pick.team_one.wins_by_year(year) + pick.team_two.wins_by_year(year) + pick.team_three.wins_by_year(year)
      record_list[pick.starting_position] = wins
    end

    sorted_records = record_list.sort_by &:last
    sorted_records.each do |key, value|
      pick = self.win_pool_picks.find_by_year_and_starting_position(year, key)
      standings_list[value] = pick
    end

    return standings_list
  end

  def get_current_pick(year)
    current_pick = -1
    draft_recap(year).each_with_index do |pick, index|
      pick.nil? ? current_pick = index : ""
    end

    return current_pick
  end

  def is_current_user_turn?(year)
    pick = self.win_pool_picks.find_by_user_id(current_user.id)
    if pick.teams_full?
      return false
    end

    current_pick = get_current_pick(year)

    if current_pick == pick.next_pick
      return true
    else
      return false
    end
  end
end
