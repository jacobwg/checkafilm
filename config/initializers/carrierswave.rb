CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => Settings.aws_key,
    :aws_secret_access_key  => Settings.aws_secret,
#    :region                 => 'eu-west-1'
  }
  config.fog_directory  = 'jacobwg'                     # required
#  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
end
