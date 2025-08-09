require 'concurrent'

workers ENV.fetch("WEB_CONCURRENCY") { Concurrent.physical_processor_count }

threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

port ENV.fetch("PORT", 3000)

plugin :tmp_restart

plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
