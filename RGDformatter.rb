require 'nokogiri'
require 'open-uri'
require 'httparty'

home = "http://www.reddit.com"
htmlend = "/r/redditgetsdrawn"
class Post
	attr_accessor :submitter,:ref_link,:title,:date,:artworks
	def initialize(post)
		@post = post
		@ref_link = self.get_ref_link
		@artworks = []
	end

	def get_ref_link
		ref_links = @post.css('.title a').map { |link| link["href"]}
		ref_links.select do |link|
			unless link.include?("/domain/") || link.include?("/r/redditgetsdrawn/")
				if link.include?("i.imgur")
					link
				else 
					link.gsub!(/imgur/,"i.imgur").insert(-1, ".jpg")
				end
			end
		end
	end
end



@doc = Nokogiri::HTML(open(home + htmlend))
posts = @doc.css('.entry')
posts_formatted = []
posts.each_with_index{|post,index|
	posts_formatted << Post.new(post)
}

posts_formatted.each{|post|
	puts post.ref_link
}
=begin
files = @doc.css('.title a').map { |link| link["href"]}

files.select! do |file|
	unless file.include?("/domain/") || file.include?("/r/redditgetsdrawn/")
		if file.include?("i.imgur")
			file
		else 
			file.gsub!(/imgur/,"i.imgur").insert(-1, ".jpg")
		end
	end
end

files.each_with_index do |file,index|
	puts URI.encode(file) + " #{index}"
end
=end