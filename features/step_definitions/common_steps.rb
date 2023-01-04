When 'I sign in' do
  user = create(:user, name: "test", email: 'test@feedmob.com', password: '123456')

  visit '/users/sign_in'
  fill_in 'user_email', with: 'test@feedmob.com'
  fill_in 'user_password', with: '123456'
  click_button '登录'
end

When 'I visit the {string} page' do |path|
  visit path
end

Then 'I see {string} text' do |content|
  expect(page).to have_content(content)
end

Then 'I should not see {string} text' do |content|
  expect(page).not_to have_content(content)
end

When 'I click on the {string} link' do |link|
  click_link(link, match: :first)
end

When 'I click on the {string} element' do |string|
  find(string).click
end

When 'I click on the {string} text with {string} element' do |text, element|
  find(element, text: text)
end

Then("I click on the {string} element within {string}") do |string, container|
  within(container) do
    find(string).click
  end
end

When "I fill {string} into the {string} field" do |text, field|
  fill_in field, :with => text
end

When "I fill {string} into the {string} field within {string}" do |text, field, container|
  within(container) do
    fill_in field, :with => text
  end
end

Then /^I should see the button "([^"]*)"$/ do |button|
  expect(page).to have_button button
end

Then /^I should see the disabled button "([^"]*)"$/ do |button|
  expect(page).to have_button button, disabled: true
end

Then /^I should not see the button "([^"]*)"$/ do |button|
  expect(page).not_to have_button button
end

Then /^I should see the disabled button "([^"]*)" within "(.*?)"$/ do |button, element|
  within element do
    expect(page).to have_button button, disabled: true
  end
end

Then /^I should see the button "([^"]*)" within "(.*?)"$/ do |button, element|
  within element do
    expect(page).to have_button button
  end
end

Then("I click on the button {string}") do |text|
  click_button "#{text}"
  wait_for_ajax
end

Then("I click on the button {string} within {string}") do |text, container|
  within(container) do
    click_button "#{text}"
    wait_for_ajax
  end
end

And("I select2 {string} from {string} filter") do |option, filter_id|
  select2(option, css: "#{filter_id} + .select2-container", exact_text: true)
end

And "I am waiting for turbolinks ajax" do
  wait_for_turbolinks_ajax
end

Then("I should see content {string} within {string}") do |text, container|
  within(container) do
    expect(page).to have_content(text)
  end
end

Then("I should not see content {string} within {string}") do |text, container|
  within(container) do
    expect(page).not_to have_content(text)
  end
end

Then 'I attach the file {string} to {string}' do |file, field|
  attach_file(field, Rails.root + file)
end

When "I fill date {string} into the {string} field" do |date, field|
  fill_in field, :with => "#{Date.parse(date)}"
end

And 'I am waiting for ajax' do
  wait_for_ajax
end