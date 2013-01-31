class CreateTaskStories < ActiveRecord::Migration
  def change
    create_table :task_stories do |t|
      t.integer :task_id
      t.integer :story_id

      t.timestamps
    end
  end
end
