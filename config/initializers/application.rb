APPLICATION = YAML.load_file("#{Rails.root.to_s}/config/application.yml")[Rails.env]
