namespace :queues do
  desc "Print the status of the QueueManager."
  task :status => :environment do
    if QueueManager.running?
      puts "QueueManager is running."
    else
      puts "QueueManager is stopped."
    end
  end

  desc "Start the QueueManager."
  task :start => :environment do
    if QueueManager.start
      while !QueueManager.running?
        sleep 1
      end
      puts "QueueManager started."
    else
      puts "QueueManager already running."
    end
  end

  desc "Stop the QueueManager."
  task :stop => :environment do
    if QueueManager.stop
      while QueueManager.running?
        sleep 1
      end
      puts "QueueManager stopped."
    else
      puts "QueueManager not running."
    end
  end

  desc "Restart the QueueManager."
  task :restart => [:stop, :start] do
    # stop, start
  end

  desc "Reload the QueueManager configuration."
  task :reload => :environment do
    if QueueManager.reload
      puts "QueueManager configuration reloaded."
    else
      puts "QueueManager not running."
    end
  end

  desc "Kill QueueManager workers immediately and fail running jobs."
  task :kill_workers => :environment do
    count = QueueManager.kill_workers
    puts "#{count} QueueManager workers killed."
  end
end
