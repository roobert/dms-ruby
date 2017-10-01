task default: :api

task :api do
  sh "rackup"
end

task :alerter do
  sh "./alerter.rb"
end

task :install do
  sh "sudo apt install libsqlite3-dev sqlite3"
  sh "gem install bundle"
  sh "bundle install"
end
