if Rails.env.production?
  ActionMailer::Base.default_url_options[:host] = "timit.chemie.uni-freiburg.de"
  ActionMailer::Base.delivery_method = :sendmail
end

if Rails.env.test?
  ActionMailer::Base.default_url_options[:host] = "localhost:3000"
  ActionMailer::Base.delivery_method = :test
end

if Rails.env.development?
  #ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.default_url_options[:host] = "localhost:3000"
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
  #:address => "physchem.uni-freiburg.de",
  #:port => 25,
  #:authentication => :plain,
  #:user_name => "",
  #:password => ""
   :address => "smtp.tuxwerk.de",
   :port => 25,
   :authentication => :plain,
   :user_name => "widu@radgeber-freiburg.de",
   :password => "WatG8Kl1a"
  }
  #ActionMailer::Base.raise_delivery_errors = true
end
