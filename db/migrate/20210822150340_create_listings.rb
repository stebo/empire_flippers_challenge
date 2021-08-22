class CreateListings < ActiveRecord::Migration[6.1]
  def change
    create_table :listings do |t|
      t.string :remote_id
      t.jsonb :remote_data

      t.timestamps
    end
  end
end
