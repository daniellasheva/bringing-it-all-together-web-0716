class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name: , breed: )
    @id=id
    @name=name
    @breed=breed
  end

  def self.create_table
#    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'Customers')
# BEGIN
#     PRINT 'Table Exists'
# END
  sql =  <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
  SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs 
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql= <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
   # binding.pry
    DB[:conn].execute(sql, self.name, self.breed)
    @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

   def self.create(name:, breed:)
    dog= Dog.new(name: name, breed: breed) #have to specify because it's a hash
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql= <<-SQL
      SELECT * FROM dogs WHERE id=?
    SQL
    result= DB[:conn].execute(sql, id).flatten
    self.new_from_db(result)
  end

   def self.new_from_db (array)
    dog= Dog.new(id: array[0], name: array[1], breed: array[2])
    dog
  end

  def self.find_or_create_by (name: , breed: )
    sql= "SELECT * FROM dogs WHERE name=? AND breed=?"
    result= DB[:conn].execute(sql, name, breed).first #when you call first on an empty array, your return is nil
      #binding.pry
      if result==nil
        dog=self.create(name: name, breed: breed)
      else
        dog=self.new_from_db(result)
      end
      dog
  end


    #if there is no instance, create it
    # if self.id=nil
    #    self.create(name, breed)
    # else
    # #if there is an instance,
    # self.find_by_name(name)
    #   newid=self.find_by_name(name).id
    #   # when creating a new dog with the same name as persisted dogs, it returns the correct dog (FAILED - 1)
    #   binding.pry
    #   self.create(id, name, breed)
    # else 
    # # it does exist, find it
    #   self.find_by_name(name)
    # end
    #end
  #end

  def self.find_by_name(name)
    sql= <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    result=DB[:conn].execute(sql, name).flatten
    self.new_from_db(result)
  end


  def update
    sql= "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end