class CreateSystemDatas < ActiveRecord::Migration
  def self.up
	Language.delete_all
	Language.create(:name => 'English')

#	Project.delete_all
#	Project.create(:name => 'All Projects',
#			   :short_decr => '',
#			   :description => '',
#			   :cost=> '',
#			   :is_completed => true,
#			   :language_id => 1)

  end

  def self.down
	Language.delete_all
#	Project.delete_all
  end
end
