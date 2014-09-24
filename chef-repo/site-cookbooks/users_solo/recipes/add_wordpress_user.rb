#tworzenie uzytkownika na podstawie data_bag
users_solo_manage "apache" do
  group_id 48
  action [ :remove, :create ]
end
