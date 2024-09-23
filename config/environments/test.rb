Rails.application.configure do
  # DB will always be setup in wagon spec_helper
  # For some reason if we run maintain_test_schema! in the core spec_helper it breaks because of multiple DB accesses
  config.active_record.maintain_test_schema = false
  

  # Do not eager load because of DB setup getting screwed
  config.eager_load = false
end
