Rails.application.routes.draw do
  devise_for :users,
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'sessions',
               registrations: 'registrations'
             }

  scope :auth do
    get 'is_signed_in', to: 'auth#is_signed_in?'
    # get 'profile', to: 'profile#get'
  end

  mount ActionBlocks::Engine => "/action_blocks"

end
