class ApplicationController < ActionController::API
  def DoSomethingBAD
    puts "Rubocop will hate this!"
  end
end
