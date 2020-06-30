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

	@db.execute 'CREATE TABLE IF NOT EXISTS Comments
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"created_date" DATE,
		"content" TEXT,
		"post_id" INTEGER
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

	#берем post_id из строки которую набрал пользователь
	post_id = params[:post_id]
	# выцепляем из БД один массив с постом
	results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
	# превращаем массив в хэш, к которому по ключу будем обращаться на странице details
	@row = results[0]

	# выводим комментарии из базы данных
	@comments = @db.execute 'SELECT  * FROM Comments where post_id= ? order by id', [post_id]
 
	erb :details
end

post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]
	@db.execute 'INSERT INTO Comments (content, created_date, post_id) values (?,datetime(), ?)', [content, post_id]
	redirect to('/details/' + post_id)
end	