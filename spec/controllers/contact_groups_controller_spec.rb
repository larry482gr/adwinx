require 'rails_helper'
require 'support/controller_macros'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe ContactGroupsController, type: :controller do
  create_english_lang
  login_user

  # This should return the minimal set of attributes required to create a valid
  # ContactGroup. As you add validations to ContactGroup, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    # skip("Add a hash of attributes valid for your model")
    { uid: controller.current_user.id, label: 'New Group' }
  }

  let(:invalid_attributes) {
    # skip("Add a hash of attributes invalid for your model")
    { uid: controller.current_user.id, label: '' }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ContactGroupsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all contact_groups as @contact_groups" do
      contact_group   = ContactGroup.create! valid_attributes
      contact_groups  = ContactGroup.where(uid: controller.current_user.id).asc(:label)
                            .page(1).per(50)
      get :index, {} # , valid_session # Commented out since we are using devise helpers... for now!!!
      expect(assigns(:contact_groups)).to eq(contact_groups)
    end
  end

  describe "GET #show" do
    it "assigns the requested contact_group as @contact_group" do
      contact_group = ContactGroup.create! valid_attributes
      get :show, {:id => contact_group.to_param} # , valid_session
      expect(assigns(:contact_group)).to eq(contact_group)
    end
  end

  describe "GET #new" do
    it "assigns a new contact_group as @contact_group" do
      get :new, {} # , valid_session
      expect(assigns(:contact_group)).to be_a_new(ContactGroup)
    end
  end

  describe "GET #edit" do
    it "assigns the requested contact_group as @contact_group" do
      contact_group = ContactGroup.create! valid_attributes
      get :edit, {:id => contact_group.to_param} # , valid_session
      expect(assigns(:contact_group)).to eq(contact_group)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new ContactGroup" do
        expect {
          post :create, {:contact_group => valid_attributes} # , valid_session
        }.to change(ContactGroup, :count).by(1)
      end

      it "assigns a newly created contact_group as @contact_group" do
        post :create, {:contact_group => valid_attributes} # , valid_session
        expect(assigns(:contact_group)).to be_a(ContactGroup)
        expect(assigns(:contact_group)).to be_persisted
      end

      it "redirects to the created contact_group" do
        post :create, {:contact_group => valid_attributes} # , valid_session
        expect(response).to redirect_to(ContactGroup.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved contact_group as @contact_group" do
        post :create, {:contact_group => invalid_attributes} # , valid_session
        expect(assigns(:contact_group)).to be_a_new(ContactGroup)
      end

      it "re-renders the 'new' template" do
        post :create, {:contact_group => invalid_attributes} # , valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested contact_group" do
        contact_group = ContactGroup.create! valid_attributes
        put :update, {:id => contact_group.to_param, :contact_group => new_attributes} # , valid_session
        contact_group.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested contact_group as @contact_group" do
        contact_group = ContactGroup.create! valid_attributes
        put :update, {:id => contact_group.to_param, :contact_group => valid_attributes} # , valid_session
        expect(assigns(:contact_group)).to eq(contact_group)
      end

      it "redirects to the contact_group" do
        contact_group = ContactGroup.create! valid_attributes
        put :update, {:id => contact_group.to_param, :contact_group => valid_attributes} # , valid_session
        expect(response).to redirect_to(contact_group)
      end
    end

    context "with invalid params" do
      it "assigns the contact_group as @contact_group" do
        contact_group = ContactGroup.create! valid_attributes
        put :update, {:id => contact_group.to_param, :contact_group => invalid_attributes} # , valid_session
        expect(assigns(:contact_group)).to eq(contact_group)
      end

      it "re-renders the 'edit' template" do
        contact_group = ContactGroup.create! valid_attributes
        put :update, {:id => contact_group.to_param, :contact_group => invalid_attributes} # , valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested contact_group" do
      contact_group = ContactGroup.create! valid_attributes
      expect {
        delete :destroy, {:id => contact_group.to_param, :contact_group => { :contacts_fate => 1 } } # , valid_session
      }.to change(ContactGroup, :count).by(-1)
    end

    it "redirects to the contact_groups list" do
      contact_group = ContactGroup.create! valid_attributes
      delete :destroy, {:id => contact_group.to_param, :contact_group => { :contacts_fate => 1 } } # , valid_session
      expect(response).to redirect_to(contact_groups_url)
    end
  end

end
