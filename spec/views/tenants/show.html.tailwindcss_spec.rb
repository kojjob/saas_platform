require 'rails_helper'

RSpec.describe "tenants/show", type: :view do
  before(:each) do
    assign(:tenant, Tenant.create!(
      name: "Name",
      subdomain: "Subdomain",
      status: "Status",
      settings: ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Subdomain/)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(//)
  end
end
