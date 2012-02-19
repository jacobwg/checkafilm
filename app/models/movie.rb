class Movie < ActiveRecord::Base

  validates :imdbid, :title, :presence
  validates :kim_sex, :kim_violence, :kim_language, :inclusion => { :in => 0..10 }

end
