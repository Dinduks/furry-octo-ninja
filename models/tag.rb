class Tag
  include DataMapper::Resource
  property :id, Serial
  property :tag, String
  validates_uniqueness_of :tag
end
