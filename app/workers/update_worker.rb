class UpdateWorker
	@queue = :update_queue
	# around_filter :shopify_session
	CYCLE = 0.5

	def self.perform(options = {notions_file_id: notions_file_id, session_token: token})
		ShopifyAPI::Base.site = "https://#{ENV['SHOPIFY_KEY']}:#{options['token']}@#{ENV['SHOP_NAME']}/admin"
		notions_file = InventoryFile.find(options['notions_file_id'])
		product_count = ShopifyAPI::Product.count
		nb_pages      = (product_count / 250.0).ceil
		start_time = Time.now
		@count = product_count
		1.upto(nb_pages) do |page|
		  unless page == 1
		    stop_time = Time.now
		    puts "Last batch processing started at #{start_time.strftime('%I:%M%p')}"
		    puts "The time is now #{stop_time.strftime('%I:%M%p')}"
		    processing_duration = stop_time - start_time
		    puts "The processing lasted #{processing_duration.to_i} seconds."
		    wait_time = (processing_duration - CYCLE).ceil
		    puts "We have to wait #{wait_time} seconds then we will resume."
		    sleep wait_time
		    start_time = Time.now
		  end
  		  puts "Doing page #{page}/#{nb_pages}..."
			products = ShopifyAPI::Product.find( :all, :params => { :limit => 250, :page => page } )	
			products.each do |product|
			  notions_file.file.read.each_line do |line|
				if line.split(' ').first.to_i == product.variants.first.sku.to_i
					product.variants.first.inventory_quantity = line.split(' ')[1]
					product.save
				end
			  end
			end
  	    end
  	puts "Update process complete"
  	notions_file.delete
	end
end