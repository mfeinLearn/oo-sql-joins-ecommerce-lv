class LineItem

  attr_accessor :id, :cart_id, :product_id

  def self.create_table
    sql = <<-SQL
      CREATE TABlE IF NOT EXISTS line_items(
        id INTEGER PRIMARY KEY,
        cart_id INTEGER,
        product_id INTEGER
      )
    SQL
    DB[:connection].execute(sql)
  end

  def self.find(id)
    sql = "select * from line_items where id = ?"
    row = DB[:connection].execute(sql, id).flatten
    self.reify_from_row(row)
  end

  def self.reify_from_row(row)
    self.new.tap do |o|
      o.id = row[0]
      o.customer_id = row[1]
      o.product_id = row[2]

    end
  end

  def cart
     cart_id = self.cart_id
     sql = "select * from carts where carts.id = ?"
     row = DB[:connection].execute(sql, cart_id).flatten
    # the information about a cart
  end
end
