# frozen_string_literal: true

require_relative '../test_helper'

class HtmlFilterTest < MailImageLinksTestCase
  def filter(text = '[Image]')
    RedmineMailImageLinks::HtmlFilter.new(link_text: text)
  end

  def test_returns_same_object_without_images
    html = '<p>No images here</p>'
    assert_same html, filter.call(html)
  end

  def test_handles_nil
    assert_nil filter.call(nil)
  end

  def test_replaces_plain_image_with_link
    html = '<p>Look: <img src="https://redmine.example.com/attachments/download/12/shot.png" alt="" /></p>'
    assert_equal '<p>Look: <a href="https://redmine.example.com/attachments/download/12/shot.png">[Image]</a></p>',
                 filter.call(html)
  end

  def test_single_quoted_and_unquoted_src
    assert_equal '<a href="https://x.test/a.png">[Image]</a>', filter.call("<img alt='a' src='https://x.test/a.png'>")
    assert_equal '<a href="https://x.test/b.png">[Image]</a>', filter.call('<img src=https://x.test/b.png>')
  end

  def test_keeps_existing_link_around_thumbnail
    html = '<a href="https://r.test/attachments/3" class="thumbnail" title="s.png">' \
           '<img src="https://r.test/attachments/thumbnail/3/200" alt="s.png" /></a>'
    assert_equal '<a href="https://r.test/attachments/3" class="thumbnail" title="s.png">[Image]</a>',
                 filter.call(html)
  end

  def test_linked_image_with_whitespace_and_newlines
    html = "<a href=\"https://r.test/x\">\n  <IMG\n src=\"https://r.test/y.png\">\n</a>"
    assert_equal '<a href="https://r.test/x">[Image]</a>', filter.call(html)
  end

  def test_multiple_images
    html = '<img src="https://r.test/1.png"><p>x</p><img src="https://r.test/2.png">'
    result = filter.call(html)
    assert_equal 2, result.scan('[Image]').size
    refute_match(/<img/i, result)
  end

  def test_non_http_sources_become_label_only
    assert_equal '[Image]', filter.call('<img src="cid:abc@local">')
    assert_equal '[Image]', filter.call('<img src="data:image/png;base64,AAAA">')
    assert_equal '[Image]', filter.call('<img src="javascript:alert(1)">')
    assert_equal '[Image]', filter.call('<img src="/attachments/download/1/x.png">')
    assert_equal '[Image]', filter.call('<img alt="no source">')
  end

  def test_escapes_link_text
    assert_equal '<a href="https://r.test/1.png">&lt;b&gt;Bild&lt;/b&gt;</a>',
                 filter('<b>Bild</b>').call('<img src="https://r.test/1.png">')
  end

  def test_blank_link_text_falls_back_to_default
    assert_equal '[Image]', filter('  ').link_text
  end

  def test_keeps_query_string_entities
    html = '<img src="https://r.test/i.png?a=1&amp;b=2">'
    assert_equal '<a href="https://r.test/i.png?a=1&amp;b=2">[Image]</a>', filter.call(html)
  end

  def test_does_not_touch_similar_tags
    html = '<p><imgx src="https://r.test/1.png"></p><code>&lt;img src="x"&gt;</code>'
    assert_same html, filter.call(html)
  end

  def test_is_idempotent
    once = filter.call('<a href="https://r.test/a"><img src="https://r.test/t"></a> <img src="https://r.test/b.png">')
    assert_same once, filter.call(once)
  end

  def test_keeps_utf8_content
    html = '<p>Größe: <img src="https://r.test/ä.png"> – fertig</p>'
    assert_equal '<p>Größe: <a href="https://r.test/ä.png">[Bild öffnen]</a> – fertig</p>',
                 filter('[Bild öffnen]').call(html)
  end
end
