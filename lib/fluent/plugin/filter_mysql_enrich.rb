module Fluent
  class MysqlEnrichFilter < Filter
    Plugin.register_filter('mysql_enrich', self)

    def initialize
      super
      require "mysql2"
    end

    config_param :sql, :string
    config_param :sql_key, :string

    config_param :record_key, :string
    config_param :record_mapping, :hash, default: {}, symbolize_keys: true, value_type: :string

    config_param :host, :string
    config_param :port, :integer, :default => 3306
    config_param :database, :string
    config_param :username, :string
    config_param :password, :string, :secret => true

    config_param :columns, :array, value_type: :string

    config_param :refresh_interval, :integer, :default => 60 

    helpers :timer

    def configure(conf)
      super
      @cache = Hash.new

      if @sql.nil?
        raise Fluent::ConfigError, "SQL Statement is is not specified"
      end

      if @sql_key.nil?
        raise Fluent::ConfigError, "SQL Key field is not specified"
      end

      if @record_key.nil?
        raise Fluent::ConfigError, "Record Key field is not specified"
      end

      if @host.nil?
        raise Fluent::ConfigError, "Database host is not specified"
      end

      if @database.nil?
        raise Fluent::ConfigError, "Database name is not specified"
      end

      if @username.nil?
        raise Fluent::ConfigError, "Username is not specified"
      end

      if @password.nil?
        raise Fluent::ConfigError, "Password is not specified"
      end

      if @columns.nil?
        raise Fluent::ConfigError, "Database table columns are not specified"
      end
    end

    def start
      super
      refresh_cache
      timer_execute(:refresh_timer, @refresh_interval, &method(:refresh_cache))
    end

    def shutdown
      super
    end

    def filter(tag, time, record)

      log.debug "Cache contains #{@cache.size} entries..."

      key = hash_get(record, @record_key)
      log.debug "Key to enrich: #{key}"
      return record if key.nil?

      row = hash_get(@cache, key)
      log.debug "Entry in cache used to enrich: #{row}"
      return record if row.nil? || @columns.nil?
      
      @columns.each do |col|
        if @record_mapping.key?(col.to_sym)
          fieldname = @record_mapping[col.to_sym]
          log.debug "Old #{col}; New #{fieldname}"
          record[fieldname] = row[col]
        else
          record[col] = row[col]
        end
      end
    
      return record
    end

    def selectable?(sql)
      sql =~/^\s*(SELECT)/i
    end

    def hash_get(hash, key)
      return hash[key.to_sym] if hash.key?(key.to_sym)
      return hash[key] if hash.key?(key)
      nil
    end

    def client
      Mysql2::Client.new({
          :host => @host, :port => @port,
          :username => @username, :password => @password,
          :database => @database,
      })
    end 
    
    def refresh_cache
      log.info "Refreshing cache..."
      temp = Hash.new
      begin
        handler = self.client
      rescue Mysql2::Error::ConnectionError
        log.warn("Connection with Database failed...")
        return
      end
      if !selectable?(@sql)
        log.warn "Only select statements are supported: #{@sql}"
      end

      results = handler.query("#{@sql}")
      if results.size() == 0
        log.warn("No results from enrichment db") 
        return
      end
      log.debug "Caching #{results.count} entries..."

      results.each do |row|
        id = row[@sql_key]
        if id.nil?
          log.debug "Id #{@sql_key} not found in row."
        else
          temp[id] = row
        end
      end
      handler.close
      @cache = temp
      log.info "Cache contains #{@cache.size} entries after loading"
    end
  end
end
