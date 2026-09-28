#!/usr/bin/env ruby
# frozen_string_literal: true


require "json"
require "csv"

BASE_DIR = File.expand_path("..", __dir__)

JSON_FILE = File.join(BASE_DIR, "deck.json")
CSV_FILE  = File.join(__dir__, "waseigo.csv")
OUT_FILE  = File.join(__dir__, "missing.csv")

# Normalize Japanese/text for comparison.
# - NFKC: normalizes Unicode forms
# - downcase: handles Latin text
# - removes ALL whitespace
# - removes common brackets
def normalize(s)
  s.to_s
   .unicode_normalize(:nfkc)
   .downcase
   .gsub(/\s+/, "")
   .gsub(/[「」『』【】（）()［］\[\]]/, "")
   .strip
end

# ------------------------------------------------------------
# Load deck
# ------------------------------------------------------------

puts "Loading #{JSON_FILE}..."

deck = JSON.parse(
  File.read(JSON_FILE, encoding: "UTF-8")
)

# ------------------------------------------------------------
# Extract ONLY note fields
# ------------------------------------------------------------

field_values = []

def extract_fields(obj, result)
  case obj
  when Hash
    if obj["__type__"] == "Note" && obj["fields"].is_a?(Array)
      obj["fields"].each do |field|
        result << field.to_s
      end
    else
      obj.each_value do |value|
        extract_fields(value, result)
      end
    end

  when Array
    obj.each do |value|
      extract_fields(value, result)
    end
  end
end

extract_fields(deck, field_values)

# Normalize all Anki fields
anki_fields = field_values.map { |field| normalize(field) }

puts "Found #{field_values.length} Anki fields."

# ------------------------------------------------------------
# Read waseigo.csv
# ------------------------------------------------------------

missing = []

CSV.foreach(
  CSV_FILE,
  encoding: "UTF-8",
  headers: false
) do |row|

  next if row.nil? || row.empty?

  original = row[0].to_s.strip

  next if original.empty?

  # Skip header
  next if normalize(original) == "katakana"

  # Split alternatives such as:
  #
  # アルバイト or バイト
  # ガス or 瓦斯
  # パソコン; パーソナルコンピューター
  #
  alternatives = original
    .split(/\s+(?:or)\s+|;/i)
    .map(&:strip)
    .reject(&:empty?)

  alternatives = [original] if alternatives.empty?

  # ----------------------------------------------------------
  # Check every alternative
  # ----------------------------------------------------------

  found = alternatives.any? do |candidate|

    candidate = normalize(candidate)

    next true if candidate.empty?

    anki_fields.any? do |field|
      field.include?(candidate)
    end

  end

  missing << original unless found
end

# ------------------------------------------------------------
# Write output
# ------------------------------------------------------------

CSV.open(
  OUT_FILE,
  "w",
  encoding: "UTF-8"
) do |csv|

  missing.each do |word|
    csv << [word]
  end
end

puts
puts "========================================"
puts "Done!"
puts "Missing: #{missing.length}"
puts "Output:  #{OUT_FILE}"
puts "========================================"
