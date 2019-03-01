class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id !=nil
      sql = <<-SQL
        UPDATE dogs SET name = ? , breed = ? WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    else
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid()FROM dogs")[0][0]
    end
    return self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.new_from_db(row)
    dog = Dog.new(id:row[0], name:row[1], breed:row[2])
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.id)[0]
  end

  def self.find_by_name(lookup_name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1;"
    DB[:conn].execute(sql, lookup_name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = Dog.new(name: name, breed: breed)
      dog.save
    end
  end

  def self.find_by_id(lookup_id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1;"
    DB[:conn].execute(sql,lookup_id).map do |row|
      self.new_from_db(row)
    end.first
  end
end
