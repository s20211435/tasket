class Category < ApplicationRecord
  belongs_to :user
  has_many :products

  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id name created_at updated_at]
  end

  def to_s
    name
  end

  def edit
    @category = Category.find(params[:id])

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "category_form",
          partial: "form",
          locals: { category: @category }
        )
      }
      format.html # 通常のHTML応答
    end
  end
end
