require 'active_record'

class Entry < ActiveRecord::Base

  attr_accessor :title, :link, :description

  def initialize(title, link, description)
    @title = title
    @link = link
    @description = description
  end

  def show
    "#### " + @title + ":" + @link
  end

  def self.find_all
    entries = Entry.all
    retEntries = []
    for entry in entries
      retEntries.push(Entry.convert(entry))
    end

    retEntries
  end

  def self.convert(entry)
    Entry.new(entry["title"], entry["link"], entry["description"])
  end
end