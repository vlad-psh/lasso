paths pictures: '/pictures',
      pictures_upload: '/pictures/upload',
      picture: '/picture/:type/:sid'

get :pictures do
  protect!
  slim :pictures
end

get :picture do
  picture = Picture.find_by(sid: params[:sid])

  response.set_header('X-Accel-Redirect', File.join("/x-picture", params[:type], picture.sid))
#  response.set_header('Content-Type', doc.mime)
  response.set_header('Content-Type', 'image/jpeg') # Should work even with PNG and other images... I believe
  response.set_header('Content-Disposition', "inline; filename=\"#{picture.filename}\"")

  return
end

post :pictures_upload do
  protect!
  unless params[:file] &&
         (tmpfile = params[:file][:tempfile]) &&
         (name = params[:file][:filename])
    @error = "No file selected"
    return slim :pictures
  end

  picture = Picture.new(filename: name, user: current_user)
  picture.create_sid

  outfile = File.open(picture.filepath(:orig), 'wb')
  while blk = tmpfile.read(65536)
    outfile.write(blk)
  end
  outfile.close
  picture.save

  img = MiniMagick::Image.open(picture.filepath(:orig))
  img.resize("200x200>")
  img.write(picture.filepath(:thumb))

  flash[:notice] = "Image uploaded"
  redirect path_to(:pictures)
end
