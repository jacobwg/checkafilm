require 'rufus/scheduler'

$scheduler = Rufus::Scheduler.start_new

$scheduler.every("5m") do
  Rails.logger.info("Keep-Alive Rufus log, time: #{Time.now}")
end

if %w(production staging).include? Rails.env
  $scheduler.every("60m") do
    Title.find_each do |t|
      t.async_fetch_information!
    end
  end
end