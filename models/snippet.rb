class Snippet
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :slug, String
  property :body, Text
  property :created_at, DateTime
  validates_presence_of   :title
  validates_uniqueness_of :slug
  validates_presence_of   :body
  has n, :tags, :through => :snippettag, :constraint => :destroy

  def add_tags(tags)
    tags = tags.split(',')
    tags = [tags] unless tags.kind_of?(Array)
    tags.each_with_index do |tag, key|
      t = Tag.new(:tag => tag.strip)
      if t.save
        tags[key] = t
      else
        tags[key] = Tag.first(:tag => t.tag)
      end
    end
    self.tags = tags
  end
end
