require 'csv'
require 'awesome_print'
require_relative 'customer.rb'

class Order

attr_reader :id

# The fulfillment_status = :pending sets a default value for fulfillment_status
# Note: @products is a single hash that contains key: food_name and value: price
# Example: @products = {"banana" => 2.25, "cookie" => 1.50}
# The constructor's customer parameter is a Customer object NOT customer id
def initialize(id, products, customer, fulfillment_status = :pending)
  @id = id
  @products = products
  @customer = customer

  if fulfillment_status == :pending || fulfillment_status == :paid || fulfillment_status == :processing || fulfillment_status == :shipped || fulfillment_status == :complete
    @fulfillment_status = fulfillment_status
  else
    raise ArgumentError, 'An invalid fulfillment status value has been entered'
  end
end

def id
  return @id
end

def products
  return @products
end

def customer
  return @customer
end

def fulfillment_status
  return @fulfillment_status
end

def total
  total_wo_tax = 0
  tax_rate = 0.075

  # Iterating through products hash and summing all the values
  @products.each do |k,v|
    total_wo_tax += v
  end

  tax = tax_rate * total_wo_tax

  total_with_tax = total_wo_tax + tax
  total_with_tax_round = total_with_tax.round(2)

  return total_with_tax_round
end

def add_product(product_name, price)

  if @products[product_name]
      raise ArgumentError, 'This product is already in the database'
  end

  @products[product_name] = price

end

# returns a collection of Order instances, representing all of the Orders described in the CSV file
def self.all
  all_order_instances = []

  CSV.open("data/orders.csv", "r").map do |line|
    # Order number
    id = line[0].to_i

    # Creating product hash
    product_hash = {}
    all_products = line[1]
    all_products_into_array = all_products.split(";")

    index = 0
    while index < all_products_into_array.length
      each_product_own_array = all_products_into_array[index].split(":")
      product_hash[each_product_own_array[0]] = each_product_own_array[1].to_f

      index += 1
    end

    # Retrieving customer object
    customer_id = line[2].to_i
    customer_object = Customer::find(customer_id)

    # Order fulfillment status
    status = line[3].to_sym

    new_order = Order.new(id, product_hash, customer_object, status)
    all_order_instances << new_order
  end

  return all_order_instances
end

def self.find(order_id)
  # Note: all_orders is an array of Order objects
  all_orders = Order.all

  # Iterating through the all_orders array. all_orders is an array containing Order objects. If the Order object has an id that matches the order_id parameter, then return that Order object
  index = 0
  while index < all_orders.length
    if all_orders[index].id == order_id
      return all_orders[index]
    end
    index += 1
  end

  # If none of the Order objects have an id that matches the order_id parameter, then return nil
  return nil

end

end

# TEST
# test_find = Order.find(3)
# puts "#{test_find.products}"

# run_method = Order.all
# puts "#{run_method}"

# index = 0
# while index < run_method.length
#   x = run_method[index]
#   puts "Order num: #{x.id} | products: #{x.products} | customer: #{x.customer} | status: #{x.fulfillment_status}"
#   index += 1
# end
