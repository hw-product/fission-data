require 'fission-data/model_base'

class User < ModelBase

  bucket :users

  value :username
  value :name
  value :updated_at, :class => Time
  value :created_at, :class => Time
  value :permissions, :class => Array

  index :username, :unique => true

  link :base_account, Account, :to => :owner
  links :accounts, Account, :to => :members
  links :identities, Identity, :to => :user, :dependent => true
  links :jobs, Job

  class << self
    def display_attributes
      [:username, :name]
    end
  end

  def create_account(name=nil)
    act = Account.new.save
    act.name = name || username
    act.owner = self
    act.save
    unless(base_account)
      self.base_account = act
      unless(self.save)
        Rails.logger.error self.errors.inspect
        raise self.errors
      end
    end
    act
  end

  def to_s
    username
  end

  def permitted?(*args)
    args.detect do |permission|
      permissions.include?(permission)
    end
  end

end
