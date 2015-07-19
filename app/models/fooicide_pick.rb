class FooicidePick < ActiveRecord::Base
  belongs_to :user
  belongs_to :team
  belongs_to :game

  # methods
  def pick_locked?
    # check if game has started
    game = Game.find(self.game_id)
    !game.nil? && game.in_progress_or_complete? ? true : false
  end

  def already_picked?(year)

  end
end
