module Alpha
  class Root < Grape::API
    version 'v1', using: :path
    format :json

    # Mountings
    mount Alpha::Applications

    #desc "Returns pong."
    #get "ping" do
      #{ ping: "pong" }
    #end
  end
end