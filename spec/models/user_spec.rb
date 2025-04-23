require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(name: 'Test User', email: 'test@example.com', password: 'password')
      expect(user).to be_valid
    end

    it 'is invalid without a name' do
      user = User.new(email: 'test@example.com', password: 'password')
      expect(user).not_to be_valid
    end

    it 'is invalid without an email' do
      user = User.new(name: 'Test User', password: 'password')
      expect(user).not_to be_valid
    end

    it 'is invalid without a password' do
      user = User.new(name: 'Test User', email: 'test@example.com')
      expect(user).not_to be_valid
    end
  end
end
