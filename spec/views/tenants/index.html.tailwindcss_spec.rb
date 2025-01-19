require 'rails_helper'

RSpec.describe "tenants/index", type: :view do
  before(:each) do
    assign(:tenants, [
      Tenant.create!(
        name: "Name",
        subdomain: "Subdomain",
        status: "Status",
        settings: ""
      ),
      Tenant.create!(
        name: "Name",
        subdomain: "Subdomain",
        status: "Status",
        settings: ""
      ),
    ])
  end

  it "renders a list of tenants" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Subdomain".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Status".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
  end
end
