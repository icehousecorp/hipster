Resque::Server.use(Rack::Auth::Basic) do |user, password|
	user == "hipster"
	password == "password"
end