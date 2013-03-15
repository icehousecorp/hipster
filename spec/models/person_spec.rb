require "spec_helper"

describe Person do

	it {should have_many(:projects).through(:person_mappings)}
	it {should have_many(:person_mappings).dependent(:destroy)}

	it {should validate_presence_of(:harvest_email)}
	it {should validate_presence_of(:harvest_name)}
	it {should validate_presence_of(:pivotal_email)}
	it {should_not allow_value("bleh").for(:harvest_email)}
	it {should_not allow_value("bleh").for(:pivotal_email)}
	it {should allow_value("bl@eh.com").for(:harvest_email)}
	it {should allow_value("bl@eh.com").for(:pivotal_email)}
	describe '#harvest_info' do
	  it "returns correct harvest info" do
	   person = Person.new(harvest_id:12345, harvest_name:'timtim', harvest_email: 'rr@yahoo.com')
	   person.harvest_info.should == "12345-timtim (rr@yahoo.com)"
	  end
	end
	
	describe '#pivotal_info' do
		it "returns correct pivotal info" do
			person = Person.new(pivotal_name:"popopo", pivotal_email:'pp@yahoo.com')
			person.pivotal_info.should == "popopo (pp@yahoo.com)"
		end
	end

	describe '#name' do
		it "return correct name format, combination of harvest and pivotal identifier" do
			person = Person.new(harvest_id:234,harvest_name:"tomtom",pivotal_id:4123,pivotal_name:"tomtim")
			person.name.should == "[234-tomtom] [4123-tomtim]"
		end
	end

	describe '#last_name' do
		it "returns valid last name from single word name of type array" do
			person = Person.new
			person.last_name(["ronald"]).should == "ronald"
		end
		it "returns valid last name from 2 word name of type array" do
			person = Person.new
			person.last_name(["ronald","savianto"]).should == "savianto"
		end
		it "returns valid last name from 3 word name of type array" do
			person = Person.new
			person.last_name(["ronald","savianto","timtim"]).should == "savianto timtim"
		end
	end

	describe '#prepare_integration' do
		it "prepares integration of harvest before create harvest instance" do
			client = Harvest::Client.new
			person = Person.new(harvest_email:'tim@mun.com',harvest_name:'timtim munmun')
			person.should_receive(:harvest_client).and_return(client)
			person.should_receive(:last_name).and_return('munmun')
			client.users.should_receive(:create).with(first_name: 'timtim', last_name: 'munmun',email: 'tim@mun.com').and_return(Harvest::User.new)
			person.prepare_integration
		end
	end
end