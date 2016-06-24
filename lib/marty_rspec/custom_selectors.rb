Capybara.add_selector(:gridpanel) do
  xpath { |name| ".//div[contains(@id, '#{name}')] | " +
          ".//div[contains(@id, '#{name.camelize(:lower)}')]" }
end
Capybara.add_selector(:msg) do
  xpath { "//div[@id='msg-div']" }
end
Capybara.add_selector(:body) do
  xpath { ".//div[@data-ref='body']" }
end
Capybara.add_selector(:input) do
  xpath { |name| "//input[@name='#{name}']" }
end
Capybara.add_selector(:status) do
  xpath { |name| "//div[contains(@id, 'statusbar')]//div[text()='#{name}']" }
end
Capybara.add_selector(:btn) do
  xpath { |name| ".//span[text()='#{name}']" }
end
Capybara.add_selector(:refresh) do
  xpath { "//img[contains(@class, 'x-tool-refresh')]" }
end
Capybara.add_selector(:gridcolumn) do
  xpath { |name| ".//span[contains(@class, 'x-column-header')]" +
          "//span[text()='#{name}']" }
end