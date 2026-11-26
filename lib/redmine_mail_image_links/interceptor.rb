# frozen_string_literal: true

# Redmine Mail Image Links
# Copyright (C) 2026  The redmine_mail_image_links contributors
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

module RedmineMailImageLinks
  # ActionMailer interceptor: rewrites the HTML part of every outgoing email
  # right before delivery. The filter is idempotent, so running it twice
  # (e.g. after a code reload in development) does no harm.
  class Interceptor
    def self.delivering_email(message)
      part = html_part_of(message)
      return if part.nil?

      html = part.decoded
      filtered = HtmlFilter.new(link_text: link_text).call(html)
      return if filtered.equal?(html)

      part.body = filtered
    rescue StandardError => e
      # Never block a notification because of this plugin.
      Rails.logger.error("[redmine_mail_image_links] #{e.class}: #{e.message}")
    end

    def self.html_part_of(message)
      return message.html_part if message.multipart?

      message.mime_type == 'text/html' ? message : nil
    end

    def self.link_text
      configured = Setting.plugin_redmine_mail_image_links['link_text'].to_s.strip
      return configured unless configured.empty?

      ::I18n.t(:mail_image_links_default_link_text,
               locale: Setting.default_language.presence || :en,
               default: HtmlFilter::DEFAULT_LINK_TEXT)
    end
  end
end
