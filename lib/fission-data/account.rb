require 'fission-data'

class Account < ModelBase

  bucket :accounts

  value :name

  index :name, :unique => true
  link :owner, User, :to => :base_account
  links :members, User, :to => :accounts
  links :jobs, Job, :to => :account
  links :repositories, Repository, :to => :owner
  links :products, Product, :to => :enabled_accounts

  class << self
    def display_attributes
      [:name, :owner]
    end

    def restrict(user)
      ([user.base_account] + user.accounts).compact.uniq
    end
  end

  def to_s
    name
  end

end
