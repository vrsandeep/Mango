enum SortMethod
  Auto
  Title
  Progress
  TimeModified
  TimeAdded
end

class SortOptions
  property method : SortMethod
  property ascend : Bool # ameba:disable Naming/QueryBoolMethods

  def initialize(in_method : String? = nil, @ascend = true)
    @method = SortMethod::Auto
    SortMethod.each do |m, _|
      if in_method && m.to_s.underscore == in_method
        @method = m
        return
      end
    end
  end

  def initialize(in_method : SortMethod? = nil, @ascend = true)
    if in_method
      @method = in_method
    else
      @method = SortMethod::Auto
    end
  end

  def self.from_tuple(tp : Tuple(String, Bool))
    method, ascend = tp
    self.new method, ascend
  end

  def self.from_info_json(dir, username)
    opt = SortOptions.new
    TitleInfo.new dir do |info|
      if info.sort_by.has_key? username
        opt = SortOptions.from_tuple info.sort_by[username]
      end
    end
    opt
  end

  def to_tuple
    {@method.to_s.underscore, ascend}
  end

  def to_json
    {
      "method" => method.to_s.underscore,
      "ascend" => ascend,
    }.to_json
  end
end

struct Image
  property data : Bytes
  property mime : String
  property filename : String
  property size : Int32

  def initialize(@data, @mime, @filename, @size)
  end

  def self.from_db(res : DB::ResultSet)
    img = Image.allocate
    res.read String
    img.data = res.read Bytes
    img.filename = res.read String
    img.mime = res.read String
    img.size = res.read Int32
    img
  end
end

class TitleInfo
  include JSON::Serializable

  property comment = "Generated by Mango. DO NOT EDIT!"
  property progress = {} of String => Hash(String, Int32)
  property display_name = ""
  property entry_display_name = {} of String => String
  property cover_url = ""
  property entry_cover_url = {} of String => String
  property last_read = {} of String => Hash(String, Time)
  property date_added = {} of String => Time
  property sort_by = {} of String => Tuple(String, Bool)

  @[JSON::Field(ignore: true)]
  property dir : String = ""

  @@mutex_hash = {} of String => Mutex

  def self.new(dir, &)
    key = "#{dir}:info.json"
    info = LRUCache.get key
    if info.is_a? String
      begin
        instance = TitleInfo.from_json info
        instance.dir = dir
        yield instance
        return
      rescue
      end
    end

    if @@mutex_hash[dir]?
      mutex = @@mutex_hash[dir]
    else
      mutex = Mutex.new
      @@mutex_hash[dir] = mutex
    end
    mutex.synchronize do
      instance = TitleInfo.allocate
      json_path = File.join dir, "info.json"
      if File.exists? json_path
        instance = TitleInfo.from_json File.read json_path
      end
      instance.dir = dir
      LRUCache.set generate_cache_entry key, instance.to_json
      yield instance
    end
  end

  def save
    json_path = File.join @dir, "info.json"
    File.write json_path, self.to_pretty_json
    key = "#{@dir}:info.json"
    LRUCache.set generate_cache_entry key, self.to_json
  end
end

alias ExamineContext = NamedTuple(
  cached_contents_signature: Hash(String, String),
  deleted_title_ids: Array(String),
  deleted_entry_ids: Array(String))
