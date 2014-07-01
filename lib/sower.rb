require 'sower/version'
require 'csv'

module Sower
  def self.seed(clazz, filename, options = {})
    sql_path  = File.join(seeds_path, "#{filename}.sql")
    csv_path  = File.join(seeds_path, "#{filename}.csv")
    text_path = File.join(seeds_path, "#{filename}.txt")

    old_table_name = clazz.table_name
    if @schema.present?
      clazz.table_name = "#{@schema}.#{clazz.table_name}"
    end

    if clazz.respond_to?(:enumeration_model_updates_permitted=)
      clazz.enumeration_model_updates_permitted = true
    end

    if File.exists?(sql_path)
      puts "Importing #{filename} to #{clazz.table_name} as SQL"

      data = File.read(sql_path)
      ActiveRecord::Base.connection.execute data
    elsif File.exists?(csv_path)
      puts "Importing #{filename} to #{clazz.table_name} as CSV"

      index = 0
      CSV.foreach(csv_path) do |row|
        attributes = {}

        unless columns = options[:columns]
          columns = [:name, :description]
        end

        columns.each_with_index do |col, i|
          if value = row[i]
            attributes[col] = value.try(:strip)
          end
        end

        m = clazz.new(attributes)
        m.id = index
        m.save(:validate => false)
        index += 1
      end
    else
      puts "Importing #{filename} to #{clazz.table_name} as Text"

      File.foreach(text_path).each_with_index do |line, index|
        m = clazz.new(:name => line.chomp)
        m.id = index
        m.save(:validate => false)
      end
    end

    # This fixes an issue where postgres import is leaving the sequences unupdated after import.
    if clazz.count > 1
      ActiveRecord::Base.connection.execute \
        "SELECT setval('#{clazz.table_name}_id_seq'::regclass, MAX(id)) FROM #{clazz.table_name};"
    end

    clazz.table_name = old_table_name
  end

  def self.seeds_path=(path)
    @seeds_path = path
  end

  def self.seeds_path
    if @seeds_path
      @seeds_path
    elsif defined?(Rails)
      Rails.root.join('db/seeds')
    else
      raise "No path to seeds found! Set Sower.seeds_path"
    end
  end

  def self.schema=(schema)
    @schema = schema
  end

end
