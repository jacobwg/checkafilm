if FileTest.exist?(Rails.root.join('.env'))
  File.open(Rails.root.join('.env'), 'r') do |file|
    file.each_line do |l|
      puts l.split('=')
      #ENV[parts.first] = parts.last
    end
  end
end