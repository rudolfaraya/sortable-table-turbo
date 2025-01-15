class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy ]

  # GET /players or /players.json
  def index
    session['filters'] ||= {}
    session['filters'].merge!(filter_params)
  
    @players = Player.includes(:team)
                      .then { search_by_name _1 }
                      .then { filter_by_team _1 }
                      .then { apply_order _1 }
  end

  # GET /players/1 or /players/1.json
  def show
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players or /players.json
  def create
    @player = Player.new(player_params)

    respond_to do |format|
      if @player.save
        format.html { redirect_to player_url(@player), notice: "Player was successfully created." }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1 or /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to player_url(@player), notice: "Player was successfully updated." }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1 or /players/1.json
  def destroy
    @player.destroy!

    respond_to do |format|
      format.html { redirect_to players_url, notice: "Player was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def player_params
      params.require(:player).permit(:name, :team_id, :seasons)
    end
    
    def filter_params
      params.permit(:name, :team_id, :column, :direction)
    end

    def search_by_name(scope)
      session['filters']['name'].present? ? scope.where('players.name like ?', "%#{session['filters']['name']}%") : scope
    end

    def filter_by_team(scope)
      session['filters']['team_id'].present? ? scope.where(team_id: session['filters']['team_id']) : scope
    end
    
    def apply_order(scope)
      scope.order(session['filters'].slice('column', 'direction').values.join(' '))
    end
end
