require 'test_helper'
class Pasteque::V5::CashesControllerTest < ActionController::TestCase
  test 'update' do
    post :update, cash: "{\"closeCash\":null,\"cashRegisterId\":3,\"closeDate\":1432660189,\"openDate\":1432660140,\"expectedCash\":null,\"sequence\":0,\"openCash\":null}", login: 'admin@ekylibre.org', password: '12345678', format: :json
  end
end
