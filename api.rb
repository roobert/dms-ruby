#!/usr/bin/env ruby

require "sinatra"
require "sequel"
require "multi_json"

database   = Sequel.sqlite('dms.db')
data_table = database.from(:data)

# create table if it doesn't exist
database.create_table? :data do
  primary_key :id
  String      :site
  Date        :date, index: true
  String      :bitmap
end

def update_bitmap(bitmap, date_time)
  # bitmap should have a slot for every 15 seconds of the day
  slots = 4 * 60 * 24
  halt "broken bitmap" unless bitmap.length == slots

  # calulate slot for current timestamp
  midnight = Date.today.to_time
  slot = (date_time - midnight).to_i / 15

  bitmap[slot] = 0

  bitmap.join.to_s
end

post '/prometheus' do
  data = ::MultiJson.decode(request.body)

  site = data["alerts"][0]["annotations"]["site"]

  date_time = Time.now
  todays_date = date_time.to_date

  results = data_table.where(site: site, date: todays_date)

  # create an empty bitmap for date if it doesnt exist
  if results.empty?
    slots = 4 * 60 * 24
    new_bitmap = Array.new("1",slots).join("")
    puts "#{site}:#{todays_date}: #{new_bitmap}"
    data_table.insert(site: site, date: todays_date, bitmap: new_bitmap)
  else
    # presumably only one result
    bitmap = results.first[:bitmap]
  end

  bitmap = bitmap.split("").map { |i| i.to_i }

  updated_bitmap = update_bitmap(bitmap, date_time)

  data_table.where(site: site, date: todays_date).update(bitmap: updated_bitmap)

  "OK"
end

# web ui stuff

get "/api/all" do
  data_table.all.to_s
end

get "/api/site/:site" do
  data_table.where(site: params[:site]).all.to_s
end

get "/api/date/:date" do
  data_table.where(date: params[:date]).all.to_s
end

get "/api/site/:site/date/:date" do
  data_table.where(site: params[:site], date: params[:date]).all.to_s
end
