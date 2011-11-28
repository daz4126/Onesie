########### Onesie ###########
# The All In One Sinatra Bootstrap!

require 'bundler'
Bundler.require

########### settings ###########
set :name, ENV['name'] || 'Onesie'
set :author, ENV['author'] || 'DAZ'
set :analytics, ENV['ANALYTICS'] || 'UA-XXXXXXXX-X'
set :token, ENV['TOKEN'] || 'makethisrandomandhardtoremember'
set :password, ENV['PASSWORD'] || 'secret'
set :js_libraries, %w[ http://cdn.rightjs.org/right.js ]
set :public_folder, Proc.new { root }
set :fonts, :"Ubuntu|Coming+Soon";
set :flash, %w[notice error warning alert info]
enable :sessions
use Rack::Flash

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
get('/logout'){ response.set_cookie(settings.author, false) ;   flash[:notice]='You are now logged out'; redirect to('/') }

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
  @title = 'Onesie: The All In One Sinatra Bootstrap!'
  slim :index
end

###########  Tests ###########
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

enable :inline_templates
__END__
########### Views ###########
@@index
p Onesie is a tiny framework for Sinatra that has everything all in one file - models, views, routes and tests.

@@layout
doctype html
html
  head
    meta charset="utf-8"
    title= @title || settings.name
    link rel="shortcut icon" href="/fav.ico"
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
        a title="home" href="/" = settings.name
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
    a.admin href='/admin' login
      
@@login
form action="/login" method="post"
  input type="password" name="password"
  input type="submit" value="Login"

@@404
h1 404! 
p That page is missing

@@script
alert 'Welcome to Onesie. This is just to make sure that Coffeescript is working.'

@@styles
// fonts
$normalfont: Ubuntu,Helvetica,Arial,sans-serif;
$headingfont:'Coming Soon',sans-serif;
$basefontsize: 13px;

// colours
$blue: #0055d4;
$green: #9f5;
$background: #fff;
$color: #666;
$headingcolor: $blue;

// reset
html,body,div,span,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote, pre,abbr,address,cite,code,del,dfn,em,img,ins,kbd,q,samp,small,strong,sub,sup,var,b,i,dl,dt, dd,ol,ul,li,fieldset,form,label,legend,table,caption,tbody,tfoot,thead,tr,th,td,article, aside, canvas, details,figcaption,figure,footer,header,hgroup,menu,nav,section, summary,time,mark,audio,video{margin:0;padding:0;border:0;outline:0;font-size:100%;vertical-align:baseline;background:transparent;line-height:1;}
// html5 elements
article,aside,canvas,details,figcaption,figure,
footer,header,hgroup,menu,nav,section,summary{display:block;}
body{font-family:$normalfont;background-color:$background;color:$color;}
// standard stuff
body{font-size:$basefontsize;}
h1,h2,h3,h4,h5,h6{margin:0.2em 0;color:$headingcolor;font-family:$headingfont;}
h1{font-size:2.4em;}h2{font-size:2em;}h3{font-size:1.6em;}
h4{font-size:1.4em;}h5{font-size:1.2em;}h6{font-size:1em;}
p{font-size:1em;line-height:1.6;margin:0 0 1em}
small{font-size:90%;}
li{font-size:1em;line-height:1.6;}


// custom styles
.logo{font-size:4em;padding-left:64px;background: url(/logo.png) 0 0 no-repeat;line-height:64px;
a{color:$green;text-decoration:none;}
}
.alert-message{padding:10px;border:3px solid $green;margin:1em;}
