#CART
# id Integer
# customer_id Integer

class Cart
  attr_accessor :id, :customer_id

  # from video!
  #
  # 2nd
  # def customer
  #   the_id_i_need_to_query = self.customer_id
  #   # I need to query it from the customers table itself
  #   row = DB[:connection].execute("select * from customers where id = ?", self.customer_id)
  # end

  # from video!
  #
  # 1st
  # expected: Cart.find(3)
  # return: <Cart object>
  def self.find(id)
    row = DB[:connection].execute("select * from carts where id = ?", id)
    Cart.reify_from_row(row.flatten)
  end
  # below is evil(thats why we used bound params (?)):
  # Cart.find("; DROP TABLE customers;")

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS carts (
        id INTEGER PRIMARY KEY,
        customer_id INTEGER
      )
    SQL
    DB[:connection].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.class}s (customer_id)
      VALUES (?)
    SQL
      DB[:connection].execute(sql, customer_id)
  end

  def total_price
    # products.collect{|p| p.price}.inject(:+)

    sql = <<-SQL
      SELECT SUM(products.price)
      FROM products
      INNER JOIN line_items ON products.id = line_items.product_id
      INNER JOIN carts ON carts.id = line_items.cart_id
      GROUP BY carts.id
    SQL
    DB[:connection].execute(sql).flatten.first
  end

  def self.find(id)
    sql = <<-SQL
      SELECT * FROM carts WHERE id = ?
    SQL

    rows = DB[:connection].execute(sql, id)

    Cart.reify_from_row(rows.first)
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM carts
    SQL
    rows = DB[:connection].execute(sql)

    Cart.reify_from_rows(rows)
  end

  def self.reify_from_rows(rows)
    rows.collect{|r| reify_from_row(r)}
  end

  def self.reify_from_row(row)
    self.new.tap do |o|
      o.id = row[0]
      o.customer_id = row[1]
    end
  end

  # Belongs To
  def customer
    Customer.find(self.customer_id)
  end

  # How do we find products for this cart?
  # Has Many
  def products
    Product.find_by_cart_id(self.id)
  end
end
