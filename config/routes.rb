Rails.application.routes.draw do


    get 'conference/show/:id', to: "conference#show", as: :conference
    get 'conference/show_people/:id', to: "conference#show_people", as: :show_people
    devise_for :users
    resources :papers
    #resources :users


    post 'papers/:id/grade',    to: "papers#rate", as: :paper_rate
    get 'papers/:id/grade',     to: "papers#grade", as: :paper_grade
    post 'papers/:id/skip',     to: "papers#skip", as: :paper_skip
    get 'papers/:id/accept',    to: "papers#accept", as: :paper_accept
    get 'users/login',          to: 'application#login_with_frab',  as: :login_user
    get 'papers/remove_rating/:id', to: "papers#remove_rating", as: :paper_remove_rating
    get 'send_email/:email',    to: "conference#send_email_to", as: :send_email_to
    get 'user/new-account/:id',     to: "conference#create_account", as: :create_account
    patch 'update-account',          to: "conference#update_user",     as: :update_user
    post 'send_email',          to: "conference#send_email", as: :send_email
    post 'mark_paid/:id',           to: "conference#mark_paid", as: :mark_paid
    root 'papers#index'

    get 'payment',            to: "payment#index"
    patch 'update_payment',    to: "payment#update", as: :update

end
