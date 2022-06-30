# frozen_string_literal: true

module Aserto
  VERSION = File.read(
    File.join(__dir__, "..", "..", "VERSION")
  ).chomp
end
