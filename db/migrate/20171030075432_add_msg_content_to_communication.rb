class AddMsgContentToCommunication < ActiveRecord::Migration[5.1]
  def change
    add_column :communications, :msg_content, :string
  end
end
