class InventoryFile < ActiveRecord::Base
  attr_accessible :file, :filename
  mount_uploader :file, InventoryFileUploader
end
