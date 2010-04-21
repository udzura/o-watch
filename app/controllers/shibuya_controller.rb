class ShibuyaController < ApplicationController
  layout "common"
  protect_from_forgery :except => :day
  before_filter :mobile_switch_filter, :redirect_mobile_filter
  mobile_filter :hankaku => true
  trans_sid

  HOUSE_ID_LIST = LiveHouse.all.map(&:id).sort

#  WillPaginate::ViewHelpers.pagination_options[:previous_label] = '前'
#  WillPaginate::ViewHelpers.pagination_options[:next_label] = '次'
#  WillPaginate::ViewHelpers.pagination_options[:param_name] = :p

  def index
    if mobile_or_xhtml?
      @dates = Date.today..(Date.today + 4)
      @schedules = Schedule.find(:all,
        :conditions => {
          :ym => Date.today.strftime("%Y%m"),
          :date => @dates
        },
        :include => [:live_house],
        :order => "date ASC, live_house_id ASC"
      ).group_by(&:date)
      @dates.each do |dt|
        @schedules[dt] = [] unless @schedules[dt]
      end
    else
      # under const
      render :action => "underconstruction"
      return

      @dates = Date.today..(Date.new(Date.today.year, Date.today.mon, -1))
      @houses = LiveHouse.all.index_by(&:id)
      @schedules = Schedule.find(:all,
        :conditions => {
          :ym => [Date.today.strftime("%Y%m"), (Date.today >> 1).strftime("%Y%m")],
          :date => @dates
        },
        :include => [:live_house],
        :order => "date ASC, live_house_id ASC"
      ).group_by(&:date).
        inject(Hash.new){|dst, src| dst.merge!(src[0] => src[1].index_by(&:live_house_id))}
    end

    respond_to do |format|
      format.html  # index.html.erb
      format.xhtml # index.xhtml.erb
      format.xml  { render :xml => @schedules }
    end

  end

  def show
    unless Date.valid_date?(*(params[:id].split(/[-_]/).map(&:to_i)))
      flash[:notice] = "日付が不正です: #{params[:id]}"
      redirect_to :action => :index
      return
    end

    if mobile_or_xhtml?
      today = Date.parse(params[:id])
      @dates = today..(today + 4)
      @schedules = Schedule.find(:all,
        :conditions => {
          :date => @dates
        },
        :include => [:live_house],
        :order => "date ASC, live_house_id ASC"
      ).group_by(&:date)
      @dates.each do |dt|
        @schedules[dt] = [] unless @schedules[dt]
      end
    else
      @dates = Date.today..(Date.new(Date.today.year, Date.today.mon, -1))
      @houses = LiveHouse.all.index_by(&:id)
      @schedules = Schedule.find(:all,
        :conditions => {
          :ym => Date.today.strftime("%Y%m"),
          :date => @dates
        },
        :include => [:live_house],
        :order => "date ASC, live_house_id ASC"
      ).group_by(&:date).
        inject(Hash.new){|dst, src| dst.merge!(src[0] => src[1].index_by(&:live_house_id))}
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xhtml # show.xhtml.erb
      format.xml  { render :xml => @schedules }
    end
  end

  def day
    if request.post?
      d = params[:date]
      params[:id] = "#{d[:year]}-#{d[:month]}-#{d[:day]}"
    end
    unless Date.valid_date?(*(params[:id].split(/[-_]/).map(&:to_i)))
      flash[:notice] = "日付が不正です: #{params[:id]}"
      redirect_to :action => :index
      return
    end
    @today = Date.parse(params[:id])
    @schedules = Schedule.find(:all,
      :conditions => {
        :date => @today
      },
      :include => [:live_house],
      :order => "live_house_id ASC")
    respond_to do |format|
      format.html # day.html.erb
      format.xhtml # day.xhtml.erb
      format.xml  { render :xml => @schedules }
    end
  end

  def search
    if params[:query] && !params[:query].empty?
      @query = params[:query]
      if request.mobile && (request.mobile.docomo? || request.mobile.au?)
        @query2 = params[:query].tosjis 
      else
        @query2 = @query
      end
  # || params[:id]
  #    @schedules = Schedule.paginate_by_fulltext_search(
  #      @query,
  #      :order => 'date_atr ASC',
  #      :page => params[:p],
  #      :per_page => 5
  #    )
      @schedules = Schedule.fulltext_search2(
        @query,
        :order => 'date_atr'
      )
      @schedules.delete_if{|s| s.date < Date.today}
      @schedules.reverse!
      @count = @schedules.size
      @page = (params[:p] && params[:p].to_i > 0) ? params[:p].to_i : 1
      @schedules = (@schedules[(-5 + 5 * @page.to_i)..(-1 + 5 * @page.to_i)] || [])
      @schedule_ids = @schedules.map(&:id)
    else
      @schedules = []
      @schedule_ids = []
      @count = @schedules.count
      @page = 1
    end
      
    respond_to do |format|
      format.html # search.html.erb
      format.xhtml # search.xhtml.erb
      format.xml  { render :xml => @schedules }
    end
  end

  def mobile_switch_filter
    case params[:mobile]
    when "true", "start"
      session[:mobile] = true
    when "destroy"
      session[:mobile] = nil
    end
  end

  def redirect_mobile_filter
    if (
      request.mobile? ||
      request.user_agent =~ /(iPhone|WILLCOM|Windows CE|Opera Mobi)/ ||
      session[:mobile]
     ) && params[:format].to_s != "xhtml"
      params2 = params.dup
      params2[:format] = "xhtml"
      redirect_to params2
      return
    else
      return
    end
  end

  def mobile_or_xhtml?
    request.mobile? || params[:format].to_s == "xhtml"
  end

end
