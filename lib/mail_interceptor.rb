class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "TIMIT-DEV to: #{message.to.flatten.join(' ')}, subj: #{message.subject}"
    message.to = "christian.wittekindt@physchem.uni-freiburg.de"
    #message.content_type = "text/html"
  end
end
