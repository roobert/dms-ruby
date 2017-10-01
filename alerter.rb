#!/usr/bin/env ruby

require "sequel"
require "slack-notifier"

%w[CLIENTS SLACK_WEBHOOK SLACK_USERNAME SLACK_CHANNEL].each do |param|
  raise StandardError, "#{param} not set!" unless ENV[param]
end

clients        = ENV["CLIENTS"]
slack_webhook  = ENV["WEBHOOK_URL"]
slack_username = ENV["SLACK_USERNAME"]
slack_channel  = ENV["SLACK_CHANNEL"]

up_symbol   = "❤"
down_symbol = "🔥"
good_symbol = "✓"
bad_symbol  = "✗"
disconnected_symbol = "!"

notifier = Slack::Notifier.new webhook_url do
  defaults channel: slack_channel,
  username: slack_username
end

database = Sequel.sqlite('dms.db')

database.create_table? :data do
  primary_key :id
  String      :site
  Date        :date, index: true
  String      :bitmap
end

dataset = database.from(:data)

#started = clients.each_with_object({}) { |client, collection| collection[client] = false }

loop do
  clients.each do |client|
    date_time = Time.now
    todays_date = date_time.to_date

    results = dataset.where(site: client, date: todays_date)

    if results.all.length.zero?
      puts "#{client} - #{disconnected_symbol}  - no records for client"
      next
    end

    # should only be one entry in the DB for each site:todays_date
    if results.all.length > 1
      puts "there is a problem: #{results}"
      next
    end

    midnight = Date.today.to_time
    slot = (date_time - midnight).to_i / 15

    bitmap_a = results.first[:bitmap].split("").map { |i| i.to_i }
    last_five_minutes = bitmap_a[0..(slot-1)][-20..-1]
    last_five_minutes_pretty = last_five_minutes.join.gsub("0", good_symbol).gsub("1", bad_symbol).scan(/.{4}/).join("|")

    # first fail alert
    # if the last 5 minutes is all 0, apart from the last slot, then ping slack
    #if (last_five_minutes[0..-2].count(0) == 19) && (last_five_minutes[-1] == 1)
    if (last_five_minutes[-2] == 0) && (last_five_minutes[-1] == 1)
      notifier.ping "#{client}   #{down_symbol}   #{last_five_minutes_pretty}"
    end

    # resolved
    # if the second to last slot contains a 1, and the current slot a 0
    if (last_five_minutes[-2] == 1) && (last_five_minutes[-1] == 0)
      notifier.ping "#{client}   #{up_symbol}   #{last_five_minutes_pretty}"
    end

    # stdout
    # output client status to standardout on every loop
    if last_five_minutes[-1] == 0
      puts "#{client} - #{up_symbol}  - #{last_five_minutes_pretty}"
    else
      puts "#{client} - #{down_symbol} - #{last_five_minutes_pretty}"
    end
  end

  sleep 15
end
