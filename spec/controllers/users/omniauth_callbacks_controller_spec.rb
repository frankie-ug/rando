require 'rails_helper'

describe Users::OmniauthCallbacksController, type: :controller do
  describe '#google_oauth2' do
    let(:user) { User.create(email: 'christopher@andela.co') }

    before do
      OmniAuth.config.test_mode = true
      request.env['devise.mapping'] = Devise.mappings[:user]

      allow(User).to receive(:find_for_google_oauth2) { user }
    end

    it 'assigns @user' do
      get :google_oauth2
      expect(assigns(:user)).to eq(user)
    end

    context 'valid credentials' do
      before do
        set_valid_omniauth
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]

        get :google_oauth2
      end

      it 'signs in user' do
        expect(controller).to be_user_signed_in
      end

      it 'displays success message' do
        expect(flash[:notice]).to eq("Successfully authenticated from Google account.")
      end
    end

    context 'invalid credentials' do
      let(:user) { User.new }

      before do
        set_invalid_omniauth
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google_auth2]

        get :google_oauth2
      end

      it 'displays error message' do
        expected_message = "Could not authenticate you from Google because \"account cannot be saved\"."
        expect(flash[:notice]).to eq(expected_message)
      end
    end

    it 'redirects to root path' do
      get :google_oauth2
      expect(response).to redirect_to root_path
    end
  end
end