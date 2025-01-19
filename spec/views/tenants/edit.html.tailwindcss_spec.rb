require 'rails_helper'

RSpec.describe "tenants/edit", type: :view do
  let(:tenant) {
    Tenant.create!(
      name: "MyString",
      subdomain: "MyString",
      status: "MyString",
      settings: ""
    )
  }

  before(:each) do
    assign(:tenant, tenant)
  end

  it "renders the edit tenant form" do
    render

    assert_select "form[action=?][method=?]", tenant_path(tenant), "post" do
      assert_select "input[name=?]", "tenant[name]"

      assert_select "input[name=?]", "tenant[subdomain]"

      assert_select "input[name=?]", "tenant[status]"

      assert_select "input[name=?]", "tenant[settings]"
    end
  end
end
