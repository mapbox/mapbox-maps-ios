Pod::Spec.new do |m|

  m.dependency 'a', '1.0'
  m.dependency 'b', '= 1.0'
  m.dependency 'c', '> 1.0'
  m.dependency 'd', '>= 1.0'
  m.dependency 'e', '< 1.0'
  m.dependency 'f', '<= 1.0'
  m.dependency 'g', '~> 1.0'
  m.dependency 'h', '~> 1.0.0'
  m.dependency 'i', '~> 1.0.0-beta.1'
  m.dependency 'j'

end
