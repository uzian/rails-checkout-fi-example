# == Schema Information
#
# Table name: payments
#
#  id         :integer          not null, primary key
#  payer_data :text
#  reference  :string
#  amount     :decimal(12, 3)
#  status     :integer          default(0)
#  archive_id :string
#  message    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
