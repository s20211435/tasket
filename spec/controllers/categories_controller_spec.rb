require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  let!(:category) { create(:category) }

  describe "GET #index" do
    it "assigns all categories and a new category" do
      get :index
      expect(assigns(:categories)).to eq([category])
      expect(assigns(:category)).to be_a_new(Category)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new category and responds with turbo_stream" do
        expect {
          post :create, params: { category: { name: "New Category" } }, format: :turbo_stream
        }.to change(Category, :count).by(1)
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end

    context "with invalid attributes" do
      it "does not create a new category and re-renders the form" do
        expect {
          post :create, params: { category: { name: "" } }, format: :turbo_stream
        }.not_to change(Category, :count)
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested category and responds with turbo_stream" do
      get :edit, params: { id: category.id }, format: :turbo_stream
      expect(assigns(:category)).to eq(category)
      expect(response.media_type).to eq Mime[:turbo_stream]
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the category and responds with turbo_stream" do
        patch :update, params: { id: category.id, category: { name: "Updated Name" } }, format: :turbo_stream
        category.reload
        expect(category.name).to eq("Updated Name")
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end

    context "with invalid attributes" do
      it "does not update the category and re-renders the form" do
        patch :update, params: { id: category.id, category: { name: "" } }, format: :turbo_stream
        category.reload
        expect(category.name).not_to eq("")
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end
  end

  describe "DELETE #destroy" do
    it "deletes the category and responds with turbo_stream" do
      expect {
        delete :destroy, params: { id: category.id }, format: :turbo_stream
      }.to change(Category, :count).by(-1)
      expect(response.media_type).to eq Mime[:turbo_stream]
    end
  end
end
