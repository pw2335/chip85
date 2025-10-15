require 'rails_helper'
require 'webmock/rspec'  # 启用 WebMock（确保已添加到 Gemfile）

# 禁用真实网络请求，仅允许模拟请求
WebMock.disable_net_connect!(allow_localhost: true)

describe Movie do
  describe '.find_in_tmdb' do
    # 注意：这是 Bearer Token，不是 api_key
    let(:bearer_token) { 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2YjI2YjE1NTE0NzA3NDZmZjQzNjc5ZGYwYjJmZTFlZSIsIm5iZiI6MTc2MDIzMTQxMC4xOSwic3ViIjoiNjhlYWZmZjIyYzBhMzJmMDYwNjQ1YTZhIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.YN53qW2p8EKijjzjKHfQN9yB86rpq2wvxu2hupQ0TGg' }
    let(:valid_params) { { title: 'Manhunter', release_year: '1986', language: 'en' } }
    
    # 构造 TMDb API URL（不含 api_key，仅包含业务参数）
    let(:tmdb_api_url) do
      query_params = {
        query: valid_params[:title],          # 对应 TMDb 的 query 参数
        year: valid_params[:release_year],    # 年份过滤
        language: valid_params[:language]     # 语言过滤
      }.to_query  # 自动拼接为 "query=Manhunter&year=1986&language=en"
      
      "https://api.themoviedb.org/3/search/movie?#{query_params}"
    end

    # 测试1：正确构造请求（URL + 头部）并处理响应
    it 'sends GET request to TMDb API with correct URL and headers' do
      # 模拟 TMDb 成功响应（带结果）
      stub_request(:get, tmdb_api_url)
        .with(
          headers: {
            'Authorization' => "Bearer #{bearer_token}",  # 匹配 Bearer 认证头部
            'Accept' => 'application/json'                # 匹配 Accept 头部
          }
        )
        .to_return(
          status: 200,
          body: JSON.generate({
            "results": [
              { "title": "Manhunter", "release_date": "1986-08-01", "original_language": "en" },
              { "title": "Manhunter 2", "release_date": "1990-01-01", "original_language": "en" }
            ]
          }),
          headers: { 'Content-Type': 'application/json' }
        )

      # 调用模型方法
      result = Movie.find_in_tmdb(valid_params)

      # 验证请求是否被正确调用
      expect(WebMock).to have_requested(
        :get, 
        tmdb_api_url
      ).with(
        headers: {
          'Authorization' => "Bearer #{bearer_token}",
          'Accept' => 'application/json'
        }
      )

      # 验证返回结果格式
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:title]).to eq("Manhunter")
      expect(result.first[:release_date]).to eq("1986-08-01")
      expect(result.first[:language]).to eq("en")
    end

    # 测试2：无结果时返回空数组
    it 'returns empty array when TMDb returns no results' do
      stub_request(:get, tmdb_api_url)
        .with(
          headers: {
            'Authorization' => "Bearer #{bearer_token}",
            'Accept' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: JSON.generate({ "results": [] }),
          headers: { 'Content-Type': 'application/json' }
        )

      result = Movie.find_in_tmdb(valid_params)
      expect(result).to be_empty
    end

    # 测试3：API 错误时返回空数组
    it 'returns empty array when TMDb API returns error' do
      stub_request(:get, tmdb_api_url)
        .with(
          headers: {
            'Authorization' => "Bearer #{bearer_token}",
            'Accept' => 'application/json'
          }
        )
        .to_return(status: 500)  # 模拟服务器错误

      result = Movie.find_in_tmdb(valid_params)
      expect(result).to be_empty
    end
  end
end