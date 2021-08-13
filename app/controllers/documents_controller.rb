class DocumentsController < ApplicationController

  def show
    if current_user.is_admin?
      @document = Document.find(params[:id])

      send_data(@document.file_content,
                type: @document.content_type,
                filename: @document.original_file_name)
    else
      render plain: "Ошибка доступа"
    end
  end

  def destroy
    if current_user.is_admin?
      @document = Document.find(params[:id])
      @document.archive!
      # for budgets
      redirect_to "/budgets/#{@document.owner.id}/#docs"
    else
      render plain: "Ошибка доступа"
    end
  end


end
