#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"

module Color
  def self.green(s)  = "\e[32m#{s}\e[0m"
  def self.cyan(s)   = "\e[36m#{s}\e[0m"
  def self.yellow(s) = "\e[33m#{s}\e[0m"
  def self.bold(s)   = "\e[1m#{s}\e[0m"
  def self.dim(s)    = "\e[2m#{s}\e[0m"
end

module Romaji
  MACRONS = { "a" => "ā", "i" => "ī", "u" => "ū", "e" => "ē", "o" => "ō" }.freeze

  COMPOUNDS = {
    "キャ" => "kya", "キュ" => "kyu", "キョ" => "kyo", "ギャ" => "gya", "ギュ" => "gyu", "ギョ" => "gyo",
    "シャ" => "sha", "シュ" => "shu", "シェ" => "she", "ショ" => "sho",
    "ジャ" => "ja",  "ジュ" => "ju",  "ジェ" => "je",  "ジョ" => "jo",
    "チャ" => "cha", "チュ" => "chu", "チェ" => "che", "チョ" => "cho",
    "ニャ" => "nya", "ニュ" => "nyu", "ニョ" => "nyo",
    "ヒャ" => "hya", "ヒュ" => "hyu", "ヒョ" => "hyo", "ビャ" => "bya", "ビュ" => "byu", "ビョ" => "byo",
    "ピャ" => "pya", "ピュ" => "pyu", "ピョ" => "pyo", "ミャ" => "mya", "ミュ" => "myu", "ミョ" => "myo",
    "リャ" => "rya", "リュ" => "ryu", "リョ" => "ryo",
    "ティ" => "ti",  "ディ" => "di",  "トゥ" => "tu",  "ドゥ" => "du",  "テュ" => "tyu", "デュ" => "dyu",
    "ファ" => "fa",  "フィ" => "fi",  "フェ" => "fe",  "フォ" => "fo",  "フュ" => "fyu",
    "ウィ" => "wi",  "ウェ" => "we",  "ウォ" => "wo",  "イェ" => "ye",
    "ヴァ" => "va",  "ヴィ" => "vi",  "ヴ"   => "vu",  "ヴェ" => "ve",  "ヴォ" => "vo",
    "ツァ" => "tsa", "ツィ" => "tsi", "ツェ" => "tse", "ツォ" => "tso",
    "クァ" => "kwa", "クィ" => "kwi", "クェ" => "kwe", "クォ" => "kwo"
  }.freeze

  ROWS = {
    ""  => "アイウエオ", "k" => "カキクケコ", "s" => "サシスセソ", "t" => "タチツテト",
    "n" => "ナニヌネノ", "h" => "ハヒフヘホ", "m" => "マミムメモ", "r" => "ラリルレロ",
    "g" => "ガギグゲゴ", "z" => "ザジズゼゾ", "d" => "ダヂヅデド", "b" => "バビブベボ", "p" => "パピプペポ"
  }.freeze

  BASIC = ROWS.each_with_object({}) do |(c, kana), map|
    %w[a i u e o].each_with_index { |v, i| map[kana[i]] = "#{c}#{v}".freeze }
  end.merge(
    "シ" => "shi", "チ" => "chi", "ツ" => "tsu", "フ" => "fu",
    "ジ" => "ji",  "ヂ" => "ji",  "ヅ" => "zu",
    "ヤ" => "ya",  "ユ" => "yu",  "ヨ" => "yo",
    "ワ" => "wa",  "ヲ" => "o",   "ン" => "n"
  ).freeze

  TABLE = COMPOUNDS.merge(BASIC).freeze

  def self.convert(text)
    return "" if text.nil? || text.empty?

    str = text.to_s.unicode_normalize(:nfkc).gsub("&nbsp;", " ").gsub(/\b([A-Za-z])(?=\p{Katakana})/, "\\1-")
    out = []
    i = 0

    while i < str.length
      char = str[i]
      if char == "ー"
        if out.last && (macron = MACRONS[out.last[-1]])
          out[-1] = out.last[0...-1] + macron
        end
      elsif char == "ッ"
        nxt = TABLE[str[i + 1, 2]] || TABLE[str[i + 1, 1]]
        out << (nxt&.start_with?("ch") ? "t" : nxt&.chr) if nxt
      elsif (r = TABLE[str[i, 2]])
        out << r
        i += 2
        next
      elsif (r = TABLE[char])
        out << r
      else
        out << char
      end
      i += 1
    end

    out.join.strip
  end
end

def update_deck(file_path, overwrite: false, dry_run: false)
  deck    = JSON.parse(File.read(file_path, encoding: "UTF-8"))
  notes   = deck["notes"] || []
  updated = 0

  notes.each do |note|
    fields = note["fields"]
    next unless fields.is_a?(Array) && fields.size > 6

    katakana, current = fields[0].to_s.strip, fields[6].to_s.strip
    next if !current.empty? && !overwrite

    romaji = Romaji.convert(katakana)
    next if romaji.empty? || romaji == current

    fields[6] = romaji
    updated += 1
  end

  puts "#{Color.bold('deck.json:')} #{Color.cyan(file_path)}"
  puts "#{Color.bold('Scanned:')}   #{Color.yellow(notes.size)} notes"
  puts "#{Color.bold('Updated:')}   #{Color.green(updated)} notes"

  return puts(Color.dim("Dry run: no changes written.")) if dry_run
  return puts(Color.dim("No updates needed.")) if updated.zero?

  File.write(file_path, JSON.pretty_generate(deck, indent: "    ") + "\n", encoding: "UTF-8")
  puts Color.green("✓ Successfully updated #{file_path}")
end

if __FILE__ == $PROGRAM_NAME
  options = { overwrite: false, dry_run: false }
  parser  = OptionParser.new do |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options] [deck.json]"
    opts.on("-f", "--overwrite", "Overwrite existing Romaji fields") { options[:overwrite] = true }
    opts.on("-d", "--dry-run", "Preview changes without saving")     { options[:dry_run] = true }
  end
  parser.parse!(ARGV)

  target = ARGV[0] || File.expand_path("../deck.json", __dir__)
  update_deck(target, **options)
end
