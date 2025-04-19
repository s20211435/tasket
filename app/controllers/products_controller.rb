class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @q = Product.ransack(params[:q])
    @products = @q.result.page(params[:page]).per(10)  # 1ページに10件表示
    @product = Product.new # フォーム用に空の@productを追加

    respond_to do |format|
      format.html
      format.json {
        # 最後に更新された商品の更新日時を返す
        latest_update = @products.maximum(:updated_at)&.iso8601 || Time.current.iso8601
        render json: { last_update: latest_update, count: @products.count }
      }
    end
  end

  def show
  end

  def new
    @product = Product.new
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("product_form", partial: "products/form", locals: { product: @product }) }
      format.html
    end
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.append("products", partial: "products/product", locals: { product: @product }),
            turbo_stream.replace("product_form", partial: "products/form_hidden"),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { flash_type: "success", message: "商品が作成されました。" })
          ]
        }
        format.html { redirect_to @product, notice: '商品が作成されました。' }
        format.json { render json: { success: true, product: @product, message: '商品が作成されました。' } }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("product_form", partial: "products/form", locals: { product: @product }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { flash_type: "danger", message: "登録できませんでした。入力内容を確認してください。" })
          ]
        }
        format.html { render :new }
        format.json { render json: { success: false, errors: @product.errors }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @product = Product.find_by(id: params[:id])

    if @product.nil?
      flash[:error] = "商品が見つかりませんでした"
      redirect_to products_path
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("product_form", partial: "products/form", locals: { product: @product })
        }
        format.html
      end
    end
  end

  def update
    if @product.update(product_params)
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("product_#{@product.id}", partial: "products/product", locals: { product: @product }),
            turbo_stream.replace("product_form", partial: "products/form_hidden"),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { flash_type: "success", message: "商品が更新されました。" })
          ]
        }
        format.html { redirect_to @product, notice: '商品が更新されました。' }
        format.json { render json: { success: true, product: @product, message: '商品が更新されました。' } }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("product_form", partial: "products/form", locals: { product: @product }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { flash_type: "danger", message: "更新できませんでした。入力内容を確認してください。" })
          ]
        }
        format.html { render :edit }
        format.json { render json: { success: false, errors: @product.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("product_#{@product.id}"),
          turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { flash_type: "success", message: "商品が削除されました。" })
        ]
      }
      format.html { redirect_to products_url, notice: '商品が削除されました。' }
      format.json { render json: { success: true, message: '商品が削除されました。' } }
    end
  end

  def calculate
    @products = Product.all
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock_quantity, :category_id)
  end
end
