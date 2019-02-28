class Dog

  attr_accessor :name, :breed, :id
#  attr_reader :id

  def initialize(attributes)
    attributes.each {|k,v| self.send(("#{k}="),v)}
  end

  def self.create_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    sql = <<~SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def self.find_by_name(name)
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE dogs.name = ?
      SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end
  end

  def update
    sql = <<~SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


  def save
    if self.id
      self.update
    else
      sql = <<~SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
      SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
      SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(attributes)
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
      LIMIT 1
      SQL
    found_dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed])

    if !found_dog.empty?
      dog_info = found_dog[0]
      dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    else
      dog = self.create(attributes)
    end
    dog
  end

end
