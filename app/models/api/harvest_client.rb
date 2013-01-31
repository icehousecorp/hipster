class Api::HarvestClient
  attr_accessor :client
  def initialize(user)
    @client = Harvest.client(user.harvest_subdomain, user.harvest_username, user.harvest_password)
  end

  def all_projects
    @client.projects.all
  end

  def all_users(project_id)
    assignments = @client.user_assignments.all(project_id)
    users = @client.users.all
    assigned_users = []
    assignments.each do |a|
      assigned_users << users.select {|u| u.id == a.user_id}.first
    end
    assigned_users
  end

  def create(task_name, project_id)
    task = Harvest::Task.new
    task.name = task_name
    task = @client.tasks.create(task)
    assignment = Harvest::TaskAssignment.new
    assignment.task_id = task.id
    assignment.project_id = project_id
    @client.task_assignments.create(assignment)
    task
  end

  def start_task(task_id, harvest_project_id, user_id)
    entries = find_entry(user_id, task_id)
    if entries.empty?
      entry = Harvest::TimeEntry.new
      entry.project_id = harvest_project_id
      entry.task_id = task_id
      entry.user_id = user_id
      @client.time.create(entry)
    end
  end

  def stop_task(task_id, user_id)
    entries = find_entry(user_id, task_id)
    @client.time.toggle(entries.first.id, user_id) unless entries.empty?
  end

  def find_entry(user_id, task_id)
    puts "finding entry for user: #{user_id} and task_id: #{task_id}"
    entries = @client.time.all(Time.now, user_id).select do |entry|
      puts '------------'
      puts entry.task_id
      puts entry.ended_at
      puts entry.task_id.to_i == task_id.to_i && entry.ended_at.blank?
      puts '------------'
      entry.task_id.to_i == task_id.to_i && entry.ended_at.blank?
    end
  end
end

module Harvest
  module API
    class Time < Base
      def toggle(id, user=nil)
        response = request(:get, credentials, "/daily/timer/#{id.to_i}", query: of_user_query(user))
        Harvest::TimeEntry.parse(response.parsed_response).first
      end
    end
  end
end

class Harvest::User
  def name
    "#{first_name} #{last_name}"
  end
end