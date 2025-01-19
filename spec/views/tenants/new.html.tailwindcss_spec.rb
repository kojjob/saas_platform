require 'rails_helper'

RSpec.describe "tenants/new", type: :view do
  before(:each) do
    assign(:tenant, Tenant.new(
      name: "MyString",
      subdomain: "MyString",
      status: "MyString",
      settings: ""
    ))
  end

  it "renders new tenant form" do
    render

    assert_select "form[action=?][method=?]", tenants_path, "post" do
      assert_select "input[name=?]", "tenant[name]"

      assert_select "input[name=?]", "tenant[subdomain]"

      assert_select "input[name=?]", "tenant[status]"

      assert_select "input[name=?]", "tenant[settings]"
    end
  end
end
