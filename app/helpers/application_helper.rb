module ApplicationHelper

#   def get_fin_year
#     @fin_years = Budget.pluck(:f_year)
#     @fin_years = Budget.pluck(:f_year).uniq! if @fin_years.length > 1
#   end

  def date(d)
    d.strftime("%d.%m.%Y") rescue ''
  end

  def time(d)
    d.strftime("%H:%M:%S") rescue ''
  end

  def norm_money(summ)
    if summ.to_f.abs < 1
      summ_formatter(summ, 'Рубль', 3)
    else
      summ_formatter(summ, 'Рубль', 0)
    end
  end

  def money(summ, current_user=nil)
    return summ.to_s.gsub('.', ',') if @export
    summ_formatter(summ, 'Рубль', 0, current_user)
  end

  # по умолчанию - без копеек
  def summ_formatter(summ, currency = 'Рубль', precision = 0, current_user=nil)
    currency = 'Рубль' if currency.nil?

    # ₽
    @currency = "" if currency == "Рубль"
    @currency = "$" if currency == "Доллар"
    @currency = "€" if currency == "Евро"

    fmt = "%u%n"
    dlm = ","

    if @current_user
      current_user = @current_user
    end

    summ = summ.to_f
    if current_user && ['USER_LOGIN'].include?(current_user.login) && summ.to_f.abs > 1_000_000
      summ /= 1_000_000
      @currency = 'млн'
	  fmt = "%n %u"
	  dlm = " "
    end

    number_to_currency(summ, unit: @currency, separator: ".", delimiter: dlm, format: fmt, precision: precision)
  end

  def paginate(collection)
    will_paginate(collection, previous_label: "Предыдущая", next_label: "Следующая", class: "flickr_pagination")
  end

  def get_breadcrumb
    unless session['last_busget_id'].nil?
      @last_open_budget = Budget.find(session['last_busget_id']) rescue Budget.root
      @breadcrumbs = @last_open_budget.ancestors
    end
  end

  def card(title, &block)
    content = capture(&block)
    render 'shared/card', card_title: title, card_content: content, bg_color: 'bg-info'
  end

  def box_begin(title)
    ret = ''
    ret += '<div class="card border-info mb-3">'
    ret += '<div class="card-header text-white font-weight-bold text-uppercase">'
    ret += title
    ret += '</div>'
    ret += '<div class="card-body p-3 bg-light">'
    ret
  end

  def box_end
    '</div></div>'
  end

  def card_primary(title, &block)
    content = capture(&block)
    render 'shared/card', card_title: title, card_content: content, bg_color: 'bg-primary'
  end

  def info_row_summ(title, summ)
    if summ
      render 'shared/info_row_summ', title: title, summ: summ
    end
  end

  def info_row_title(title)
    render 'shared/info_row_title', title: title
  end

  def icon(svg_class, icon, options={})
    icon = icon.to_s.gsub('_','-')
    svg_class = svg_class.to_s.gsub('_','-')

    width = options.fetch(:width, nil)
    fill  = options.fetch(:fill, nil)

    content_tag :svg, nil, class: svg_class, viewBox: '0 0 8 8', width: width, fill: fill do
      concat content_tag(:use, nil, class: 'icon-' + icon, 'xlink:href' => asset_path('open-iconic.min.svg#' + icon))
    end

  end

end
