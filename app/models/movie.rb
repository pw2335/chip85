class Movie < ApplicationRecord
  TMDB_BEARER_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2YjI2YjE1NTE0NzA3NDZmZjQzNjc5ZGYwYjJmZTFlZSIsIm5iZiI6MTc2MDIzMTQxMC4xOSwic3ViIjoiNjhlYWZmZjIyYzBhMzJmMDYwNjQ1YTZhIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.YN53qW2p8EKijjzjKHfQN9yB86rpq2wvxu2hupQ0TGg'
  TMDB_BASE_URL = 'https://api.themoviedb.org/3/search/movie'
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  # def self.find_in_tmdb(search_terms)
  #   []
  # end 

  def self.find_in_tmdb(params)
    # 1. 提取搜索关键词（必填，对应 TMDb 的 query 参数）
    search_query = params[:search_terms] || ''  # 注意：TMDb 用 query 表示搜索关键词，不是 title
    return [] if search_query.empty?  # 无关键词时返回空

    # 2. 处理可选参数
    release_year = params[:release_year].presence  # 年份（可选）
    language = params[:language].presence || 'en'  # 语言（默认 en）

    # 3. 构建查询参数（TMDb 搜索电影的核心参数）
    query_params = {
      query: search_query,  # 必选：搜索关键词
      language: language    # 可选：语言（如 'en' 英文，'zh-CN' 中文）
    }
    query_params[:year] = release_year if release_year  # 可选：年份过滤

    # 4. 发送请求（使用 Bearer Token 认证，而非 api_key 参数）
    response = Faraday.get(TMDB_BASE_URL) do |req|
      req.params = query_params
      # 添加认证头部（关键修改）
      req.headers['Authorization'] = "Bearer #{TMDB_BEARER_TOKEN}"
      req.headers['accept'] = 'application/json'  # 明确要求 JSON 响应
    end

    # 5. 处理响应
    return [] unless response.status == 200  # 非成功状态返回空

    json_response = JSON.parse(response.body)
    results = json_response['results'] || []  # 提取结果数组

    # 6. 转换为需要的格式（只保留必要字段）
    results.map do |movie_data|
      {
        title: movie_data['title'],
        release_date: movie_data['release_date'],
        language: movie_data['original_language'],
        rating: 'R'  # TMDb 不直接返回 MPAA 评级，可留空或默认值
      }
    end
  rescue Faraday::Error => e
    Rails.logger.error("TMDb API 请求失败：#{e.message}")
    []  # 异常时返回空数组
  end

end

