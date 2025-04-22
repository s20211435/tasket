require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let!(:category) { create(:category) }
  let!(:product) { create(:product, category: category) }

  describe "GET #index" do
    it "assigns all products and renders the index template" do
      get :index
      expect(assigns(:products)).to include(product)
      expect(assigns(:product)).to be_a_new(Product)
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "assigns the requested product" do
      get :show, params: { id: product.id }
      expect(assigns(:product)).to eq(product)
      expect(response).to render_template(:show)
    end
  end

  describe "GET #new" do
    it "assigns a new product and responds with turbo_stream" do
      get :new, format: :turbo_stream
      expect(assigns(:product)).to be_a_new(Product)
      expect(assigns(:categories)).to eq([category])
      expect(response.media_type).to eq Mime[:turbo_stream]
    end
  end

  describe "POST #create" do
  context "with valid attributes" do
    it "creates a new product and responds with turbo_stream" do
      expect {
        post :create, params: { product: { name: "New Product", price: 500, category_id: category.id } }, format: :turbo_stream
      }.to change(Product, :count).by(1)
      expect(assigns(:product)).to be_persisted
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("product_form")
    end
  end

  context "with invalid attributes" do
    it "does not create a new product and re-renders the form" do
      expect {
        post :create, params: { product: { name: "", price: 500, category_id: category.id } }, format: :turbo_stream
      }.not_to change(Product, :count)
      expect(assigns(:product)).not_to be_persisted
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("product_form")
    end
  end
end

  describe "GET #edit" do
    it "assigns the requested product and responds with turbo_stream" do
      get :edit, params: { id: product.id }, format: :turbo_stream
      expect(assigns(:product)).to eq(product)
      expect(assigns(:categories)).to eq([category])
      expect(response.media_type).to eq Mime[:turbo_stream]
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the product and responds with turbo_stream" do
        patch :update, params: { id: product.id, product: { name: "Updated Product" } }, format: :turbo_stream
        product.reload
        expect(product.name).to eq("Updated Product")
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end

    context "with invalid attributes" do
      it "does not update the product and re-renders the form" do
        patch :update, params: { id: product.id, product: { name: "" } }, format: :turbo_stream
        product.reload
        expect(product.name).not_to eq("")
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end
  end

  describe "DELETE #destroy" do
    it "marks the product as discarded and responds with turbo_stream" do
      expect {
        delete :destroy, params: { id: product.id }, format: :turbo_stream
      }.to change { Product.kept.count }.by(-1) # 論理削除を考慮
      expect(product.reload.discarded?).to be true
      expect(response.media_type).to eq Mime[:turbo_stream]
    end
  end
end
