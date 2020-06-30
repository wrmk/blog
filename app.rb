#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"created_date" DATE,
		"content" TEXT
	);'
end

get '/' do

	@results = @db.execute 'SELECT * FROM Posts ORDER BY ID DESC'

	erb :index
end

get '/new' do
	erb :new
end

post '/new' do
	content = params[:content]

	if content.length <= 0
		@error = 'type your text'
		return erb :new
	end

	@db.execute 'INSERT INTO Posts (content, created_date) values (?,datetime())', [content]

	redirect to '/'
	erb  "you type #{content}" 
end

get '/details/:post_id' do
	post_id = params[:post_id]

	results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
	@row = results[0]

	erb :details
end