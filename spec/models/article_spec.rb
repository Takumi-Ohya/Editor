# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  describe "正常系テスト" do
    context "タイトルと本文どちらも記入されている時" do
      let(:article) { build(:article) }

      it "記事が作成できる" do
        expect(article).to be_valid
      end
    end
  end

  describe "異常系テスト" do
    context "タイトルが記入されていない時" do
      let(:article) { build(:article, title: nil) }

      it "記事が作成できない" do
        expect(article).to be_invalid
        expect(article.errors.details[:title][0][:error]).to eq :blank
      end
    end

    context "本文が記入されていない時" do
      let(:article) { build(:article, body: nil) }

      it "記事が作成されない" do
        expect(article).to be_invalid
        expect(article.errors.details[:body][0][:error]).to eq :blank
      end
    end

    context "同一ユーザーで同じタイトルの記事が存在する時" do
      let(:user) { create(:user) }
      let(:oldarticle) { create(:article, title: sametitle, user: user) }
      let(:newarticle) { build(:article, title: sametitle, user: user) }
      let(:sametitle) { "foo" }

      it "記事が作成されない" do
        user
        oldarticle
        expect(newarticle).to be_invalid
        expect(newarticle.errors.details[:title][0][:error]).to eq :taken
      end
    end
  end
end
