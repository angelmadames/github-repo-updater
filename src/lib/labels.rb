# frozen_string_literal: true

require 'json'

module Labels
  module_function

  def client
    Http.client(Config::Github.endpoints[:base], Config::Github.headers)
  end

  def add(labels)
    puts '➕ Adding labels…'

    labels.each do |name, color|
      if Config::Labels.colors.include? name
        puts "➡️ Already added: #{name}"
        next
      end

      body = {
        name:  name,
        color: color
      }.to_json

      res = client.post(Config::Github.endpoints[:repo_label], body)
      Http.handle_response(res, '✅ Added', name)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def remove
    puts '🗑️ Removing labels…'

    res    = client.get(Config::Github.endpoints[:repo_label])
    labels = JSON.parse(res.body)

    labels_to_remove = labels.map { |label| label['name'] }

    labels_to_remove.each do |name|
      if Config::Labels.colors.include? name
        puts "➡️ Not removed, meant to be added: #{name}"
        next
      end

      encoded_label = Http.uri_encode(name)

      res = client.delete("#{Config::Github.endpoints[:repo_label]}/#{encoded_label}")
      Http.handle_response(res, '✅ Removed', name)
    end
  end
  # rubocop:enable Metrics/AbcSize
end
