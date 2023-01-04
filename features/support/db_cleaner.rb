Cucumber::Rails::Database.autorun_database_cleaner = false
Cucumber::Rails::World.use_transactional_tests = false
Cucumber::Rails::Database.javascript_strategy = :truncation

Before do
  DatabaseRewinder.clean
end

After do
  DatabaseRewinder.clean_all
end