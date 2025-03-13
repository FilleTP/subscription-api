Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :subscriptions, only: [:create, :show], param: :external_id do
        member do
          post 'apply_coupon'
          delete 'remove_coupon'
        end
      end

      resources :coupons, only: [:create, :show, :index]
    end
  end
end
