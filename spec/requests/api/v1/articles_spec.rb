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
      it "記事が見つからない" do
        expect{subject}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST /articles" do
    subject {post(api_v1_articles_path, params: params)}

    let(:params) {{article: attributes_for(:article)}}
    let(:current_user) {create(:user)}
    it "記事のレコードが作成できる" do
      expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
      res = JSON.parse(response.body)
      expect(res["title"]).to eq params[:article][:title]
      expect(res["body"]).to eq params[:article][:body]
      expect(response).to have_http_status(200)
    end
  end

  describe "PATCH /api/v1/articles/:id" do
    subject {patch(api_v1_article_path(article.id), params: params)}

    let(:params) {{article: attributes_for(:article)}}
    let(:current_user) {create(:user)}
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    context "自分が所持している記事のレコードを更新しようとするとき" do
      let(:article) {create(:article, user: current_user)}

      it "記事が更新できる" do
        expect {subject}.to change {article.reload.title}.from(article.title).to(params[:article][:title]) &
                            change {article.reload.body}.from(article.body).to(params[:article][:body])
        expect(response).to have_http_status(200)
      end
    end

    context "自分が所持していない記事のレコードを更新しようとするとき" do
      let(:other_user) {create(:user)}
      let!(:article) {create(:article, user: other_user)}

      it "更新できない" do
        expect {subject}.to raise_error(ActiveRecord::RecordNotFound)
                            change {Article.count}.by(0)
      end
    end
  end
end
