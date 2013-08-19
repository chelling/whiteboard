class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all
    else
       can :read, :all
       # pickem
       can :create, PickemPick
       can [:update, :destroy], PickemPick do |pick|
         pick.try(:user) == user
       end
       # fooicide
       can :create, FooicidePick
       can [:update, :destroy], FooicidePick do |pick|
         pick.try(:user) == user
       end
       # pickem
       can :create, ThirtyEight
       can [:update, :destroy], ThirtyEight do |te|
         te.try(:user) == user
       end
    end
  end
end
