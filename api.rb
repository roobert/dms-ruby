#!/usr/bin/env ruby

require "sequel"
require "multi_json"
require "sinatra"
require "haml"
require "json"

database   = Sequel.sqlite('dms.db')
data_table = database.from(:data)

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

  # mark the slot as UP for this site
  bitmap[slot] = 1

  # storing bitmap as a String for now..
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
    bitmap = Array.new(slots, "0").join("")
    puts "#{site}:#{todays_date}: creating empty bitmap"
    data_table.insert(site: site, date: todays_date, bitmap: bitmap)
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

get "/" do
  haml :last_five_minutes
end

get "/api/all" do
  content_type :json
  data_table.all.to_json
end

get "/api/today" do
  content_type :json
  data_table.where(date: Time.now.to_date).all.to_json
end

get "/api/last_five_minutes" do

  rows = data_table.where(date: Time.now.to_date).all

  date_time = Time.now
  midnight = Date.today.to_time
  slot = (date_time - midnight).to_i / 15

  rows = rows.map do |row|
    row[:bitmap] = row[:bitmap][0..slot][-21..-2]
    row
  end

  content_type :json
  rows.to_json
end

get "/api/site/:site" do
  content_type :json
  data_table.where(site: params[:site]).all.to_json
end

get "/api/date/:date" do
  content_type :json
  data_table.where(date: params[:date]).all.to_json
end

get "/api/site/:site/date/:date" do
  content_type :json
  data_table.where(site: params[:site], date: params[:date]).all
end
