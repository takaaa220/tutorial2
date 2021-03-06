User.create!(name: "admin", email: "admin@example.com",
            password: "adminpass",
            password_confirmation: "adminpass",
            admin: true,
            activated: true, activated_at: Time.zone.now )

99.times do |n|
  name = "name-#{n+1}"
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name: name, email: email,
    password: password, password_confirmation: password,
    activated: true, activated_at: Time.zone.now)
end

users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content)}
end

users = User.all
user = users.first
following = users[2..50]
followers = users[3..50]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }

# リツイート
user2 = User.second
for num in 1..50 do
  if micropost = Micropost.find_by(id: num)
    micropost.retweet(user2)
  end
end
