class InventoryController < ApplicationController

	around_filter :shopify_session
	CYCLE = 0.5

	def index
		@file = InventoryFile.new
	end

	def new
		@file = InventoryFile.new
	end

	def create
		@file = InventoryFile.create(:file => params[:inventory_file][:file],
																 :filename => params[:inventory_file][:filename])
		redirect_to update_path
	end

	def update
		notions_file = InventoryFile.last
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
		redirect_to root_path
	end
end