FactoryGirl.define do
  factory :basic_tag, :class =>Tag do
    tag 'hello'
  end

  factory :basic_snippet, :class => Snippet do
    title 'hello'
    slug  'hello'
    body  'hello world!'
  end
end
