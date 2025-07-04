class CategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @categories = current_user.categories
    @category = Category.new
  end

  def create
    @category = current_user.categories.build(category_params)

    if @category.save
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.append("categories", partial: "categories/category", locals: { category: @category }),
            turbo_stream.replace("category_form", partial: "categories/form", locals: { category: Category.new }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { flash_type: "success", message: "カテゴリが作成されました。" })
          ]
        }
        format.html { redirect_to categories_path, notice: 'カテゴリが作成されました。' }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("category_form", partial: "categories/form", locals: { category: @category }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { flash_type: "danger", message: "カテゴリの作成に失敗しました。" })
          ]
        }
        format.html { render :index }
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "category_form",
          partial: "categories/form",
          locals: { category: @category }
        )
      }
      format.html
    end
  end

  def update
    if @category.update(category_params)
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("category_#{@category.id}", partial: "categories/category", locals: { category: @category }),
            turbo_stream.replace("category_form", partial: "categories/form", locals: { category: Category.new }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { flash_type: "success", message: "カテゴリが更新されました。" })
          ]
        }
        format.html { redirect_to categories_path, notice: 'カテゴリが更新されました。' }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("category_form", partial: "categories/form", locals: { category: @category }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { flash_type: "danger", message: "カテゴリの更新に失敗しました。" })
          ]
        }
        format.html { render :edit }
      end
    end
  end

  def destroy
    @category = Category.find(params[:id])

    if @category.products.exists?
      flash[:alert] = "このカテゴリは使用されているため削除できません。"
      redirect_to categories_path
    else
      @category.destroy
      flash[:notice] = "カテゴリを削除しました。"
      redirect_to categories_path
    end
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end

class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[new edit create update]

  def new
    @product = Product.new
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("product_form", partial: "products/form", locals: { product: @product }) }
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("product_form", partial: "products/form", locals: { product: @product }) }
      format.html
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_categories
    @categories = Category.all
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock_quantity, :category_id)
  end
end
