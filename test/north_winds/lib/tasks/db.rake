namespace :db do
    task fakeit: :environment do
        ['admin@northwinds.com',
        'employee@northwinds.com',
        'customer@northwinds.com'].each_with_index do |email, index|
            u = User.create!({
              email: email,
              password: 'developer',
              role: email.split('@').first
            })
        end

        
    end
end