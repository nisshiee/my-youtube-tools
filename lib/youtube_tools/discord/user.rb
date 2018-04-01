class YoutubeTools::Discord::User
  # @!attribute [rw] id
  #   @return [String]
  # @!attribute [rw] nickname
  #   @return [String]
  attr_accessor :id, :nickname

  def initialize(id:, nickname:)
    @id = id
    @nickname = nickname
  end

  def ==(o)
    id == o.id
  end

  def eql?(o)
    self == o
  end

  def hash
    id.hash
  end

  NISSHIEE = new(id: '275535768334630913', nickname: 'にっしー')
  ARUMI = new(id: '285411994591559680', nickname: 'あるみ')
  MITSUYOSHI = new(id: '298272951999135744', nickname: 'みつよし')
  TEI = new(id: '370789186376302607', nickname: 'てい')
  IICYAN = new(id: '388542258959482891', nickname: 'いいだ')

  ALL = [
    NISSHIEE,
    ARUMI,
    MITSUYOSHI,
    TEI,
    IICYAN,
  ].freeze

  def self.find(id)
    ALL.find { |u| u.id == id }
  end
end
