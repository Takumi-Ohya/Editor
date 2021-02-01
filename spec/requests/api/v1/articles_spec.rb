require 'rails_helper'

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /api/v1/articles" do

      subject{ get api_v1_articles_path}
      let!(:article1) {create(:article , updated_at: 1.days.ago)}
      let!(:article2) {create(:article , updated_at: 2.days.ago)}
      let!(:article3) {create(:article)}

      it "記事の一覧が取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res.length).to eq 3
        expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
        expect(res[0]["user"].keys).to eq ["id", "name"]
        expect(res[0]["id"]).to eq article3.id
        expect(res[1]["id"]).to eq article1.id
        expect(res[2]["id"]).to eq article2.id
        expect(response).to have_http_status(200)
    end
  end

  describe "GET /api/v1/article/:id" do
    subject { get api_v1_article_path(article_id) }
    context "指定したidの記事が存在する時" do
      let(:article) {create(:article)}
      let(:article_id) {article.id}

      it "そのidの記事が取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["user"]["id"]).to eq article.user_id
        expect(res["user"].keys).to eq ["id", "name"]
        expect(response).to have_http_status(200)
      end
    end

    context "指定したidの記事が存在しない時" do
      let(:article_id) {100000}
      fit "記事が見tuからない" do
        expect{subject}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
