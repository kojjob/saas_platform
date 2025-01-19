module TenantsHelper
  def render_status_icon(status)
    case status
    when "active"
      content_tag :svg, class: "w-5 h-5 text-green-500", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor" do
        content_tag :path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
      end
    when "maintenance"
      content_tag :svg, class: "w-5 h-5 text-yellow-500", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor" do
        content_tag :path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"
      end
    when "inactive"
      content_tag :svg, class: "w-5 h-5 text-gray-500", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor" do
        content_tag :path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
      end
    when "archived"
      content_tag :svg, class: "w-5 h-5 text-purple-500", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor" do
        content_tag :path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4"
      end
    end
  end

  def status_color_class(status)
    case status.to_s
    when "active"
      "bg-green-100"
    when "trial"
      "bg-blue-100"
    when "maintenance"
      "bg-yellow-100"
    else
      "bg-gray-100"
    end
  end

  def status_badge_class(status)
    case status.to_s
    when "active"
      "bg-green-100 text-green-800"
    when "trial"
      "bg-blue-100 text-blue-800"
    when "maintenance"
      "bg-yellow-100 text-yellow-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  def status_icon(status)
    case status.to_s
    when "active"
      render_icon("check", "text-green-600")
    when "trial"
      render_icon("clock", "text-blue-600")
    when "maintenance"
      render_icon("wrench", "text-yellow-600")
    else
      render_icon("x", "text-gray-600")
    end
  end

  def render_icon(name, classes = "")
    case name
    when "check"
      content_tag :svg, class: "w-4 h-4 #{classes}", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
        content_tag :path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M5 13l4 4L19 7"
      end
    when "clock"
      content_tag :svg, class: "w-4 h-4 #{classes}", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
        content_tag :path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
      end
    when "wrench"
      content_tag :svg, class: "w-4 h-4 #{classes}", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
        content_tag :path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
      end
    when "x"
      content_tag :svg, class: "w-4 h-4 #{classes}", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
        content_tag :path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M6 18L18 6M6 6l12 12"
      end
    end
  end

  def render_stat_icon(name)
    case name
    when "users"
      content_tag :div, class: "p-2 bg-blue-100 rounded-lg" do
        content_tag :svg, class: "w-4 h-4 text-blue-600", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
          content_tag :path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
        end
      end
    when "database"
      content_tag :div, class: "p-2 bg-green-100 rounded-lg" do
        content_tag :svg, class: "w-4 h-4 text-green-600", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
          content_tag :path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4"
        end
      end
    when "code"
      content_tag :div, class: "p-2 bg-purple-100 rounded-lg" do
        content_tag :svg, class: "w-4 h-4 text-purple-600", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
          content_tag :path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"
        end
      end
    end
  end
end
