# frozen_string_literal: true

# Runs inside Redmine only:
#   bin/rails redmine:plugins:test NAME=redmine_mail_image_links RAILS_ENV=test
require_relative '../test_helper'

class MailerWithImageLinksTest < ActiveSupport::TestCase
  include Redmine::I18n

  IMAGE_URL = 'https://images.example.com/screenshot.png'
  # Markdown (CommonMark) image, the default text formatting since Redmine 6
  IMAGE = "![screenshot](#{IMAGE_URL})"

  def setup
    ActionMailer::Base.deliveries.clear
    Setting.plain_text_mail = '0'
    Setting.default_language = 'en'
    Setting.text_formatting = 'common_mark'
    User.current = nil
  end

  def last_email
    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    mail
  end

  def html_of(mail)
    mail.html_part.decoded
  end

  def test_inline_image_is_replaced_with_link
    issue = Issue.generate!(description: "Screenshot:\n\n#{IMAGE}")
    assert Mailer.deliver_issue_add(issue)

    html = html_of(last_email)
    assert_no_match(/<img/i, html)
    assert_includes html, %(<a href="#{IMAGE_URL}">[Open image]</a>)
  end

  def test_textile_image_is_replaced_with_link
    with_settings text_formatting: 'textile' do
      issue = Issue.generate!(description: "Screenshot:\n\n!#{IMAGE_URL}!")
      assert Mailer.deliver_issue_add(issue)
    end

    html = html_of(last_email)
    assert_no_match(/<img/i, html)
    assert_includes html, %(<a href="#{IMAGE_URL}">[Open image]</a>)
  end

  def test_text_part_is_not_changed
    issue = Issue.generate!(description: IMAGE)
    assert Mailer.deliver_issue_add(issue)

    assert_includes last_email.text_part.decoded, IMAGE_URL
  end

  def test_thumbnail_macro_keeps_link_to_attachment
    set_tmp_attachments_directory
    issue = Issue.generate!(description: '{{thumbnail(image.png)}}')
    issue.attachments << Attachment.new(
      file: mock_file_with_options(original_filename: 'image.png'),
      author: User.find(1)
    )
    issue.save!

    assert Mailer.deliver_issue_add(issue)
    html = html_of(last_email)
    assert_no_match(/<img/i, html)
    assert_match %r{<a [^>]*href="http://localhost:3000/attachments/\d+[^"]*"[^>]*>\[Open image\]</a>}, html
  end

  def test_link_text_from_plugin_setting
    with_settings plugin_redmine_mail_image_links: { 'link_text' => '[Bild öffnen]' } do
      issue = Issue.generate!(description: IMAGE)
      assert Mailer.deliver_issue_add(issue)
    end

    assert_includes html_of(last_email), %(<a href="#{IMAGE_URL}">[Bild öffnen]</a>)
  end

  def test_default_link_text_follows_default_language
    with_settings default_language: 'de' do
      issue = Issue.generate!(description: IMAGE)
      assert Mailer.deliver_issue_add(issue)
    end

    assert_includes html_of(last_email), '[Bild öffnen]'
  end

  def test_encoded_mail_round_trips
    issue = Issue.generate!(description: "Größe ändern: #{IMAGE}")
    assert Mailer.deliver_issue_add(issue)

    reparsed = Mail.new(last_email.encoded)
    html = reparsed.html_part.decoded
    assert_includes html, 'Größe ändern'
    assert_includes html, '[Open image]'
    assert_no_match(/<img/i, html)
  end

  def test_plain_text_mail_setting_still_works
    with_settings plain_text_mail: '1' do
      issue = Issue.generate!(description: IMAGE)
      assert Mailer.deliver_issue_add(issue)
    end

    assert_nil last_email.html_part
    assert_includes last_email.body.decoded, IMAGE_URL
  end
end
