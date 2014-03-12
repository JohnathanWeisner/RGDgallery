require 'nokogiri'
require 'open-uri'


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
		@artworks      = self.get_artworks(get_first_level_comments)
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
		return post.css('p.title a.title').each {|title| puts title.text}	
	end

	# Phase 1 Method
	#
	# return the submitter as a Submitter object (See Submitter class)
	# Example "<a href="http://www.reddit.com/user/jgordon02" class="author id-t2_4ja0p">jgordon02</a>"
	# submitter.username => jgordon02
	# submitter.user_link => http://www.reddit.com/user/jgordon02
	#
	def get_submitter
		Submitter.new(post) # Be weary of creating dependencies like these which don't promote easy future changes. Suggest reading of Chapter 3 Practical OO Design in Ruby 
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
		time = post.at_css('time')["datetime"]
	end

	# Phase 1 Method
	#
	# return the link as a string to the comments page
	# Example <li class="first"><a class="comments" href="http://www.reddit.com/r/redditgetsdrawn/comments/1zysx2/please_draw_my_grandparents_it_was_just_their/" target="_parent">143 comments</a>
	# get_comments_link => "http://www.reddit.com/r/redditgetsdrawn/comments/1zysx2/please_draw_my_grandparents_it_was_just_their/"
	def get_comments_link
		comments_link = post.at_css('.comments')["href"]
	end

	# Phase 1.5 Method (Complete all Phase 1 methods before working on this)
	#
	# This method will be for phase 1.5 where we need to return all of the first level comments after going to @comments_link
	# The comments will be stored in an array.
	def get_first_level_comments
		comments_page = Nokogiri::HTML(open(comments_link))
		child = comments_page.css('.child .entry')
		comments = comments_page.css('.entry').select{|link| 
			!(child.include?(link))
		}
		comments[1..-1] # index 0 would be the initial post so we return all but the index 0
	end

	# Phase 1.5 Method (Complete all Phase 1 methods before working on this)
	#
	# Within this method we will call get_first_level_comments and then format the information into Artwork objects
	def get_artworks(comments) # given an array all of the first_level_comments
		art = comments.map{|comment| Artwork.new(comment)}
	end

end



# Represents the Submitter of the post
class Submitter
	attr_accessor :username, :user_link
	def initialize(post)
		@post = post
		@username  = get_username
		@user_link = get_user_link
	end

	def get_username
		authors = @post.css('.author')
		username = authors.map {|author| author.text.strip}[0]
	end

	def get_user_link
		user_link = "http://www.reddit.com/user/#{username}"
	end

end





#
# An Example Artwork comment
#
#
#  <div class="entry unvoted">
#  	<div class="collapsed" style="display:none">
#  		<a href="#" class="expand" onclick="return showcomment(this)">[+]</a>
#  		<a href="http://www.reddit.com/user/StorytimeWithDudly" class="author gray id-t2_bie55">StorytimeWithDudly</a>
#  		<span class="userattrs"></span> <span class="score dislikes">28 points</span><span class="score unvoted">29 points</span>
#  		<span class="score likes">30 points</span> 
#  		<time title="Tue Mar 11 16:55:29 2014 UTC" datetime="2014-03-11T16:55:29+00:00">1 hour</time> ago  <a href="#" class="expand" onclick="return showcomment(this)">(1 child)</a>
#  	</div>
#  	<div class="noncollapsed">
#  		<p class="tagline">
#  			<a href="#" class="expand" onclick="return hidecomment(this)">[–]</a>
#  			<a href="http://www.reddit.com/user/StorytimeWithDudly" class="author id-t2_bie55">StorytimeWithDudly</a>
#  			<span class="userattrs"></span> <span class="score dislikes">28 points</span><span class="score unvoted">29 points</span>
#  			<span class="score likes">30 points</span> <time title="Tue Mar 11 16:55:29 2014 UTC" datetime="2014-03-11T16:55:29+00:00">1 hour</time> ago
#  		</p>
#  		<form action="#" class="usertext" onsubmit="return post_form(this, 'editusertext')" id="form-t1_cfzxh8dzu4">
#  			<input type="hidden" name="thing_id" value="t1_cfzxh8d">
#  			<div class="usertext-body">
#  				<div class="md">
#  					<p>Second submission to this sub! I really need skin tones...<br><a href="http://imgur.com/lzByaHa">http://imgur.com/lzByaHa</a>      </p>
#  				</div>
#  			</div>
#  		</form>
#  		<ul class="flat-list buttons">
#  			<li class="first">
#  				<a href="http://www.reddit.com/r/redditgetsdrawn/comments/2052uh/my_boyfriend_during_his_african_childhood/cfzxh8d" class="bylink" rel="nofollow">permalink</a>
#  			</li>
#  		</ul>
#  	</div>
#  </div>

