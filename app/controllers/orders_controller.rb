class OrdersController < ApplicationController
  def index

  end

  def checkout
  end

  def confirm
    @completed_order = @current_order
    @current_order.status = "Awaiting confirmation"
    @current_order.attributes = order_params
    if !@current_order.save
      @current_order.status = "pending"
      render :checkout
    end
  end

  def cancel
    @current_order.status = "cancelled"
    @current_order.save
    session[:order_id] = nil
    redirect_to orders_path
  end

  def finalize
    @current_order.status = "paid"
    items = @current_order.orderitems
    items.each do |item|
      item.product.stock -= item.quantity
      item.product.save
    end
    session[:order_id] = nil
    render :thanks
  end

  def fulfill
    @robot = Robot.find(params[:id])
    @products = Product.where(robot_id: @robot.id )
  end

  def destroy
    @current_order.destroy
    session[:order_id] = nil
    redirect_to orders_path
  end

  def show
    @guest = Order.find(params[:id])
    @card_num = @guest.credit_num.split(//).last(4).join
  end

  private

  def order_params
    params.require(:order).permit([:credit_name, :email, :credit_num, :cvv, :address, :city, :state, :zip])
  end
end
