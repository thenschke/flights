class PriceupdateMiddleware
  def call(worker_instance, queue, sqs_msg, body)
    puts 'Before work'
    yield
    puts 'After work'
  end
end
