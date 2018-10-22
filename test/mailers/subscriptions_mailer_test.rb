require 'test_helper'

class SubscriptionsMailerTest < ActionMailer::TestCase
  test "jobs" do
    mail = SubscriptionsMailer.jobs
    assert_equal "Jobs", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
