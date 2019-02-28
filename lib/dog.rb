class Dog
  attr_reader :id
  attr_accessor :name, :breed

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  # Inserts this dog into the db and returns it
  def save
    if @idea
      self.update
    else
      sql = <<~SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  # Updates this dog's attributes
  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ?", @name, @breed)
  end

  # Creates new instance of dog with given attributes
  # and adds it to the dogs table in db.
  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end

  # Creates new dog from given attributes from table row
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  # Returns dog with given id
  def self.find_by_id(id)
    sql = <<~SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  # Returns dog with given name
  def self.find_by_name(name)
    sql = <<~SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  # Returns dog with given attributes if it exists
  # else creates new dog with given attributes and returns it
  def self.find_or_create_by(name:, breed:)
    sql = <<~SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    dog_data = DB[:conn].execute(sql, name, breed)

    if !dog_data.empty?
      dog_row = dog_data.first
      dog = Dog.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  # Creates a new table dogs in the db
  def self.create_table
    sql = <<~SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  # Removes dogs table from db
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end
end
