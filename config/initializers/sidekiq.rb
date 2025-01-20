require 'sidekiq'
require 'sidekiq-cron'

schedule = {
  'sync_click_count_job' => {
    'class' => 'SyncClickCountJob',
    'cron'  => '*/5 * * * *', # Runs every 5 minutes
    'queue' => 'default'
  }
}

Sidekiq::Cron::Job.load_from_hash(schedule)