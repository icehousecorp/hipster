require "spec_helper"

describe Project do

	it {should have_many(:people).through(:person_mappings)}
	it {should have_many(:person_mappings).dependent(:destroy)}
	it {should belong_to :user}
	it {should allow_mass_assignment_of(:harvest_project_id)}
	it {should allow_mass_assignment_of(:pivotal_project_id)}
	it {should allow_mass_assignment_of(:user_id)}
	it {should allow_mass_assignment_of(:harvest_project_name)}
	it {should allow_mass_assignment_of(:pivotal_project_name)}
	it {should allow_mass_assignment_of(:project_name)}
	it {should allow_mass_assignment_of(:client_id)}
	it {should allow_mass_assignment_of(:client_name)}
	it {should allow_mass_assignment_of(:harvest_project_code)}
	it {should allow_mass_assignment_of(:harvest_billable)}
	it {should allow_mass_assignment_of(:harvest_budget)}
	it {should allow_mass_assignment_of(:pivotal_start_iteration)}
	it {should allow_mass_assignment_of(:pivotal_start_date)}
	it {should allow_mass_assignment_of(:person_ids)}
	it {should allow_mass_assignment_of(:create_method)}

	# it {should validate_presence_of(:harvest_email)}
	# it {should validate_presence_of(:harvest_name)}
	# it {should validate_presence_of(:pivotal_email)}
	# it {should_not allow_value("bleh").for(:harvest_email)}
	# it {should_not allow_value("bleh").for(:pivotal_email)}
	# it {should allow_value("bl@eh.com").for(:harvest_email)}
	# it {should allow_value("bl@eh.com").for(:pivotal_email)}
	describe '#prepare_create' do
		it "assign project name to pivotal and harvest project name" do
			proj = Project.new(project_name:"propo")
			proj.prepare_create
			proj.harvest_project_name.should == "propo"
			proj.pivotal_project_name.should == "propo"
		end
	end
end