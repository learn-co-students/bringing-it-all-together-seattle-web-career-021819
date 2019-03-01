class Dog
  attr_accessor :id, :name, :breed

  @@all = []

  def initialize(hash)
    hash.each { |key, value| self.send("#{key}=", value) }
  end


  def self.create_table
    sql = <<~SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL
    DB[:conn].execute(sql)
  end


  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end


  def save
    sql = <<~SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      ;
      SQL
    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    return self
  end



  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
    new_dog
  end


  def self.find_by_id(num)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = #{num}")[0]
    self.new_from_db(row)
  end


  def self.new_from_db(row)
    hash = {}
    hash[:id] = row[0]
    hash[:name] = row[1]
    hash[:breed] = row[2]
    Dog.new(hash)
  end


  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = \"#{name}\"")[0]
    self.new_from_db(row)
  end

  def self.find_by_breed(breed)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE breed = \"#{breed}\"")[0]
    self.new_from_db(row)
  end


  def self.find_or_create_by(name:, breed:)
    dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = \"#{name}\" AND breed = \"#{breed}\"")
    if !dogs.empty?
      self.new_from_db(dogs[0])
    else  # if no dog record is found - .create new dog instance
      hash = {}
      hash[:name] = name
      hash[:breed] = breed
      self.create(hash)
    end
  end

  def update
    
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end




end
