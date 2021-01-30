# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  image                  :string
#  name                   :string
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string           default(""), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe "正常系テスト" do
    context "名前、メールアドレス、パスワードがすべて入力されている時" do

      let(:user) {build(:user)}

      it "ユーザー登録ができる"do

        expect(user).to be_valid
      end
    end
  end

  describe "異常系テスト" do
    context "名前が入力されていない時" do

      let(:user) {build(:user, name: nil)}

      it "ユーザーが登録できない"do

        expect(user).to be_invalid
        expect(user.errors.details[:name][0][:error]).to eq :blank
      end
    end

    context "emailが入力されていない時" do

      let(:user) {build(:user, email: nil)}

      it "ユーザーが登録できない" do

        expect(user).to be_invalid
        expect(user.errors.details[:email][0][:error]).to eq :blank
      end
    end

    context "パスワードが入力されていない時" do

      let(:user) {build(:user, password: nil)}

      it "ユーザーが登録できない" do

        expect(user).to be_invalid
        expect(user.errors.details[:password][0][:error]).to eq :blank
      end
    end

    context "同じ名前のユーザーが存在する時" do

      let(:newuser) {build(:user, name: "foo")}

      it "ユーザーが登録できない" do
        olduser = create(:user, name: "foo")
        expect(newuser).to be_invalid
        expect(newuser.errors.details[:name][0][:error]).to eq :taken
      end
    end

    context "同じメールアドレスが使われている時" do

      let(:newuser) {build(:user, email: "foo@example.com")}

      it "ユーザーが登録できない" do
        olduser = create(:user, email: "foo@example.com")
        expect(newuser).to be_invalid
        expect(newuser.errors.details[:email][0][:error]).to eq :taken
      end
    end
  end
end
