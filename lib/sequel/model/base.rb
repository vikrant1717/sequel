module Sequel
  class Model
    # returns the database associated with the model class
    def self.db
      @db ||= ((superclass != Object) && (superclass.db)) || \
        raise(SequelError, "No database associated with #{self}.")
    end
    
    # sets the database associated with the model class
    def self.db=(db); @db = db; end
    
    # called when a database is opened in order to automatically associate the
    # first opened database with model classes.
    def self.database_opened(db)
      @db = db if self == Model && !@db
    end

    # returns the dataset associated with the model class.
    def self.dataset
      @dataset || super_dataset || raise(SequelError, "No dataset associated with #{self}.")
    end
    
    def self.super_dataset
      if superclass && superclass.respond_to?(:dataset) && ds = superclass.dataset
        ds
      end
    end
    
    def self.columns
      @columns ||= @dataset.columns || raise(SequelError, "Could not fetch columns for #{self}")
    end

    # Sets the dataset associated with the model class.
    def self.set_dataset(ds)
      @db = ds.db
      @dataset = ds
      @dataset.set_model(self)
    end
    
    def model
      @model ||= self.class
    end
    
    # Returns the dataset assoiated with the object's model class.
    def db
      @db ||= model.db
    end

    # Returns the dataset assoiated with the object's model class.
    def dataset
      @dataset ||= model.dataset
    end
    
    def columns
      @columns ||= model.columns
    end
  end

  def self.Model(source)
    @models ||= {}
    @models[source] ||= Class.new(Sequel::Model) do
      set_dataset(source.is_a?(Dataset) ? source : db[source])
      # meta_def(:inherited) do |c|
      #   c.set_dataset(source.is_a?(Dataset) ? source : c.db[source])
      # end
    end
  end
end