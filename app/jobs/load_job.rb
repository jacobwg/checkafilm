class LoadJob
  include Resque::Plugins::UniqueJob

  @queue = :titles

  def self.perform(title_id)
    title = Title.find(title_id)
    title.load! if title
  end

end
