module Imdb
  BASE_DOMAIN = "https://www.imdb.com"
  class GetMoviesFromActor
    def initialize(actor_id:)
      @actor_id = actor_id
    end

    def call
      html = HTTParty.get(url)
      parsed_html = Nokogiri::HTML(html)
      actor_header_index = parsed_html.css("#filmography").children.css("div").find_index do |div|
        div.attributes["id"]&.value.in? ["filmo-head-actor", "filmo-head-actress"]
      end
      return [] unless actor_header_index.present?
      show_rows = parsed_html.css("#filmography").children.css("div")[actor_header_index + 1].css(".filmo-row")
      movie_rows = show_rows.reject do |show_row|
        show_row.children.select { |c| c.name == "text" }.any? do |text|
          (text.text =~ /series/i).present? || (text.text =~ /video game/i).present?
        end
      end
      movie_rows.collect do |movie_row|
        {
          name: movie_row.css("a").first.children.first.text,
          movie_id: movie_row.attributes["id"].value.split("-").last
        }
      end
    end

  private
    attr_reader :actor_id

    def url
      "#{BASE_DOMAIN}/name/#{actor_id}"
    end
  end
end