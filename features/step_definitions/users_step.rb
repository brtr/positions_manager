Given (/^I am a new, authenticated user$/) do
  email = 'tester@test.com'
  password = 'password'
  User.new(:email => email, :password => password, :password_confirmation => password).save!

  visit '/users/sign_in'
  fill_in "user_email", :with => email
  fill_in "user_password", :with => password
  click_button "登录"
end