class Tag
  include DataMapper::Resource
  property :id, Serial
  property :tag, String
  validates_uniqueness_of :tag
  validates_presence_of   :tag
  has n, :snippets, :through => :snippettag
end
