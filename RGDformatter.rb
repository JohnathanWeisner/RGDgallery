require 'nokogiri'
require 'open-uri'
require 'httparty'

HOME = "http://www.reddit.com"
HTMLEND = "/r/redditgetsdrawn"

# A typical post will look like this unformatted:
# 	<div class="entry unvoted">
#   	<p class="title"><a class="title " href="http://imgur.com/LVJy5YG" tabindex="1">Please draw my grandparents! It was just their 50th anniversary!</a>&#32;
#     	<span class="domain">(<a href="/domain/imgur.com/">imgur.com</a>)</span>
#     </p>
#     <p class="tagline">submitted&#32;
#     	<time title="Sun Mar 9 14:18:03 2014 UTC" datetime="2014-03-09T14:18:03+00:00">16 hours</time>&#32;ago&#32;by&#32;<a href="http://www.reddit.com/user/jgordon02" class="author id-t2_4ja0p">jgordon02</a>
#     	<span class="userattrs"></span>
#     </p>
#     <ul class="flat-list buttons">
#     	<li class="first"><a class="comments" href="http://www.reddit.com/r/redditgetsdrawn/comments/1zysx2/please_draw_my_grandparents_it_was_just_their/" target="_parent">143 comments</a>
#     	</li>
#     	<li class="share">
#     		<span class="share-button toggle" style=""><a class="option active login-required" href="#" tabindex="100">share</a><a class="option " href="#">cancel</a>
#     		</span>
#     	</li>
#     </ul>
#     <div class="expando" style='display: none'>
#     	<span class="error">loading...</span>
#     </div>
#   </div>
#
#
# Use this example as a guide for what CSSquery you'll need to get at the information you're looking for.
class Post
  attr_reader :post
	attr_accessor :submitter,:ref_link,:comments_link,:title,:timestamp,:artworks
	def initialize(post)
		@post          = post
		@ref_link      = self.get_ref_link
		@title         = self.get_title
		@submitter     = self.get_submitter
		@timestamp     = self.get_timestamp
		@comments_link = self.get_comments_link
		@artworks      = self.get_artworks
	end

	# This method already works. It grabs the href of the reference image and formats it properly
	# so the image link is usable.
	def get_ref_link
		ref_links = post.css('.title a').map { |link| link["href"]}
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

	# Phase 1 Method
	#
	# return the title of the post
	# Example "<a class="title " href="http://imgur.com/LVJy5YG" tabindex="1">Please draw my grandparents! It was just their 50th anniversary!</a>&#32;"
	# get_title will only return "Please draw my grandparents! It was just their 50th anniversary!"
	#
	def get_title  
	end

	# Phase 1 Method
	#
	# return the submitter as a Submitter object (See Submitter class)
	# Example "<a href="http://www.reddit.com/user/jgordon02" class="author id-t2_4ja0p">jgordon02</a>"
	# submitter.username => jgordon02
	# submitter.user_link => http://www.reddit.com/user/jgordon02
	#
	def get_submitter 
	end

	# Phase 1 Method
	#
	# return the timestamp of when the reference was originially submitted
	# Example <p class="tagline">submitted&#32;
    #           <time title="Sun Mar 9 14:18:03 2014 UTC" datetime="2014-03-09T14:18:03+00:00">16 hours</time>&#32;ago&#32;by&#32;<a href="http://www.reddit.com/user/jgordon02" class="author id-t2_4ja0p">jgordon02</a>
    #           <span class="userattrs"></span>
    #         </p>
    # get_timestamp => "2014-03-09T14:18:03+00:00"
    #
	def get_timestamp
	end

	# Phase 1 Method
	#
	# return the link as a string to the comments page
	# Example <li class="first"><a class="comments" href="http://www.reddit.com/r/redditgetsdrawn/comments/1zysx2/please_draw_my_grandparents_it_was_just_their/" target="_parent">143 comments</a>
	# get_comments_link => "http://www.reddit.com/r/redditgetsdrawn/comments/1zysx2/please_draw_my_grandparents_it_was_just_their/"
	def get_comments_link
	end

	# Phase 1.5 Method (Complete all Phase 1 methods before working on this)
	#
	# This method will be for phase 1.5 where we need to return all of the first level comments after going to @comments_link
	# The comments will be stored in an array.
	def get_first_level_comments 
	end

	# Phase 1.5 Method (Complete all Phase 1 methods before working on this)
	#
	# Within this method we will call get_first_level_comments and then format the information into Artwork objects
	def get_artworks
	end

end

# This class may need to be fleshed out more
class Submitter
	attr_accessor :username, :user_link
	def initialize()
	end
end

# This class may need to be fleshed out more
class Artwork
	attr_accessor :link, :submitter, :timestamp, :upvotes
	def initialize()
	end
end


doc = Nokogiri::HTML(open(HOME + HTMLEND))
posts = doc.css('.entry')
posts_formatted = []

# Adds the Post object to the posts_formatted array
posts.each_with_index{|post,index|
	posts_formatted << Post.new(post)
}

#this is just a test call to make sure we have all of the reference picture links formatted correctly
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
