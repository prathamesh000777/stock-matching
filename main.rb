
require 'set'

class User
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

class Order
  attr_accessor :user, :action, :stock_symbol, :quantity, :price

  def initialize(user, action, stock_symbol, quantity, price)
    @user = user
    @action = action
    @stock_symbol = stock_symbol
    @quantity = quantity
    @price = price
  end

  def <=>(other)
    if action == 'Buy'
      price <=> other.price
    else
      other.price <=> price 
    end
  end
end

class OrderMatch
  attr_accessor :buy_order, :sell_order, :quantity, :price

  def initialize(buy_order, sell_order, quantity, price)
    @buy_order = buy_order
    @sell_order = sell_order
    @quantity = quantity
    @price = price
  end
end


class StockTradingSystem
  attr_accessor :users, :buy_orders, :sell_orders, :order_matches

  def initialize
    @users = []
    @buy_orders = SortedSet.new # sorted in ascending order
    @sell_orders = SortedSet.new # sorted in descending order
    @order_matches = []
  end

  def place_order(user, action, stock_symbol, quantity, price)
    order = Order.new(user, action, stock_symbol, quantity, price)

    if action == 'Buy'
      @buy_orders << order
      puts "\nPlaced Buy Order: #{user.name}, Quantity: #{quantity}, Price: #{price}"
      match_sell_orders(order)
    else
      @sell_orders << order
      puts "\nPlaced Sell Order: #{user.name}, Quantity: #{quantity}, Price: #{price}"
      match_buy_orders(order)
    end

    order
  end

  def match_sell_orders(buy_order)
    @sell_orders.each do |sell_order|
      next if sell_order.stock_symbol != buy_order.stock_symbol
      next if sell_order.price > buy_order.price

      if sell_order.quantity <= buy_order.quantity
        create_order_match(buy_order, sell_order, sell_order.quantity, sell_order.price)
        buy_order.quantity -= sell_order.quantity
        @sell_orders.delete(sell_order)
      else
        create_order_match(buy_order, sell_order, buy_order.quantity, sell_order.price)
        sell_order.quantity -= buy_order.quantity
        buy_order.quantity = 0
      end

      @buy_orders.delete(buy_order) if buy_order.quantity == 0
      break if buy_order.quantity == 0
    end
  end

  def match_buy_orders(sell_order)
    @buy_orders.each do |buy_order|
      next if sell_order.stock_symbol != buy_order.stock_symbol
      next if sell_order.price > buy_order.price

      if buy_order.quantity <= sell_order.quantity
        create_order_match(buy_order, sell_order, buy_order.quantity, sell_order.price)
        sell_order.quantity -= buy_order.quantity
        @buy_orders.delete(buy_order)
      else
        create_order_match(buy_order, sell_order, sell_order.quantity, sell_order.price)
        buy_order.quantity -= sell_order.quantity
        sell_order.quantity = 0
      end

      @sell_orders.delete(sell_order) if sell_order.quantity == 0
      break if sell_order.quantity == 0
    end
  end

  def create_order_match(buy_order, sell_order, quantity, price)
    order_match = OrderMatch.new(buy_order, sell_order, quantity, price)
    puts "Matched Buy Order: #{order_match.buy_order.user.name}, Sell Order: #{order_match.sell_order.user.name}, Quantity: #{order_match.quantity}, Price: #{order_match.price}"
    @order_matches << order_match
  end
end

system = StockTradingSystem.new
user1 = User.new('User1')
user2 = User.new('User2')
user3 = User.new('User3')
user4 = User.new('User4')

system.users << user1
system.users << user2
system.users << user3
system.users << user4

system.place_order(user1, 'Buy', 'AAPL', 10, 100)
system.place_order(user1, 'Buy', 'HAL', 10, 100)
system.place_order(user2, 'Sell', 'AAPL', 5, 150)
system.place_order(user3, 'Sell', 'AAPL', 5, 90)
system.place_order(user4, 'Sell', 'AAPL', 5, 100)


puts "\nTotal Order Matches:"
system.order_matches.each do |order_match|
  puts "Matched Buy Order: #{order_match.buy_order.user.name}, Sell Order: #{order_match.sell_order.user.name}, Quantity: #{order_match.quantity}, Price: #{order_match.price}"
end

puts "\nTotal Pending Orders:"
system.buy_orders.each do |buy_order|
  puts "Buy Order: #{buy_order.user.name}, Quantity: #{buy_order.quantity}, Price: #{buy_order.price}, Symbol: #{buy_order.stock_symbol}"
end
system.sell_orders.each do |sell_order|
  puts "Buy Order: #{sell_order.user.name}, Quantity: #{sell_order.quantity}, Price: #{sell_order.price}, Symbol: #{sell_order.stock_symbol}"
end
