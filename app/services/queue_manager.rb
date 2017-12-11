class QueueManager

  def self.pidfile
    File.join(Rails.root, "tmp", "pids", "resque-pool.pid")
  end

  def self.pid
    File.read(pidfile) rescue nil
  end

  def self.command
    [ "resque-pool", "-d", "-E", Rails.env, "--term-graceful" ]
  end

  def self.start
    if running?
      false
    else
      system(*command)
    end
  end

  def self.stop
    interrupt("-TERM")
  end

  def self.kill_workers
    count = 0
    Resque.workers.each do |w|
      w.unregister_worker
      count += 1
    end
    count
  end

  def self.restart
    if stop
      while running?
        sleep 1
      end
      start
    else
      false
    end
  end

  def self.reload
    interrupt("-HUP")
  end

  def self.running?
    p = pid
    !!p && system("ps", "-p", p)
  end

  def self.interrupt(signal)
    if running?
      system("kill", signal, pid)
    else
      false
    end
  end

  def self.queue_sizes
    Resque.queue_sizes
  end

  def self.queue_size(queue_name)
    Resque.size(queue_name)
  end

end
