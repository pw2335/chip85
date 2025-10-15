class MoviesController < ApplicationController
  before_action :force_index_redirect, only: [:index]

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @movies = Movie.with_ratings(ratings_list, sort_by)
    @ratings_to_show_hash = ratings_hash
    @sort_by = sort_by
    # remember the correct settings for next time
    session['ratings'] = ratings_list
    session['sort_by'] = @sort_by
  end


  def search_tmdb
    # 仅当用户提交了空搜索时，才重定向提示
    if request.post? && params[:search_terms].blank?
      flash[:danger] = "Please fill in all required fields!"
      redirect_to search_tmdb_path and return
    end
  
    # 调用模型方法获取结果（空搜索时返回空数组）
    # @movies = Movie.find_in_tmdb(params[:search_terms] || "")
    @movies = Movie.find_in_tmdb(params || "")
  
    # 处理无结果场景
    if @movies.blank? && !params[:search_terms].blank?
      flash[:warning] = "No movies found with given parameters!"
    end
  
    # 渲染搜索结果视图
  end

  def add_movie
    movie_params = params.permit(:title, :release_date, :rating, :language)
    @movie = Movie.new(movie_params)
    puts "movie_params: #{movie_params.inspect}"  # 检查参数是否正确
    puts "@movie.errors.full_messages: #{@movie.errors.full_messages.inspect}"  # 检查验证错误
    puts "Saved successfully? #{@movie.save}"
    if @movie.save
      flash[:success] = "#{@movie.title} was successfully added to RottenPotatoes."
    else
      flash[:danger] = "Failed to add movie: #{@movie.errors.full_messages.join(', ')}"
    end

    redirect_to search_tmdb_path
  end
  


  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private

  def force_index_redirect
    return unless !params.key?(:ratings) || !params.key?(:sort_by)

    flash.keep
    url = movies_path(sort_by: sort_by, ratings: ratings_hash)
    redirect_to url
  end

  def ratings_list
    params[:ratings]&.keys || session[:ratings] || Movie.all_ratings
  end

  def ratings_hash
    ratings_list.to_h { |item| [item, "1"] }
  end

  def sort_by
    params[:sort_by] || session[:sort_by] || 'id'
  end
end
