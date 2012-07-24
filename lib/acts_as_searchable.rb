module ActsAsSearchable
  def acts_as_searchable(default_searchable_options = {})
    # TODO: escape table + column names
    fn = lambda do |*args|
      raise ArgumentError if args.empty? || args.size > 2
      q = args[0]
      searchable_options = args[1] || {}
      if q
        # prepare options
        searchable_options = {}.update(default_searchable_options).update(searchable_options)
        includes = [*(searchable_options[:includes] || [])]
        text_fields = searchable_options[:text_fields] || []
        booleans = searchable_options[:booleans] || []
        custom = [*(searchable_options[:custom] || [])]
        (includes + [self.table_name.to_sym]).each do |table_name|
          t = eval(table_name.to_s.classify) # TODO: This must be possible without eval
          unless searchable_options[:text_fields]
            text_fields += t.columns_hash.select {|n,c| c.type == :string }.map {|c| [t.table_name, c[0].to_sym] }
          end
          unless searchable_options[:columns]
            booleans += t.columns_hash.select {|n,c| c.type == :boolean }.map {|c| [t.table_name, c[0].to_sym] }
          end
        end
        columns = searchable_options[:columns] || text_fields
        expand_names = lambda {|x| x.kind_of?(String) ? [self.table_name, x] : x }
        text_fields.map!(&expand_names)
        booleans.map!(&expand_names)
        columns.map!(&expand_names)
        # build query
        selection = self.where("1 = 1")
        selection = selection.includes(includes) if includes.any?
        q = q.strip
        custom.each do |key,sql|
          q.gsub!(/\b#{Regexp.quote(key)}\b/i) do
            if sql.respond_to? :call
              selection = sql.call(selection)
            else
              selection = selection.where("#{sql}")
            end
            ""
          end
          q.strip!
        end
        columns.each do |f|
          field_name = f.join(".")
          values = []
          q.gsub!(/\b(#{f.last}):(\w+)\b/i) do
            values << $2
            ""
          end
          q.strip!
          sql_like = []
          bind = []
          values.each do |s|
            sql_like << "#{field_name} like ?"
            bind << "%#{s}%"
          end
          if sql_like.any?
            selection = selection.send :where, *[sql_like.join(" or "), *bind]
          end
        end
        booleans.each do |f|
          field_name = f.join(".")
          m = f.last.to_s.match(/^(is|has)_(.+)$/i)
          if m
            denom = m[1]
            basename = m[2]
          else
            denom = "is"
            basename = f.last.to_s
          end
          q.gsub!(/\b#{denom}:#{basename}\b/i) do
            selection = selection.where("#{field_name} = 1")
            ""
          end
          q.gsub!(/\bnot:#{basename}\b/i) do
            selection = selection.where("#{field_name} = 0")
            ""
          end
          q.strip!
        end
        sql_like = []
        bind = []
        q.split(/\s+/).each do |s|
          sql_like << "concat_ws('', #{text_fields.map{|x| x.join('.')}.join(',')}) like ?"
          bind << "%#{s}%"
        end
        if sql_like.any?
          selection = selection.send :where, *[sql_like.join(" and "), *bind]
        end
        selection
      end
    end
    self.scope :search, fn
  end
end
ActiveRecord::Base.extend ActsAsSearchable
