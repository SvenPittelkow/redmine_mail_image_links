# frozen_string_literal: true

# Redmine Mail Image Links
# Copyright (C) 2026  The redmine_mail_image_links contributors
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

Redmine::Plugin.register :redmine_mail_image_links do
  name        'Redmine Mail Image Links'
  author      'GITHUB_OWNER'
  description 'Replaces inline images in notification emails with a link to the image.'
  version     '1.0.0'
  url         'https://github.com/GITHUB_OWNER/redmine_mail_image_links'
  author_url  'https://github.com/GITHUB_OWNER'

  requires_redmine version_or_higher: '6.0.0'

  settings default: { 'link_text' => '' },
           partial: 'settings/redmine_mail_image_links'
end

# init.rb runs inside a to_prepare block (Redmine >= 6), lib/ is autoloaded.
ActionMailer::Base.register_interceptor(RedmineMailImageLinks::Interceptor)
