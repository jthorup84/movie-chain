module Imdb
  BASE_DOMAIN = "https://www.imdb.com"
  class GetActorsFromMovie
    def initialize(movie_id:)
      @movie_id = movie_id
    end

    def call
      html = HTTParty.get(url)
      parsed_html = Nokogiri::HTML(html)
      actor_rows = parsed_html.css(".cast_list").css("tr")
      actor_rows.collect do |actor_row|
        next unless actor_row.css("td")[1].present?
        {
          name: actor_row.css("td")[1].text.strip,
          actor_id: actor_row.css("td")[1].css("a").first.attributes["href"].value.split("/")[2]
        }
      end.compact
    end

  private
    attr_reader :movie_id

    def url
      "#{BASE_DOMAIN}/title/#{movie_id}/fullcredits"
    end
  end
end