class SyncStoriesJob

	@queue = :hipster_queue

	def self.perform(project_id)
		project = Project.find(project_id)
		pivotal_user = project.user
		admin_user = User.find(4)

		PivotalTracker::Client.token = pivotal_user.pivotal_token
		harvest = Harvest.token_client(admin_user.harvest_subdomain, admin_user.harvest_token, ssl: true)

		pivotal_project = PivotalTracker::Project.find(project.pivotal_project_id)

		at_pivotal = PivotalTracker::Story.all(pivotal_project).map { |x| x.id }.sort

		task_ids = harvest.task_assignments.all(project.harvest_project_id).map { |x| x.task_id }

		at_harvest = harvest.tasks.all.select { |x|
			task_ids.include? x.id
		}.map { |x| x.name.split[0].delete("[#").delete("]").to_i}.sort

		discrepancy = at_pivotal.reject { |x| at_harvest.include? x }.sort

		discrepancy.each do |story_id|
			begin
				pivotal_story = PivotalTracker::Story.find(story_id, pivotal_project.id)
				task = Harvest::Task.new
			  task.name = "[##{story_id}] #{pivotal_story.name}"
			  task = harvest.tasks.create(task)
			  assignment = Harvest::TaskAssignment.new
			  assignment.task_id = task.id
			  assignment.project_id = project.harvest_project_id
			  harvest.task_assignments.create(assignment)
			  TaskStory.create(task_id: task.id, story_id: story_id)
			rescue => ex
				puts ex.inspect
			end
		end
	end
end