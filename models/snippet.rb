class Snippet
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :body, String
  property :created_at, DateTime
  validates_presence_of   :title
  validates_uniqueness_of :slug
  validates_presence_of   :body
  has n, :tags, :through => :snippettag
end
