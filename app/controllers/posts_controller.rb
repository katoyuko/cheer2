class PostsController < ApplicationController

  def top
    # お気に入りカテゴリ一覧
    @user = current_user
    @favorite_categories = @user.favorite_categories.page(params[:page]).reverse_order.per(4)

    post_category_count = PostCategory.joins(:posts).where(created_at: 1.weeks.ago..Time.now).group(:post_category_id).count
    post_category_ids = Hash[post_category_count.sort_by{ |_, v| -v }].keys
    @post_category_ranks = PostCategory.where(id: post_category_ids).sort_by{|o| post_category_ids.index(o.id)}[0..3]
  end

  def about
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)

    @post_category = PostCategory.find(params[:post_category_id])
    @post.post_category_id = @post_category.id
    @post.user_id = current_user.id

    if @post.save
      redirect_to posts_path, notice: "投稿しました！"
    else
      render :new
    end
  end

  def index
    @posts = Post.all.reverse_order
  end

  def show
    @post = Post.find(params[:id])
    @post_comment = PostComment.new
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])

    if @post.update_attributes(post_params)
      redirect_to posts_path, notice: "更新しました！"
    else
      render :edit
    end

  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: "削除しました！"
  end

  private
    def post_params
      params.require(:post).permit(:post_category_id, :image, :post_content, :user_id)
    end

end