class Artwork
	attr_accessor :comment, :link, :submitter, :timestamp, :upvotes
	def initialize(comment)
		@comment = comment
		@link = self.get_art_link
		@submitter = self.get_submitter
		@timestamp = self.get_timestamp
		@upvotes = self.get_upvotes
	end

	# Returns the href for the artwork: if the link is a gallery then the method must open that gallery and grab the first picture in said gallery
	def get_art_link
		links = comment.at_css('.md p a') == nil ? nil : links = comment.at_css('.md p a').attributes["href"].value
	end

	# Returns a Submitter object which includes username and user_link
	def get_submitter
		Submitter.new(@comment)
	end

	# Returns the timestamp for the when the art was submitted
	def get_timestamp
		time = comment.at_css('time')["datetime"]
	end

	# Returns the number of upvotes as an int
	# Example <span class="score likes">30 points</span> 
	# get_upvotes => 30
	def get_upvotes
	    upvotes = comment.at_css('.likes')
	    if upvotes.to_s.empty?
	    	nil
	    else
	    	upvotes.children.text.to_s.split(" ")[0].to_i
	    end
	end
end

doc = Nokogiri::HTML(open(HOME + HTMLEND))
posts = doc.css('.entry')
posts_formatted = []


# Adds the Post object to the posts_formatted array
posts.each_with_index{|post,index|
	posts_formatted << post
#	puts posts_formatted[index]
#	puts "Artwork Submitter Username: #{posts_formatted[index].artworks.at(0).submitter.username}"
#	puts "Artwork Submitter Link: #{posts_formatted[index].artworks.at(0).submitter.user_link}"
#	p posts_formatted[index].comments_link
}

posts_formatted.each_with_index do |post, index|
	puts "The post in posts_formatted array at index ##{index}:"
	puts "Title"
	puts "post.title : #{post.title}"
	puts "Reference picture"
	puts "post.ref_link : #{post.ref_link}"
	puts "Submitter"
	puts "post.submitter.username : #{post.submitter.username}"
	puts "post.submitter.user_link : #{post.submitter.user_link}"
	puts "Time Submitted"
	puts "post.timestamp : #{post.timestamp}"
	puts "Link to the comments section of the post"
	puts "post.comments_link : #{post.comments_link}"
	puts "Iterating through the artworks array of this post we get"
	post.artworks.each_with_index{|artwork, index|
		puts "Artwork at index ##{index}"
		puts "Artwork Link"
		puts "posts.artworks[#{index}].link : #{artwork.link}"
		puts "Artwork Submitter"
		puts "posts.artworks[#{index}].submitter.username : #{artwork.submitter.username}"
		puts "posts.artworks[#{index}].submitter.user_link : #{artwork.submitter.user_link}"
		puts "Artwork Originially Posted"
		puts "posts.artworks[#{index}].timestamp : #{artwork.timestamp}"
		puts "Artwork Upvotes Count"
		puts "posts.artworks[#{index}].upvotes : #{artwork.upvotes}"
	}
end

# posts_formatted[4].artworks.each {|artwork| p artwork.get_art_link}
#puts posts_formatted[1].get_first_level_comments[0]
#this is just a test call to make sure we have all of the reference picture links formatted correctly
#posts_formatted.each{|post|  
#	puts "Title: #{post.get_title} - RefLink: #{post.ref_link.join} by #{post.get_submitter.username.join} at (#{post.get_submitter.user_link})"
#}
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
