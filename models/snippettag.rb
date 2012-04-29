class SnippetTag
  include DataMapper::Resource
  belongs_to :snippet, :key => true
  belongs_to :tag,     :key => true
end
