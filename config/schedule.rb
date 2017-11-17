job_type :runner, "cd /home/ubuntu/flights && bundle exec dotenv bin/rails runner -e production ':task' :output"
set :output, {:error => "log/cron_error_log.log", :standard => "log/cron_log.log"}

# updating prices
every 12.hours do
   runner "PriceupdateJob.perform_now"
end
