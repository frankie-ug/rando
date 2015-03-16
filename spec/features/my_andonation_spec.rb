require 'rails_helper'

feature 'Campaigns' do
  background do
    allow_any_instance_of(SubledgerClient).to receive(:create_account).and_return("account_id")
    OmniAuth.config.test_mode = true
    set_valid_omniauth
  end

  scenario 'authenticated user sees his campaigns' do
    res = double("response", body: sample_transaction_api_response)
    expect(SubledgerClient).to receive(:get) { res }
    visit '/'

    click_on 'Login'
    create(:campaign, title: 'Black Long Coffee is Bitter', user: User.first)
    create_list(:campaign, 4, user: User.first)
    click_on 'My Andonation'
    expect(page).to have_content('My Campaigns')
    expect(page).to have_content('Food for the Poor')
    expect(page).to have_content((Date.tomorrow + 1.day).strftime('%Y-%m-%d'))
    expect(page).to have_content('6000')
    expect(page).to have_content('View all 5 Campaigns')

    click_on 'View all 5 Campaigns'
    expect(page).to have_content('Black Long Coffee is Bitter')
  end

  scenario 'authenticated user sees message if no current campaigns' do
    visit '/'

    click_on 'Login'
    save_and_open_page
    click_on 'My Andonation'
    expect(page).to_not have_link('View all 0 campaigns')
    expect(page).to have_content('You have no active campaigns currently running')

    visit '/my_andonation/campaigns'
    expect(page).to have_content('You have no active campaigns currently running')
    click_on 'Logout'
  end

  after do
    OmniAuth.config.test_mode = false
  end
end

feature 'Roles' do
  let(:transaction) { Transaction.new(ActiveSupport::JSON.decode(expected_transactions)) }

  background do
    allow_any_instance_of(SubledgerClient).to receive(:user_transactions).and_return([transaction])
    OmniAuth.config.test_mode = true
    set_valid_omniauth
    create(:user, first_name: 'Chiemeka', last_name: 'Alim')
    create(:user, first_name: 'Fiyin', last_name: 'Foluwa')
    create(:user, first_name: 'Frankie', last_name: 'Nnaemeka')

    visit '/'
    click_on 'Login'
    click_on 'My Andonation'
  end

  scenario 'a user with admin role should see Users link' do
    expect(page).not_to have_link('Users')

    user = User.where(email: 'christopher@andela.co').first
    user.add_role :admin
    click_on 'My Andonation'
    click_on 'Users'
    expect(page).to have_content('Fiyin')
    expect(page).to have_content('Chiemeka')
    expect(page).to have_content('Frankie')
    expect(page).to have_content('Alim')
    expect(page).to have_content('Foluwa')
    expect(page).to have_content('Nnaemeka')
    expect(page).to have_content('Admin, Member')
  end
end