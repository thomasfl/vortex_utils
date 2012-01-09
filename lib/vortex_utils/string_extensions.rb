# -*- coding: utf-8 -*-
require 'iconv'

# Utilities useful for adding content to Content Management Systems

class String

  # Turn a normal sentence into a valid, readable filename.
  #
  # Example:
  #
  #    "A small test".to_readable_url
  #     => "a-small-test"
  def to_readable_url
    sentence = self
    if(sentence.size > 10)then
      truncated_title = sentence.sub(/:.*/,"").sub(/;/,"").sub(/&/,"").sub(/\(/,"").sub(/\)/,"")
      html_filename = truncated_title.snake_case
    else
      html_filename = sentence.snake_case
    end

    # Just keep the 100 first chars, to nearest word.
    if(html_filename.size > 100)then
      html_filename = html_filename.gsub(/\.html$/,"")
      html_filename = html_filename[0..100]
      html_filename = html_filename.gsub(/_[^_]*$/,"") + ".html"
    end
    return html_filename
  end

  def snake_case
    camel_cased_word_input = self
    camel_cased_word = camel_cased_word_input + "" # create local copy of string
    camel_cased_word = camel_cased_word.transliterate_accents
    camel_cased_word = camel_cased_word.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1\2').
      gsub(/([a-z\d])([A-Z])/,'\1\2').downcase

    camel_cased_word = camel_cased_word.to_s.gsub(/ /,'-')
    camel_cased_word = camel_cased_word.to_s.gsub(/^_/,'')
    camel_cased_word = camel_cased_word.gsub("__","_")

    # sanitize the string
    camel_cased_word = camel_cased_word.gsub(/[^a-z._0-9 -]/i, "").
      tr(".", "_").gsub(/(\s+)/, "_").gsub(/_/, '-').downcase
    camel_cased_word = camel_cased_word.to_s.gsub(/--*/,'-')
    return camel_cased_word
  end

  # Filter accents and some special characters
  def transliterate_accents
    str = self
    accents = {
      ['á','à','â','ä','ã','Ã','Ä','Â','À'] => 'a',
      ['é','è','ê','ë','Ë','É','È','Ê'] => 'e',
      ['í','ì','î','ï','I','Î','Ì'] => 'i',
      ['ó','ò','ô','ö','õ','Õ','Ö','Ô','Ò'] => 'o',
      ['ñ'] => 'n',
      ['œ'] => 'e',
      ['ß'] => 'ss',
      ['ú','ù','û','ü','U','Û','Ù'] => 'u',
      ['æ'] => 'ae',
      ['ø'] => 'o',
      ['å'] => 'a',
      ['Æ'] => 'ae',
      ['Ø'] => 'o',
      ['Å'] => 'a',
      ['§'] => ''
    }
    accents.each do |ac,rep|
      ac.each do |s|
        str.gsub!(s, rep)
      end
    end

    # Remove the rest of the accents and special characters
    conv = Iconv.new("ASCII//TRANSLIT//IGNORE", "UTF-8")
    str = conv.iconv(str)
    return str
  end

end
