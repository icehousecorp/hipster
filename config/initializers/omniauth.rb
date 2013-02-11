Rails.application.config.middleware.use OmniAuth::Builder do
  provider :harvest, 'lpU2PAFA1XDdrqMEQKE2hA==', 's4epXu9Rreu2vAApbOwnqiY+AwXqOm2oDcld5nlxY9iIE9yiUvaLtitkOBKJ1f201qvp5HzGDdqEjg72/4MwEQ=='
  provider :google_oauth2, "952086453504.apps.googleusercontent.com", "Dk8BHR-RAEgghBc0xWZNAArV"
end
