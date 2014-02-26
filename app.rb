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
      <title>Título</title>
    </head>
    <body>
      <%= yield %>
    </body>
  </html>

@@index
  <p>Hola, mundo</p>
