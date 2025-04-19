require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'バリデーションのテスト' do
    it '名前があれば有効であること' do
      category = Category.new(name: 'テストカテゴリ')
      expect(category).to be_valid
    end

    it '名前がなければ無効であること' do
      category = Category.new(name: nil)
      expect(category).to_not be_valid
      expect(category.errors[:name]).to include("を入力してください")
    end
  end
end
