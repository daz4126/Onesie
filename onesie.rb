########### Onesie ###########
# The All In One Sinatra Bootstrap!
require 'bundler'
Bundler.require

########### configuration & settings ###########
configure do
  set :name, ENV['name'] || 'Onesie'
  set :author, ENV['author'] || 'DAZ'
  set :analytics, ENV['ANALYTICS'] || 'UA-XXXXXXXX-X'

  set :token, ENV['TOKEN'] || 'makethisrandomandhardtoremember'
  set :password, ENV['PASSWORD'] || 'secret'

  set :public_folder, -> { root }
  set :views, -> { root }

  set :js_libraries, %w[ http://cdn.rightjs.org/right.js ]
  set :fonts, :"Ubuntu|Coming+Soon|Lemon";

  set :markdown, :layout_engine => :slim

  set :flash, %w[notice error warning alert info]
  enable :sessions
  use Rack::Flash
end

########### Models ###########

# Put your models here

###########  Admin ###########
helpers do
	def admin? ; request.cookies[settings.author] == settings.token ; end
	def protected! ; halt [ 401, 'Not authorized' ] unless admin? ; end
end

get('/admin'){ slim :login }

post '/login' do
	response.set_cookie(settings.author, settings.token) if params[:password] == settings.password
  flash[:notice]='You are now logged in'
	redirect to('/')
end

get '/logout' do
  response.set_cookie(settings.author, false)
  flash[:notice]='You are now logged out'
  redirect to('/')
end

########### Helpers ###########
helpers do
def current?(path='') ; request.path_info=='/'+path ? 'current':  nil ; end

# add your own helpers here ...
end

###########  Routes ###########
not_found { slim :'404' }
get('/styles.css'){ scss :styles }
get('/application.js') { coffee :script }

# home page
get '/' do
  @title = 'The All In One Sinatra Bootstrap!'
  markdown :README
end

get '/:page' do
  markdown params[:page].to_sym
end

###########  Tests ###########
# run tests with $> onesie.rb -test
if ARGV.include? 'test'
  set :environment, :test
  set :run, false
  
  require 'test/unit' 
  require 'rack/test'

  class OnesieTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_it_shows_index_page
      get '/'
      assert last_response.ok?
      assert_equal (slim :index), last_response.body
    end
  end
end
__END__
########### Views ###########

# put your own views here

@@test
This is a test page
--------------------
Testing, testing 1,2,3

@@layout
doctype html
html
  head
    meta charset="utf-8"
    title= "#{settings.name}: #{@title}" || settings.name || "Untitled"
    link rel="shortcut icon" href="/favicon.ico"
    - settings.js_libraries.each do |link|
      script src==link
    script src="/application.js"
    /[if lt IE 9]
      script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"
    link href="http://fonts.googleapis.com/css?family=#{settings.fonts}" rel='stylesheet'
    link rel="stylesheet" media="screen, projection" href="/styles.css"
  body
    header role="banner"
      h1.logo 
        a title="Home, Sweet Home" href="/" = settings.name
      - settings.flash.each do |key|
        - if flash[key]
          div class="alert-message #{key}" == flash[key]
    .content role='main'
      h1= @title
      == yield
    footer role="contentinfo"
      small &copy; Copyright #{settings.author} #{Time.now.year}. All Rights Reserved.
      ==slim :admin,:layout=>false
    javascript:
      var _gaq=[["_setAccount","#{ settings.analytics }"],["_trackPageview"]];(function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];g.async=g.src="//www.google-analytics.com/ga.js";s.parentNode.insertBefore(g,s)}(document,"script"))
  
@@admin
.admin
  -if admin?
    a.admin href='/logout' logout
  -else
    a.admin href='/admin' login (the password is secret)
      
@@login
form action="/login" method="post"
  input type="password" name="password"
  input type="submit" value="Login"

@@404
h1 404! 
p That page is missing

@@script
alert 'Coffeescript is working!'

@@styles
@import "reset";
// fonts
$normalfont: Ubuntu,Helvetica,Arial,sans-serif;
$headingfont:'Lemon',sans-serif;
$basefontsize: 13px;

// colours
$blue: #0055d4;
$green: #9f5;
$background: #fff;
$color: #666;
$headingcolor: $blue;

body{font-family:$normalfont;font-size:$basefontsize;background-color:$background;color:$color;}
h1,h2,h3,h4,h5,h6{margin:0.2em 0;color:$headingcolor;font-family:$headingfont;}

// custom styles
.logo{
font-size:4em;padding-left:64px;
background: url(/logo.png) 0 0 no-repeat;
line-height:64px;
a{
  color:$green;text-decoration:none;
  text-shadow: 1px 1px 1px $blue;
}
}
.alert-message{padding:10px;border:3px solid $green;margin:1em;}
