require 'sinatra'

set :public_folder, File.dirname(__FILE__)

get '/' do
  erb :index
end

__END__

@@layout
  <!DOCTYPE HTML>
  <html lang="en">
    <head>
      <meta charset="UTF-8">
      <link type="text/css" rel="stylesheet" href="css/global.css">
      <link type="text/css" rel="stylesheet" href="css/metro-bootstrap.css">
      <link type="text/css" rel="stylesheet" href="font-awesome-4.0.3/css/font-awesome.min.css">
      <title>Analizador Léxico JS</title>
    </head>
    <body>
      <%= yield %>
    </body>
  </html>
