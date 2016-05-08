
                 User.create!(name:  "Example User",
                              email: "max@test.com",
                              password:              "foobar",
                              password_confirmation: "foobar", admin: true)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@example.com"
  password = "password"
  User.create!(name:  name, email: email, password: password,
               password_confirmation: password)
end
