require 'rails_helper'

if RUBY_VERSION>='2.6.0'
  if Rails.version < '5'
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        # hack to avoid MonitorMixin double-initialize error:
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  else
    puts "Monkeypatch for ActionController::TestResponse no longer needed"
  end
end

describe MoviesController do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end
    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with('hardware').
       and_return(@fake_results)
     get :search_tmdb, {:search_terms => 'hardware'}
   end
   describe 'after valid search' do
     before :each do
       allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
       get :search_tmdb, {:search_terms => 'hardware'}
     end
     it 'selects the Search Results template for rendering' do
       expect(response).to render_template('search_tmdb')
     end
     it 'makes the TMDb search results available to that template' do
       expect(assigns(:movies)).to eq(@fake_results)
     end
   end
 end

 describe 'adding movie to database' do
  self.use_transactional_fixtures = false
  let(:movie_params) { { title: 'Manhunter', release_date: '1986-08-01 ', rating: 'R', language: 'en' } }

  it 'saves movie to database and redirects to search page' do
    # 发送POST请求到add_movie动作
    post :add_movie, movie_params

    puts "Database movies: #{Movie.all.inspect}"

    # 验证：1. 数据库中存在该电影；2. 重定向到搜索页；3. 显示成功提示
    expect(Movie.exists?(title: 'Manhunter', release_date: DateTime.parse('1986-08-01 00:00:00'))).to be true
    expect(response).to redirect_to(search_tmdb_path)
    expect(flash[:success]).to eq("Manhunter was successfully added to RottenPotatoes.")
  end

  # 测试：重复添加时不报错（可选，根据业务需求）
  it 'does not raise error when adding duplicate movie' do
    # 先创建一条记录
    Movie.create(movie_params)
    # 再次添加
    expect { post :add_movie, movie_params }.not_to raise_error
  end
end
end

