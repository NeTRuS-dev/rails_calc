Rails.application.routes.draw do
  root 'calculations#index'

  get 'calculations/index'
  post 'calculations/calc'
  post 'calculations/memorize'
  post 'calculations/get-memorized', to: 'calculations#get_memorized'
  post 'calculations/clear-memory', to: 'calculations#clear_memory'
end
