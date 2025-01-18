class Api::TestController < ApplicationController
  def show
    data = File.read(Rails.root.join('data', 'test_data.json'))
    render json: JSON.parse(data)
  rescue Errno::ENOENT
    render json: { error: 'データファイルが見つかりません' }, status: :not_found
  end
end