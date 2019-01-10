PROBLEM_REPORT_SPAM_MATCHERS = [
  # a cursory Google search suggests that the following pattern is generated by the WebCruiser
  # scanning tool
  lambda { |ticket| ticket.what_wrong =~ /WCRTESTINP/ },
  # as above
  lambda { |ticket| ticket.what_doing =~ /WCRTESTINP/ },

  # get rid of very low-quality feedback where "what_wrong" and "what_doing" are
  # either single words or missing completely
  lambda { |ticket| !ticket.what_wrong.include?(" ") && !ticket.what_doing.include?(" ") },
].freeze
