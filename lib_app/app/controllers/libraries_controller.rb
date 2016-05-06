class LibrariesController < ApplicationController

  def index
    @libraries = Library.all
    render :index
  end

  def new
    @library = Library.new
    render :new
  end

  def create
    library_params = params.require(:library).permit(:name, :floor_count, :floor_area)
    redirect_to libraries_path
  end

  def edit
  end

  def update
  end

  def show
  end

  def delete
  end
  
end
