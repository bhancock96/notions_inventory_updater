class InventoryController < ApplicationController

	around_filter :shopify_session

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
		sess = session[:shopify].token
		notions_file = InventoryFile.last
		Resque.enqueue(UpdateWorker, {notions_file_id: notions_file.id, token: sess})
		redirect_to root_path
	end
end