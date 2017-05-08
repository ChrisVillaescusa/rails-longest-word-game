Rails.application.routes.draw do
  get 'control/game'

  get 'control/score'

   get 'game', to: 'control#game'
   get '/', to: 'control#game'
   get 'score', to: 'control#score'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
