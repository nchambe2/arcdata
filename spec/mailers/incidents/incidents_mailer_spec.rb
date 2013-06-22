require "spec_helper"

describe Incidents::IncidentsMailer do
  let(:from_address) {["incidents@arcbadat.org"]}
  let(:person) { FactoryGirl.create :person }

  before(:each) do
    @chapter = FactoryGirl.create :chapter
  end

  describe "weekly" do
    let(:mail) { Incidents::IncidentsMailer.weekly(@chapter, person) }

    it "renders the headers" do
      mail.subject.should match("ARCBA Disaster Operations")
      mail.to.should eq([person.email])
      mail.from.should eq(from_address)
    end

    it "renders the body" do
      mail.body.encoded.should match("ARCBA Disaster Operations")
    end

    it "is multipart" do
      mail.parts.count.should == 2
    end
  end

  describe "no_incident_report" do
    let(:report) { stub :incident, incident_number: "12-345", county_name: 'County', created_at: Time.zone.now, dispatch_log: stub( delivered_to: "Bob")}
    let(:mail) { Incidents::IncidentsMailer.no_incident_report(report, person) }

    it "renders the headers" do
      mail.subject.should eq("Missing Incident Report For County")
      mail.from.should eq(from_address)
    end

    it "should be to the county designated contact" do
      mail.to.should eq([person.email])
    end

    it "renders the body" do
      mail.body.encoded.should match("An incident number was created for your")
      mail.body.encoded.should match("Person Contacted by Dispatch: Bob")
    end
  end

  describe "new_incident" do
    let(:dispatch) { stub :dispatch_log, incident_type: 'Flood', address: Faker::Address.street_address, displaced: 3, services_requested: "Help!", agency: "Fire Department", contact_name: "Name", contact_phone: "Phone", delivered_at: nil}
    let(:report) { stub :incident, incident_number: "12-345", county_name: 'County', created_at: Time.zone.now, dispatch_log: dispatch}
    let(:mail) { Incidents::IncidentsMailer.new_incident(report, person) }

    it "renders the headers" do
      mail.subject.should eq("New Incident For County")
      mail.from.should eq(from_address)
    end

    it "should be to the recipient" do
      mail.to.should eq([person.email])
    end

    it "renders the body" do
      mail.body.encoded.should match("Incident Type: Flood")
      mail.body.encoded.should_not match("Delivered At")
    end
  end

  describe "incident_dispatched" do
    let(:dispatch) { stub :dispatch_log, incident_type: 'Flood', address: Faker::Address.street_address, displaced: 3, services_requested: "Help!", agency: "Fire Department", contact_name: "Name", contact_phone: "Phone", delivered_at: Time.zone.now, delivered_to: "Bob"}
    let(:report) { stub :incident, incident_number: "12-345", county_name: 'County', created_at: Time.zone.now, dispatch_log: dispatch}
    let(:mail) { Incidents::IncidentsMailer.incident_dispatched(report, person) }

    it "renders the headers" do
      mail.subject.should eq("Incident For County Dispatched")
      mail.from.should eq(from_address)
    end

    it "should be to the recipient" do
      mail.to.should eq([person.email])
    end

    it "renders the body" do
      mail.body.encoded.should match("Incident Type: Flood")
      mail.body.encoded.should match("Delivered To: Bob")
    end
  end

  describe "incident_report_filed" do
    let(:dat) { FactoryGirl.create :dat_incident}
    let(:report) { FactoryGirl.create :incident, dat_incident: dat}
    let(:mail) { Incidents::IncidentsMailer.incident_report_filed(report, person) }

    it "renders the headers" do
      mail.subject.should eq("Incident Report Filed For #{report.county.name}")
      mail.from.should eq(from_address)
    end

    it "should be to the designated contact" do
      mail.to.should eq([person.email])
    end

    it "renders the body" do
      mail.body.encoded.should match("A New DAT Incident Report was filed")
    end
  end

  #describe "orphan_cas" do
  #  let(:mail) { Incidents::IncidentsMailer.orphan_cas }
#
  #  it "renders the headers" do
  #    mail.subject.should eq("Orphan cas")
  #    mail.to.should eq(["to@example.org"])
  #    mail.from.should eq(from_address)
  #  end
#
  #  it "renders the body" do
  #    mail.body.encoded.should match("Hi")
  #  end
  #end

end
