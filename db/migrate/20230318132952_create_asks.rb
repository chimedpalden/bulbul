class CreateAsks < ActiveRecord::Migration[6.1]
  def change
    create_table :asks do |t|
      t.string :question, null: false
      t.text :answer
      t.text :context
      t.integer :ask_count, default: 1

      t.timestamps
    end
  end
end
