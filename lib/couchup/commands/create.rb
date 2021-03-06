module Couchup
  module Commands
    class Create
      def run(*params)
        what = params.shift.to_s
        if(what == 'view')
          create_view(params.first)
        else
          Couchup.server.database!(params.first)
          Use.new.run(params.first)
        end
      end
      
      def create_view(name)
        raise "Please set your EDITOR env variable before using view" if ENV['EDITOR'].nil? 
        view = ::Couchup::View.new(name)  
        file = Tempfile.new(name.gsub("/", "_"))
        tmp_file_path = file.path
        file.write("------BEGIN Map-------\n")
        file.write( view.map? ? view.map : ::Couchup::View::MAP_TEMPLATE)
        file.write("\n------END------\n")
        
        file.write("\n------BEGIN Reduce(Remove the function if you don't want a reduce)-------\n")
        file.write(view.reduce? ? view.reduce: ::Couchup::View::REDUCE_TEMPLATE )
        file.write("\n------END------\n")
        file.write("\nDelete Everything to do nothing.\n")
        file.close
        
        `#{ENV['EDITOR']} #{tmp_file_path}`
        contents = File.open(tmp_file_path).read
        ::Couchup::View.create(name, contents) unless contents.blank?
        file.close
        file.unlink
      end
      
      def self.describe
        "Creates a new database and switches to the database if using create :database, :foo or a new view if using create :view,'Rider/by_number'"
      end
    end
  end
end