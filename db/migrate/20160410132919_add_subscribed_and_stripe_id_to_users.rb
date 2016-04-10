class AddSubscribedAndStripeIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscribed, :boolean
    add_column :users, :stripe_id, :string
  end
end
